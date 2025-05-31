import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:synchronized/synchronized.dart';
import '../models/json_rpc_message.dart';
import '../models/server.dart';
import '../../utils/process.dart';
import '../client/mcp_client_interface.dart';

class StdioClient implements McpClient {
  @override
  final ServerConfig serverConfig;
  late final Process process;
  final _writeLock = Lock();
  final _pendingRequests = <String, Completer<JSONRPCMessage>>{};
  final List<Function(String)> stdErrCallback;
  final List<Function(String)> stdOutCallback;

  // Add StreamController
  final _processStateController = StreamController<ProcessState>.broadcast();

  // Provide public Stream
  Stream<ProcessState> get processStateStream => _processStateController.stream;

  StdioClient({
    required this.serverConfig,
    this.stdErrCallback = const [],
    this.stdOutCallback = const [],
  });

  void _handleMessage(JSONRPCMessage message) {
    if (message.id != null && _pendingRequests.containsKey(message.id)) {
      final completer = _pendingRequests.remove(message.id);
      completer?.complete(message);
    }
  }

  Future<void> _setupProcess() async {
    Logger.root.info(
        'Starting process: ${serverConfig.command} ${serverConfig.args.join(" ")}');

    _processStateController.add(const ProcessState.starting());

    process = await startProcess(
      serverConfig.command,
      serverConfig.args,
      serverConfig.env,
    );

    Logger.root.info('Process startup status: PID=${process.pid}');

    // Use utf8 decoder
    final stdoutStream =
        process.stdout.transform(utf8.decoder).transform(const LineSplitter());

    stdoutStream.listen(
      (String line) {
        try {
          for (final callback in stdOutCallback) {
            callback(line);
          }
          final data = jsonDecode(line);
          final message = JSONRPCMessage.fromJson(data);
          _handleMessage(message);
        } catch (e, stack) {
          Logger.root.severe('Failed to parse server output: $e\n$stack');
        }
      },
      onError: (error) {
        Logger.root.severe('stdout error: $error');
        for (final callback in stdErrCallback) {
          callback(error.toString());
        }
      },
      onDone: () {
        Logger.root.info('stdout stream closed');
      },
    );

    process.stderr.transform(utf8.decoder).listen(
      (String text) {
        Logger.root.warning('Server error output: $text');
        for (final callback in stdErrCallback) {
          callback(text);
        }
      },
      onError: (error) {
        Logger.root.severe('stderr error: $error');
        for (final callback in stdErrCallback) {
          callback(error.toString());
        }
      },
    );

    // Listen for process exit
    process.exitCode.then((code) {
      Logger.root.info('Process exited with code: $code');
      _processStateController.add(ProcessState.exited(code));
    });

    _processStateController.add(const ProcessState.running());
  }

  Future<void> write(List<int> data) async {
    try {
      await _writeLock.synchronized(() async {
        final String jsonStr = utf8.decode(data);
        process.stdin.writeln(utf8.decode(data));
        await process.stdin.flush();
        Logger.root.info('Data written: $jsonStr');
      });
    } catch (e) {
      Logger.root.severe('Failed to write data: $e');
      rethrow;
    }
  }

  // Add initialize method
  @override
  Future<void> initialize() async {
    await _setupProcess();
  }

  // Modify dispose method
  @override
  Future<void> dispose() async {
    await _processStateController.close();
    process.kill();
  }

  @override
  Future<JSONRPCMessage> sendMessage(JSONRPCMessage message) async {
    if (message.id == null) {
      throw ArgumentError('Message must have an id');
    }

    final completer = Completer<JSONRPCMessage>();
    _pendingRequests[message.id!] = completer;

    try {
      await write(utf8.encode(jsonEncode(message.toJson())));
      return await completer.future.timeout(
        const Duration(seconds: 60 * 60),
        onTimeout: () {
          _pendingRequests.remove(message.id);
          throw TimeoutException('Request timed out: ${message.id}');
        },
      );
    } catch (e) {
      _pendingRequests.remove(message.id);
      rethrow;
    }
  }

  @override
  Future<JSONRPCMessage> sendInitialize() async {
    // Step 1: Send initialization request
    final initMessage =
        JSONRPCMessage(id: 'init-1', method: 'initialize', params: {
      'protocolVersion': '2024-11-05',
      'capabilities': {
        'roots': {'listChanged': true},
        'sampling': {}
      },
      'clientInfo': {'name': 'DartMCPClient', 'version': '1.0.0'}
    });

    final initResponse = await sendMessage(initMessage);
    Logger.root.info('Initialization request response: $initResponse');

    // Step 2: Send initialization complete notification (no response needed)
    final notifyMessage =
        JSONRPCMessage(method: 'notifications/initialized', params: {});

    await write(utf8.encode(jsonEncode(notifyMessage.toJson())));
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
}

// Add process state enum
enum ProcessStateType {
  starting,
  running,
  error,
  exited,
}

// Add process state class
class ProcessState {
  final ProcessStateType type;
  final dynamic error;
  final StackTrace? stackTrace;
  final int? exitCode;

  const ProcessState._(this.type, {this.error, this.stackTrace, this.exitCode});

  const ProcessState.starting() : this._(ProcessStateType.starting);
  const ProcessState.running() : this._(ProcessStateType.running);
  const ProcessState.error(dynamic err, StackTrace stack)
      : this._(ProcessStateType.error, error: err, stackTrace: stack);
  const ProcessState.exited(int code)
      : this._(ProcessStateType.exited, exitCode: code);
}
