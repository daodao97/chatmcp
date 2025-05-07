import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import '../models/json_rpc_message.dart';
import '../models/server.dart';
import '../client/mcp_client_interface.dart';

/// Custom error class for Streamable HTTP connection errors
class StreamableHTTPError extends Error {
  final int? code;
  final String message;

  StreamableHTTPError(this.code, this.message);

  @override
  String toString() => 'Streamable HTTP error: $message';
}

/// Unauthorized error
class UnauthorizedError extends Error {
  final String message;

  UnauthorizedError([this.message = "Unauthorized"]);

  @override
  String toString() => 'Unauthorized error: $message';
}

/// Reconnection options configuration
class StreamableHTTPReconnectionOptions {
  /// Initial reconnection delay (milliseconds)
  final int initialReconnectionDelay;

  /// Maximum reconnection delay (milliseconds)
  final int maxReconnectionDelay;

  /// Reconnection delay growth factor
  final double reconnectionDelayGrowFactor;

  /// Maximum number of retries
  final int maxRetries;

  const StreamableHTTPReconnectionOptions({
    this.initialReconnectionDelay = 1000,
    this.maxReconnectionDelay = 30000,
    this.reconnectionDelayGrowFactor = 1.5,
    this.maxRetries = 2,
  });
}

/// SSE connection options
class StartSSEOptions {
  /// Resumption token for continuing interrupted long-running requests
  final String? resumptionToken;

  /// Callback invoked when the resumption token changes
  final Function(String)? onResumptionToken;

  /// Override the message ID associated with replayed messages
  final String? replayMessageId;

  StartSSEOptions({
    this.resumptionToken,
    this.onResumptionToken,
    this.replayMessageId,
  });
}

/// Streamable HTTP client implementation
class StreamableClient implements McpClient {
  @override
  final ServerConfig serverConfig;

  /// HTTP client
  final http.Client _httpClient = http.Client();

  /// Server URL
  late final String _url;

  /// Session ID
  String? _sessionId;

  /// Controller for aborting requests
  StreamController<bool>? _abortController;

  /// Reconnection options
  final StreamableHTTPReconnectionOptions _reconnectionOptions;

  /// Number of reconnection attempts
  int _reconnectionAttempts = 0;

  /// Message processing callback
  Function(JSONRPCMessage)? onMessage;

  /// Error handling callback
  Function(Object)? onError;

  /// Connection close callback
  Function()? onClose;

  StreamableClient({
    required this.serverConfig,
    StreamableHTTPReconnectionOptions? reconnectionOptions,
  }) : _reconnectionOptions =
            reconnectionOptions ?? const StreamableHTTPReconnectionOptions() {
    if (serverConfig.command.startsWith('http')) {
      _url = serverConfig.command;
    } else {
      throw ArgumentError('URL is required for StreamableClient');
    }
  }

  /// Get common HTTP headers
  Future<Map<String, String>> _commonHeaders() async {
    final headers = <String, String>{
      'Accept': 'application/json, text/event-stream',
      'Content-Type': 'application/json',
    };

    if (_sessionId != null) {
      headers['mcp-session-id'] = _sessionId!;
    }

    // You can add authorization information here if available

    return headers;
  }

  /// Start or authorize SSE connection
  Future<void> _startOrAuthSse(StartSSEOptions options) async {
    try {
      final headers = await _commonHeaders();

      // Add Last-Event-ID header if there is a resumption token
      if (options.resumptionToken != null) {
        headers['Last-Event-ID'] = options.resumptionToken!;
      }

      // Set Accept header for SSE stream
      headers['Accept'] = 'text/event-stream';

      final request = http.Request('GET', Uri.parse(_url));
      request.headers.addAll(headers);

      final response = await _httpClient.send(request);

      if (!response.statusCode.toString().startsWith('2')) {
        if (response.statusCode == 401) {
          // Authorization failure handling
          throw UnauthorizedError();
        }

        throw StreamableHTTPError(
          response.statusCode,
          'Failed to connect to SSE stream: ${response.reasonPhrase}',
        );
      }

      // Handle session ID
      final responseHeaders = response.headers;
      if (responseHeaders.containsKey('mcp-session-id')) {
        final sessionIdValue = responseHeaders['mcp-session-id'];
        if (sessionIdValue != null) {
          _sessionId = sessionIdValue;
        }
      }

      // Handle SSE stream
      _handleSseStream(response.stream, options);
    } catch (error) {
      onError?.call(error);
      rethrow;
    }
  }

  /// Schedule reconnection
  void _scheduleReconnection(StartSSEOptions options, int attemptIndex) {
    if (attemptIndex >= _reconnectionOptions.maxRetries) {
      onError?.call(Exception('Maximum reconnection attempts reached'));
      return;
    }

    final delay = _calculateReconnectionDelay(attemptIndex);

    Future.delayed(Duration(milliseconds: delay), () {
      if (_abortController == null || _abortController!.isClosed) {
        return; // Already closed, no reconnection
      }

      // Attempt reconnection
      _startOrAuthSse(options).catchError((error) {
        _reconnectionAttempts++;
        _scheduleReconnection(options, attemptIndex + 1);
      });
    });
  }

  /// Calculate reconnection delay
  int _calculateReconnectionDelay(int attemptIndex) {
    final delay = _reconnectionOptions.initialReconnectionDelay *
        _reconnectionOptions.reconnectionDelayGrowFactor.pow(attemptIndex);

    return delay
        .clamp(
          _reconnectionOptions.initialReconnectionDelay.toDouble(),
          _reconnectionOptions.maxReconnectionDelay.toDouble(),
        )
        .toInt();
  }

  /// Handle SSE stream
  void _handleSseStream(Stream<List<int>> stream, StartSSEOptions options) {
    final onResumptionToken = options.onResumptionToken;
    final replayMessageId = options.replayMessageId;
    String? lastEventId;

    // Ensure the stream is a broadcast stream that can be listened to multiple times
    final broadcastStream =
        stream.isBroadcast ? stream : stream.asBroadcastStream();

    // Decode UTF-8 and split into lines
    final lineStream =
        broadcastStream.transform(utf8.decoder).transform(const LineSplitter());

    // SSE processing variables
    String? eventName;
    String data = '';
    String id = '';

    // Subscription handling
    final subscription = lineStream.listen(
      (line) {
        if (line.isEmpty) {
          // An empty line indicates the end of an event
          if (data.isNotEmpty) {
            // Process the event
            if (id.isNotEmpty) {
              lastEventId = id;
              onResumptionToken?.call(id);
            }

            if (eventName == null || eventName == 'message') {
              try {
                final parsed = jsonDecode(data);
                final message = JSONRPCMessage.fromJson(parsed);

                // If the message ID needs to be replaced
                if (replayMessageId != null && message.id != null) {
                  // Since we cannot directly access private fields, we create a new message object
                  final newMessage = JSONRPCMessage(
                    id: replayMessageId,
                    method: message.method,
                    params: message.params,
                    result: message.result,
                    error: message.error,
                  );
                  onMessage?.call(newMessage);
                } else {
                  onMessage?.call(message);
                }
              } catch (error) {
                onError?.call(error);
              }
            }
          }

          // Reset event data
          eventName = null;
          data = '';
          id = '';
        } else if (line.startsWith('event:')) {
          eventName = line.substring(6).trim();
        } else if (line.startsWith('data:')) {
          data += line.substring(5).trim();
        } else if (line.startsWith('id:')) {
          id = line.substring(3).trim();
        }
      },
      onError: (error) {
        onError?.call(error);

        // Attempt reconnection
        if (_abortController != null && !_abortController!.isClosed) {
          if (lastEventId != null) {
            try {
              _scheduleReconnection(
                StartSSEOptions(
                  resumptionToken: lastEventId,
                  onResumptionToken: onResumptionToken,
                  replayMessageId: replayMessageId,
                ),
                0,
              );
            } catch (reconnectError) {
              onError?.call(Exception('Failed to reconnect: $reconnectError'));
            }
          }
        }
      },
      onDone: () {
        // If the stream closes normally, also attempt reconnection
        if (_abortController != null && !_abortController!.isClosed) {
          if (lastEventId != null) {
            try {
              _scheduleReconnection(
                StartSSEOptions(
                  resumptionToken: lastEventId,
                  onResumptionToken: onResumptionToken,
                  replayMessageId: replayMessageId,
                ),
                0,
              );
            } catch (reconnectError) {
              onError?.call(Exception('Failed to reconnect: $reconnectError'));
            }
          }
        }
      },
      cancelOnError: false,
    );

    // Cancel subscription when the abort controller is closed
    if (_abortController != null && !_abortController!.isClosed) {
      // Since _abortController is now a broadcast stream, no need to worry about multiple listeners
      _abortController!.stream.listen((_) {
        subscription.cancel();
      });
    }
  }

  /// Start client connection
  @override
  Future<void> initialize() async {
    if (_abortController != null) {
      throw Exception('StreamableClient already started!');
    }

    // Use a broadcast stream controller to support multiple listeners
    _abortController = StreamController<bool>.broadcast();
  }

  /// Close client connection
  @override
  Future<void> dispose() async {
    _abortController?.add(true);
    await _abortController?.close();
    _abortController = null;
    _httpClient.close();
    onClose?.call();
  }

  /// Send message to server
  @override
  Future<JSONRPCMessage> sendMessage(JSONRPCMessage message) async {
    try {
      final headers = await _commonHeaders();
      final completer = Completer<JSONRPCMessage>();

      final response = await _httpClient.post(
        Uri.parse(_url),
        headers: headers,
        body: jsonEncode(message.toJson()),
      );

      // Handle session ID
      final sessionIdValue = response.headers['mcp-session-id'];
      if (sessionIdValue != null && sessionIdValue.isNotEmpty) {
        _sessionId = sessionIdValue;
      }

      if (!response.statusCode.toString().startsWith('2')) {
        if (response.statusCode == 401) {
          // Authorization failure handling
          throw UnauthorizedError();
        }

        throw StreamableHTTPError(
          response.statusCode,
          'Error POSTing to endpoint (HTTP ${response.statusCode}): ${response.body}',
        );
      }

      // If the response is 202 Accepted, there is no body to process
      if (response.statusCode == 202) {
        // If it is an initialized notification, we start the SSE stream
        if (message.method == 'notifications/initialized') {
          _startOrAuthSse(StartSSEOptions()).catchError((error) {
            onError?.call(error);
          });
        }

        // Create a default success response
        final successResponse = JSONRPCMessage(
          id: message.id,
          method: '', // Add an empty string as the default method value
          result: {'success': true},
        );

        return successResponse;
      }

      // Check response type
      final contentType = response.headers['content-type'];

      if (message.id != null) {
        if (contentType?.contains('text/event-stream') == true) {
          // Handle SSE stream response for the request
          // Create a one-time copy of the response body's byte stream, ensuring the type is List<int> instead of Uint8List
          final responseBodyBytes = response.bodyBytes;
          // Explicitly convert Uint8List to a Stream of type List<int>
          final responseBodyStream = Stream<List<int>>.value(responseBodyBytes);

          // Register a temporary handler function
          final oldOnMessage = onMessage;

          // Use function declaration instead of variable assignment
          void completerOnMessage(JSONRPCMessage responseMessage) {
            if (responseMessage.id == message.id && !completer.isCompleted) {
              completer.complete(responseMessage);
            }
            // Also call the original message handler
            oldOnMessage?.call(responseMessage);
          }

          onMessage = completerOnMessage;

          // Handle SSE stream
          _handleSseStream(
            responseBodyStream,
            StartSSEOptions(),
          );

          // Set timeout
          return completer.future.timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              // Restore the original message handler
              onMessage = oldOnMessage;
              throw TimeoutException('Request timed out: ${message.id}');
            },
          ).whenComplete(() {
            // Restore the original message handler after the request is complete
            onMessage = oldOnMessage;
          });
        } else if (contentType?.contains('application/json') == true) {
          // For non-streaming servers, we may get a direct JSON response
          final data = jsonDecode(response.body);

          if (data is List) {
            for (final item in data) {
              final msg = JSONRPCMessage.fromJson(item);
              if (msg.id == message.id) {
                return msg;
              }
            }
          } else {
            return JSONRPCMessage.fromJson(data);
          }
        }
      }

      throw StreamableHTTPError(
        -1,
        'Unexpected response or content type: $contentType',
      );
    } catch (error) {
      onError?.call(error);
      rethrow;
    }
  }

  @override
  Future<JSONRPCMessage> sendInitialize() async {
    // Send initialization request
    final initMessage = JSONRPCMessage(
      id: 'init-1',
      method: 'initialize',
      params: {
        'protocolVersion': '2024-11-05',
        'capabilities': {
          'roots': {'listChanged': true},
          'sampling': {}
        },
        'clientInfo': {
          'name': 'DartMCPStreamableClient',
          'version': '1.0.0',
        }
      },
    );

    final initResponse = await sendMessage(initMessage);
    Logger.root.info('Initialization request response: $initResponse');

    // Send initialization complete notification
    final notifyMessage = JSONRPCMessage(
      method: 'notifications/initialized',
      params: {},
    );

    await sendMessage(notifyMessage);
    return initResponse;
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

  /// Terminate the current session
  Future<void> terminateSession() async {
    if (_sessionId == null) {
      return; // No session to terminate
    }

    try {
      final headers = await _commonHeaders();

      final response = await _httpClient.delete(
        Uri.parse(_url),
        headers: headers,
      );

      // We specifically handle 405 as a valid response
      if (!response.statusCode.toString().startsWith('2') &&
          response.statusCode != 405) {
        throw StreamableHTTPError(
          response.statusCode,
          'Failed to terminate session: ${response.reasonPhrase}',
        );
      }

      _sessionId = null;
    } catch (error) {
      onError?.call(error);
      rethrow;
    }
  }
}

// Extension method for the pow function for num types
extension NumExtension on num {
  double pow(int exponent) {
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= this;
    }
    return result;
  }
}
