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

    if (eventType == 'endpoint' && data != null) {
      _handleEndpointEvent(data);
    } else if (eventType == 'message' && data != null) {
      try {
        final jsonData = jsonDecode(data);
        final message = JSONRPCMessage.fromJson(jsonData);
        _handleMessage(message);
      } catch (e, stack) {
        Logger.root.severe('解析服务器消息失败: $e\n$stack');
      }
    } else {
      Logger.root.info('收到未处理的SSE事件类型: $eventType');
    }
  }

  void _handleEndpointEvent(String data) {
    try {
      final uri = Uri.parse(serverConfig.command);
      final baseUrl = uri.origin;

      String rawEndpoint;
      if (data.startsWith("http")) {
        rawEndpoint = data.trim();
      } else {
        final path = data.trim();
        rawEndpoint = baseUrl + (path.startsWith("/") ? path : "/$path");
      }

      final parsedUri = Uri.parse(rawEndpoint);
      if (!parsedUri.hasScheme || !parsedUri.hasAuthority) {
        Logger.root.severe('收到无效的消息端点URL: $rawEndpoint');
        return;
      }

      // 提取新的sessionId - 同时支持sessionId和session_id两种参数名
      String? newSessionId = parsedUri.queryParameters['sessionId'] ??
          parsedUri.queryParameters['session_id'];

      if (newSessionId == null || newSessionId.isEmpty) {
        // 如果URL中没有sessionId参数，尝试从路径中提取
        final match = RegExp(r'sessionId=([^&]+)').firstMatch(data);
        if (match != null) {
          newSessionId = match.group(1);
        }
      }

      if (newSessionId == null || newSessionId.isEmpty) {
        Logger.root.severe('无法从endpoint中提取sessionId: $data');
        return;
      }

      // 构建标准化的endpoint URL
      final Map<String, String> queryParams =
          Map.from(parsedUri.queryParameters);
      queryParams['sessionId'] = newSessionId; // 使用标准化的参数名

      final normalizedUri = Uri(
        scheme: parsedUri.scheme,
        host: parsedUri.host,
        path: parsedUri.path,
        queryParameters: queryParams,
      );

      _messageEndpoint = normalizedUri.toString();
      _isEndpointConfirmed = true;

      Logger.root.info('成功更新endpoint和sessionId: $_messageEndpoint');
      _processStateController.add(const ProcessState.running());

      // 完成endpoint确认
      if (!_endpointConfirmedCompleter.isCompleted) {
        _endpointConfirmedCompleter.complete();
      }
      _endpointTimer?.cancel();
    } catch (e) {
      Logger.root.severe('处理endpoint事件失败: $e');
      if (!_endpointConfirmedCompleter.isCompleted) {
        _endpointConfirmedCompleter.completeError(e);
      }
    }
  }

  Future<void> _ensureValidConnection() async {
    if (_connectionState != ConnectionState.connected ||
        !_isEndpointConfirmed) {
      Logger.root.info('检测到连接状态异常，尝试重新建立连接');
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
      throw StateError('消息端点未初始化');
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
      throw ArgumentError('消息必须有ID');
    }

    final completer = Completer<JSONRPCMessage>();
    _pendingRequests[message.id!] = completer;

    try {
      Logger.root.info('准备发送消息: ${message.id} - ${message.method}');
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
      Logger.root.warning('尝试初始化但消息端点尚未建立，等待端点建立...');
      // 等待一段时间以确保SSE连接已建立并获取到端点
      int attempts = 0;
      const maxAttempts = 30; // 增加到30次尝试
      const delay = Duration(milliseconds: 500);

      while (_messageEndpoint == null && attempts < maxAttempts) {
        await Future.delayed(delay);
        attempts++;
        Logger.root.info('等待消息端点建立: 尝试 $attempts/$maxAttempts');

        // 如果连接已关闭或出错，尝试重新连接
        if (_disposed) {
          Logger.root.warning('SSE连接可能已关闭，尝试重新连接');
          await _connect();
        }
      }

      if (_messageEndpoint == null) {
        Logger.root.severe(
            '消息端点在 ${maxAttempts * delay.inMilliseconds / 1000} 秒后仍未建立');
        throw StateError('消息端点在等待后仍未建立，无法完成初始化');
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
      Logger.root.info('初始化响应: $initResponse');

      // 等待一小段时间确保服务器已处理初始化请求
      await Future.delayed(const Duration(milliseconds: 100));

      // 发送初始化完成通知
      Logger.root.info('发送初始化完成通知');
      await _sendNotification('notifications/initialized', {});

      return initResponse;
    } catch (e, stack) {
      Logger.root.severe('初始化失败: $e\n$stack');
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
