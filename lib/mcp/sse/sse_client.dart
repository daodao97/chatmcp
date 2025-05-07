import 'package:chatmcp/mcp/stdio/stdio_client.dart';
import 'package:synchronized/synchronized.dart';

import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart'
    as flutter_client_sse;

import '../client/mcp_client_interface.dart';
import '../models/json_rpc_message.dart';
import '../models/server.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

class SSEClient implements McpClient {
  final ServerConfig _serverConfig;
  final _pendingRequests = <String, Completer<JSONRPCMessage>>{};
  final _processStateController = StreamController<ProcessState>.broadcast();
  Stream<ProcessState> get processStateStream => _processStateController.stream;

  StreamSubscription? _sseSubscription;
  final _writeLock = Lock();
  String? _messageEndpoint;

  bool _isConnecting = false;
  bool _disposed = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _initialReconnectDelay = Duration(seconds: 1);
  Timer? _reconnectTimer;

  final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=utf-8',
    'Accept': 'application/json; charset=utf-8',
  };

  final Map<String, String> _sseHeaders = {
    'Accept': 'text/event-stream',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive',
  };

  SSEClient({required ServerConfig serverConfig})
      : _serverConfig = serverConfig;

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
    try {
      Logger.root.info('开始建立SSE连接: ${serverConfig.command}');
      _processStateController.add(const ProcessState.starting());

      _sseSubscription?.cancel();

      // 检查是否需要更新SSE连接URL中的会话ID
      String connectionUrl = serverConfig.command;

      // 如果之前连接过且有消息端点且消息端点中包含会话ID，则尝试更新连接URL
      if (_messageEndpoint != null) {
        try {
          final messageUri = Uri.parse(_messageEndpoint!);
          if (messageUri.queryParameters.containsKey('session_id')) {
            final sessionId = messageUri.queryParameters['session_id'];
            if (sessionId != null && sessionId.isNotEmpty) {
              Logger.root.info('使用当前会话ID进行SSE连接: $sessionId');

              final originalUri = Uri.parse(connectionUrl);
              final Map<String, String> queryParams =
                  Map.from(originalUri.queryParameters);
              queryParams['session_id'] = sessionId;

              final updatedUri = Uri(
                scheme: originalUri.scheme,
                host: originalUri.host,
                path: originalUri.path,
                queryParameters: queryParams,
              );

              connectionUrl = updatedUri.toString();
              Logger.root.info('更新后的SSE连接URL: $connectionUrl');
            }
          }
        } catch (e) {
          Logger.root.warning('尝试更新SSE连接URL时出错: $e');
        }
      }

      Logger.root.info('建立SSE连接到: $connectionUrl');

      // 使用flutter_client_sse库建立SSE连接
      _sseSubscription = flutter_client_sse.SSEClient.subscribeToSSE(
        method: SSERequestType.GET,
        url: connectionUrl,
        header: _sseHeaders,
      ).listen(
        (event) {
          Logger.root.fine(
              '收到SSE事件: ${event.event}, ID: ${event.id}, 数据长度: ${event.data?.length ?? 0}字节');
          _handleSSEEvent(event);
        },
        onError: (error) {
          Logger.root.severe('SSE连接错误: $error');
          _processStateController
              .add(ProcessState.error(error, StackTrace.current));
          _scheduleReconnect();
        },
        onDone: () {
          Logger.root.info('SSE连接关闭');
          _processStateController.add(const ProcessState.exited(0));
          _scheduleReconnect();
        },
      );

      Logger.root.info('SSE连接建立成功，等待事件...');
      _reconnectAttempts = 0;
    } catch (e, stack) {
      Logger.root.severe('SSE连接失败: $e\n$stack');
      _processStateController.add(ProcessState.error(e, stack));
      _scheduleReconnect();
    } finally {
      _isConnecting = false;
    }
  }

  void _handleSSEEvent(flutter_client_sse.SSEModel event) {
    final eventType = event.event;
    final data = event.data;

    Logger.root.info('event: $eventType, data: $data');

    if (eventType == 'endpoint' && data != null) {
      final uri = Uri.parse(serverConfig.command);
      final baseUrl = uri.origin;
      // 处理并规范化消息端点URL，确保没有多余的空格
      String rawEndpoint;
      if (data.startsWith("http")) {
        rawEndpoint = data.trim();
      } else {
        final path = data.trim();
        rawEndpoint = baseUrl + (path.startsWith("/") ? path : "/$path");
      }

      try {
        // 验证消息端点URL是否有效
        final parsedUri = Uri.parse(rawEndpoint);
        if (!parsedUri.hasScheme || !parsedUri.hasAuthority) {
          Logger.root.severe('收到无效的消息端点URL: $rawEndpoint');
          return;
        }

        _messageEndpoint = rawEndpoint;
        Logger.root.info('成功设置消息端点: $_messageEndpoint');
        _processStateController.add(const ProcessState.running());
      } catch (e) {
        Logger.root.severe('解析消息端点URL失败: $rawEndpoint, 错误: $e');
      }
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

  void _scheduleReconnect() {
    if (_disposed || _isConnecting || _reconnectTimer != null) return;

    _reconnectAttempts++;
    if (_reconnectAttempts > _maxReconnectAttempts) {
      Logger.root.severe('达到最大重连尝试次数 ($_maxReconnectAttempts)，停止重连');
      return;
    }

    final delay = _initialReconnectDelay * (1 << (_reconnectAttempts - 1));
    Logger.root.info('计划在 ${delay.inSeconds} 秒后进行第 $_reconnectAttempts 次重连尝试');

    // 在重连前尝试刷新会话ID
    _reconnectTimer = Timer(delay, () async {
      _reconnectTimer = null;

      // 如果消息端点已建立，尝试刷新会话ID
      if (_messageEndpoint != null) {
        try {
          final refreshed = await _refreshSessionId();
          if (refreshed) {
            Logger.root.info('重连前成功刷新会话ID');
          } else {
            Logger.root.warning('重连前刷新会话ID失败，使用原有会话ID继续');
          }
        } catch (e) {
          Logger.root.warning('重连前刷新会话ID时发生错误: $e');
        }
      }

      _connect();
    });
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    // 取消SSE订阅
    await _sseSubscription?.cancel();
    _sseSubscription = null;

    await _processStateController.close();
    _messageEndpoint = null;
  }

  Future<void> _sendHttpPost(Map<String, dynamic> data) async {
    if (_messageEndpoint == null) {
      throw StateError('消息端点未初始化 ${jsonEncode(data)}');
    }

    await _writeLock.synchronized(() async {
      try {
        // 构建URL并确保它是有效的
        final String cleanEndpoint = _messageEndpoint!.trim();
        Logger.root.info('构建HTTP请求URL: $cleanEndpoint');

        // 解析URL以检查和处理可能存在的问题
        final uri = Uri.parse(cleanEndpoint);

        // 检查URL查询参数中是否有session_id
        if (uri.queryParameters.containsKey('session_id')) {
          final sessionId = uri.queryParameters['session_id'];
          Logger.root.info('检测到会话ID: $sessionId');

          // 验证会话ID是否有效（通常是非空且有一定长度的UUID）
          if (sessionId == null || sessionId.isEmpty || sessionId.length < 10) {
            Logger.root.warning('可能无效的会话ID: $sessionId，尝试获取新的会话ID');
            // 这里可以添加获取新会话ID的逻辑
          }
        } else {
          Logger.root.warning('URL中没有检测到会话ID参数');
        }

        Logger.root.info('发送HTTP请求到 $cleanEndpoint: ${jsonEncode(data)}');

        final response = await http.post(
          Uri.parse(cleanEndpoint),
          headers: _headers,
          body: jsonEncode(data),
        );

        Logger.root.info('HTTP响应状态码: ${response.statusCode}');

        if (response.statusCode >= 400) {
          final errorBody = response.body;
          Logger.root
              .severe('HTTP POST failed: ${response.statusCode} - $errorBody');
          throw Exception(
              'MCP HTTP POST ERROR: ${response.statusCode} - $errorBody');
        } else {
          // 记录成功响应
          if (response.body.isNotEmpty) {
            try {
              // 使用utf8解码确保中文正确显示
              Logger.root.info(
                  'HTTP response content: ${utf8.decode(response.bodyBytes)}');
            } catch (e) {
              // 如果解码失败，回退到原始方式
              Logger.root.info('HTTP response content: ${response.body}');
            }
          }
        }
      } catch (e, stack) {
        Logger.root.severe('发送HTTP POST失败: $e\n$stack');
        rethrow;
      }
    });
  }

  Future<bool> _refreshSessionId() async {
    // 如果没有消息端点，无法刷新会话ID
    if (_messageEndpoint == null) {
      Logger.root.severe('尝试刷新会话ID但消息端点尚未建立');
      return false;
    }

    try {
      Logger.root.info('尝试刷新会话ID');

      // 提取原始URL的基本部分（不包含查询参数）
      final Uri originalUri = Uri.parse(_messageEndpoint!);
      final String baseUrl =
          '${originalUri.scheme}://${originalUri.host}${originalUri.path}';

      // 构建获取新会话ID的URL（这里需要根据实际API调整）
      final String sessionUrl = '$baseUrl?action=new_session';

      Logger.root.info('请求新的会话ID: $sessionUrl');

      // 发送请求获取新的会话ID
      final response = await http.get(Uri.parse(sessionUrl));

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          final String? newSessionId = responseData['session_id'];

          if (newSessionId != null && newSessionId.isNotEmpty) {
            // 更新消息端点的会话ID
            final Map<String, String> queryParams =
                Map.from(originalUri.queryParameters);
            queryParams['session_id'] = newSessionId;

            final Uri newUri = Uri(
              scheme: originalUri.scheme,
              host: originalUri.host,
              path: originalUri.path,
              queryParameters: queryParams,
            );

            _messageEndpoint = newUri.toString();
            Logger.root.info('成功刷新会话ID，新的消息端点: $_messageEndpoint');
            return true;
          } else {
            Logger.root.severe('获取新会话ID失败: 响应中没有有效的会话ID');
          }
        } catch (e) {
          Logger.root.severe('解析会话ID响应时出错: $e');
        }
      } else {
        Logger.root.severe(
            '获取新会话ID失败，状态码: ${response.statusCode}, 响应: ${response.body}');
      }
    } catch (e, stack) {
      Logger.root.severe('刷新会话ID时发生异常: $e\n$stack');
    }

    return false;
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
      bool retried = false;

      // 尝试发送请求，如果会话ID无效则尝试刷新
      while (true) {
        try {
          await _sendHttpPost(message.toJson());
          break; // 如果成功发送，则跳出循环
        } catch (e) {
          // 检查是否是会话ID无效的错误
          if (!retried && e.toString().contains('Invalid session id')) {
            Logger.root.warning('检测到会话ID无效，尝试刷新会话ID');
            retried = true;

            // 尝试刷新会话ID
            bool refreshed = await _refreshSessionId();
            if (refreshed) {
              Logger.root.info('会话ID已刷新，重试发送消息');
              continue; // 重试发送请求
            }
          }
          // 其他错误或刷新会话ID失败，直接抛出异常
          rethrow;
        }
      }

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
        if (_disposed || _sseSubscription == null) {
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

    try {
      await _sendHttpPost(notification.toJson());
    } catch (e) {
      // 如果是会话ID无效的错误，尝试刷新后重试一次
      if (e.toString().contains('Invalid session id')) {
        Logger.root.warning('发送通知时检测到会话ID无效，尝试刷新会话ID并重试');

        // 尝试刷新会话ID
        bool refreshed = await _refreshSessionId();
        if (refreshed) {
          Logger.root.info('会话ID已刷新，重试发送通知');
          await _sendHttpPost(notification.toJson());
        } else {
          Logger.root.severe('刷新会话ID失败，无法发送通知: $method');
          rethrow;
        }
      } else {
        // 其他错误直接抛出
        rethrow;
      }
    }
  }
}
