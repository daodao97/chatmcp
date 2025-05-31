import 'package:chatmcp/mcp/stdio/stdio_client.dart';
import 'package:synchronized/synchronized.dart';
import 'package:eventflux/eventflux.dart';

import '../client/mcp_client_interface.dart';
import '../models/json_rpc_message.dart';
import '../models/server.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'dart:convert';
import 'dart:async';

// 连接状态枚举
enum ConnectionState {
  disconnected,
  connecting,
  waitingForEndpoint,
  connected,
  reconnecting
}

class SSEClient implements McpClient {
  final ServerConfig _serverConfig;
  final _pendingRequests = <String, Completer<JSONRPCMessage>>{};
  final _processStateController = StreamController<ProcessState>.broadcast();
  Stream<ProcessState> get processStateStream => _processStateController.stream;

  late final EventFlux _eventFlux;
  final _writeLock = Lock();
  String? _messageEndpoint;
  bool _isEndpointConfirmed = false;
  Completer<void> _endpointConfirmedCompleter = Completer<void>();

  bool _isConnecting = false;
  bool _disposed = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _initialReconnectDelay = Duration(seconds: 1);
  static const Duration _endpointTimeout = Duration(seconds: 10);
  Timer? _endpointTimer;

  ConnectionState _connectionState = ConnectionState.disconnected;

  final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=utf-8',
    'Accept': 'application/json; charset=utf-8',
  };

  SSEClient({required ServerConfig serverConfig})
      : _serverConfig = serverConfig {
    _eventFlux = EventFlux.spawn();
  }

  @override
  ServerConfig get serverConfig => _serverConfig;

  void _handleMessage(JSONRPCMessage message) {
    if (message.id != null && _pendingRequests.containsKey(message.id)) {
      final completer = _pendingRequests.remove(message.id);
      completer?.complete(message);
    }
  }

  @override
  Future<void> initialize() async {
    _reconnectAttempts = 0;
    await _connect();
  }

  Future<void> _connect() async {
    if (_isConnecting || _disposed) return;

    _isConnecting = true;
    _connectionState = ConnectionState.connecting;
    _isEndpointConfirmed = false;

    try {
      Logger.root.info('开始建立SSE连接: ${serverConfig.command}');
      _processStateController.add(const ProcessState.starting());

      // 重置endpoint确认状态
      _endpointTimer?.cancel();
      _endpointTimer = null;

      // 创建新的completer
      _endpointConfirmedCompleter = Completer<void>();

      String connectionUrl = serverConfig.command;
      Logger.root.info('建立SSE连接到: $connectionUrl');
      _connectionState = ConnectionState.waitingForEndpoint;

      // 设置endpoint超时定时器
      _endpointTimer = Timer(_endpointTimeout, () {
        if (!_endpointConfirmedCompleter.isCompleted) {
          _endpointConfirmedCompleter
              .completeError('Endpoint confirmation timeout');
        }
      });

      _eventFlux.connect(
        EventFluxConnectionType.get,
        connectionUrl,
        header: _headers,
        autoReconnect: true,
        reconnectConfig: ReconnectConfig(
          mode: ReconnectMode.exponential,
          interval: _initialReconnectDelay,
          maxAttempts: _maxReconnectAttempts,
          onReconnect: () {
            Logger.root.info('SSE连接正在重连');
            _connectionState = ConnectionState.reconnecting;
          },
        ),
        onSuccessCallback: (response) {
          response?.stream?.listen(
            (event) {
              Logger.root.fine(
                  '收到SSE事件: ${event.event}, ID: ${event.id}, 数据长度: ${event.data?.length ?? 0}字节');
              _handleSSEEvent(event);
            },
          );
        },
        onError: (error) {
          Logger.root.severe('SSE连接错误: $error');
          _connectionState = ConnectionState.disconnected;
          _processStateController
              .add(ProcessState.error(error, StackTrace.current));
        },
        onConnectionClose: () {
          Logger.root.info('SSE连接关闭');
          _connectionState = ConnectionState.disconnected;
          _processStateController.add(const ProcessState.exited(0));
        },
        tag: 'MCP-SSE',
      );

      // 等待endpoint确认
      try {
        await _endpointConfirmedCompleter.future.timeout(_endpointTimeout);
        Logger.root.info('SSE连接已确认并获取到有效endpoint');
        _connectionState = ConnectionState.connected;
        _reconnectAttempts = 0;
      } catch (e) {
        Logger.root.severe('等待endpoint确认超时: $e');
        throw Exception('Failed to confirm endpoint: $e');
      }
    } catch (e, stack) {
      Logger.root.severe('SSE连接失败: $e\n$stack');
      _connectionState = ConnectionState.disconnected;
      _processStateController.add(ProcessState.error(e, stack));
    } finally {
      _isConnecting = false;
    }
  }

  void _handleSSEEvent(EventFluxData event) {
    final eventType = event.event;
    final data = event.data;

    Logger.root.info('event: $eventType, data: $data');

    if (eventType == 'endpoint') {
      _handleEndpointEvent(data);
    } else if (eventType == 'message') {
      try {
        final jsonData = jsonDecode(data);
        final message = JSONRPCMessage.fromJson(jsonData);
        _handleMessage(message);
      } catch (e, stack) {
        Logger.root.severe('handle message failed: $e\n$stack');
      }
    } else {
      Logger.root.info('unhandled event: $eventType');
    }
  }

  void _handleEndpointEvent(String data) {
    try {
      final uri = Uri.parse(serverConfig.command);
      final baseUrl = uri.origin;

      data = data.trim();
      String rawEndpoint = data.startsWith("http") ? data : baseUrl + data;

      final parsedUri = Uri.parse(rawEndpoint);
      if (!parsedUri.hasScheme || !parsedUri.hasAuthority) {
        Logger.root.severe('invalid endpoint: $rawEndpoint');
        return;
      }

      // 构建标准化的endpoint URL
      final Map<String, String> queryParams =
          Map.from(parsedUri.queryParameters);

      uri.queryParameters.forEach((key, value) {
        queryParams[key] = value;
      });

      final normalizedUri = Uri(
        scheme: parsedUri.scheme,
        host: parsedUri.host,
        port: parsedUri.port,
        path: parsedUri.path,
        queryParameters: queryParams,
      );

      _messageEndpoint = normalizedUri.toString();
      _isEndpointConfirmed = true;

      Logger.root.info('endpoint: $_messageEndpoint');
      _processStateController.add(const ProcessState.running());

      // 完成endpoint确认
      if (!_endpointConfirmedCompleter.isCompleted) {
        _endpointConfirmedCompleter.complete();
      }
      _endpointTimer?.cancel();
    } catch (e) {
      Logger.root.severe('handle endpoint event failed: $e');
      if (!_endpointConfirmedCompleter.isCompleted) {
        _endpointConfirmedCompleter.completeError(e);
      }
    }
  }

  Future<void> _ensureValidConnection() async {
    if (_connectionState != ConnectionState.connected ||
        !_isEndpointConfirmed) {
      Logger.root.info('connection state is not valid, try to reconnect');
      await _connect();
    }
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    _endpointTimer?.cancel();
    _endpointTimer = null;

    // 断开SSE连接
    await _eventFlux.disconnect();

    await _processStateController.close();
    _messageEndpoint = null;
  }

  Future<void> _sendHttpPost(Map<String, dynamic> data) async {
    if (_messageEndpoint == null) {
      throw StateError('message endpoint is not initialized');
    }

    await _writeLock.synchronized(() async {
      try {
        await _ensureValidConnection();

        final response = await http.post(
          Uri.parse(_messageEndpoint!),
          headers: _headers,
          body: jsonEncode(data),
        );

        if (response.statusCode >= 400) {
          final errorBody = response.body;
          throw Exception(
              'HTTP POST ERROR: ${response.statusCode} - $errorBody');
        }
      } catch (e) {
        Logger.root.severe('HTTP POST failed: $e');
        rethrow;
      }
    });
  }

  @override
  Future<JSONRPCMessage> sendMessage(JSONRPCMessage message) async {
    if (message.id == null) {
      throw ArgumentError('message must have an id');
    }

    final completer = Completer<JSONRPCMessage>();
    _pendingRequests[message.id!] = completer;

    try {
      Logger.root.info('send message: ${message.id} - ${message.method}');
      await _sendHttpPost(message.toJson());

      return await completer.future.timeout(
        const Duration(seconds: 60 * 60),
        onTimeout: () {
          _pendingRequests.remove(message.id);
          throw TimeoutException('请求超时: ${message.id}');
        },
      );
    } catch (e) {
      _pendingRequests.remove(message.id);
      rethrow;
    }
  }

  @override
  Future<JSONRPCMessage> sendInitialize() async {
    // 确保连接已经建立
    if (_messageEndpoint == null) {
      Logger.root.warning(
          'try to initialize but message endpoint is not established, wait for endpoint to be established...');
      // 等待一段时间以确保SSE连接已建立并获取到端点
      int attempts = 0;
      const maxAttempts = 30; // 增加到30次尝试
      const delay = Duration(milliseconds: 500);

      while (_messageEndpoint == null && attempts < maxAttempts) {
        await Future.delayed(delay);
        attempts++;
        Logger.root.info(
            'wait for message endpoint to be established: attempt $attempts/$maxAttempts');

        // 如果连接已关闭或出错，尝试重新连接
        if (_disposed) {
          Logger.root.warning('SSE connection may be closed, try to reconnect');
          await _connect();
        }
      }

      if (_messageEndpoint == null) {
        Logger.root.severe(
            'message endpoint is not established after ${maxAttempts * delay.inMilliseconds / 1000} seconds');
        throw StateError(
            'message endpoint is not established, cannot complete initialization');
      }
    }

    Logger.root.info('开始发送初始化请求到 $_messageEndpoint');

    // 发送初始化请求
    final initMessage =
        JSONRPCMessage(id: 'init-1', method: 'initialize', params: {
      'protocolVersion': '2024-11-05',
      'capabilities': {
        'roots': {'listChanged': true},
        'sampling': {}
      },
      'clientInfo': {'name': 'DartMCPClient', 'version': '1.0.0'}
    });

    Logger.root.info('初始化请求内容: ${jsonEncode(initMessage.toJson())}');

    try {
      final initResponse = await sendMessage(initMessage);
      Logger.root.info('initialize response: $initResponse');

      // 等待一小段时间确保服务器已处理初始化请求
      await Future.delayed(const Duration(milliseconds: 100));

      // 发送初始化完成通知
      Logger.root.info('send initialize completed notification');
      await _sendNotification('notifications/initialized', {});

      return initResponse;
    } catch (e, stack) {
      Logger.root.severe('initialize failed: $e\n$stack');
      rethrow;
    }
  }

  @override
  Future<JSONRPCMessage> sendPing() async {
    final message = JSONRPCMessage(id: 'ping-1', method: 'ping');
    return sendMessage(message);
  }

  @override
  Future<JSONRPCMessage> sendToolList() async {
    final message = JSONRPCMessage(id: 'tool-list-1', method: 'tools/list');
    return sendMessage(message);
  }

  @override
  Future<JSONRPCMessage> sendToolCall({
    required String name,
    required Map<String, dynamic> arguments,
    String? id,
  }) async {
    final message = JSONRPCMessage(
      method: 'tools/call',
      params: {
        'name': name,
        'arguments': arguments,
        '_meta': {'progressToken': 0},
      },
      id: id ?? 'tool-call-${DateTime.now().millisecondsSinceEpoch}',
    );

    return sendMessage(message);
  }

  // 添加一个实用方法来发送符合格式的通知
  Future<void> _sendNotification(
      String method, Map<String, dynamic> params) async {
    final notification = JSONRPCMessage(
      method: method,
      params: params,
    );

    await _sendHttpPost(notification.toJson());
  }
}
