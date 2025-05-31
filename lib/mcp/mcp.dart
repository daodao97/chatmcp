import 'package:logging/logging.dart';
import '../utils/toast.dart';
import './models/server.dart';
import './client/mcp_client_interface.dart';
import './stdio/stdio_client.dart';
import './sse/sse_client.dart';
import './streamable/streamable_client.dart';
import 'inmemory/client.dart';
import 'inmemory_server/factory.dart';

Future<McpClient?> initializeMcpServer(
    Map<String, dynamic> mcpServerConfig) async {
  // Get server configuration
  final serverConfig = ServerConfig.fromJson(mcpServerConfig);

  // Create appropriate client based on configuration
  McpClient mcpClient;

  // 首先检查类型字段
  if (serverConfig.type.isNotEmpty) {
    switch (serverConfig.type) {
      case 'sse':
        mcpClient = SSEClient(serverConfig: serverConfig);
        break;
      case 'streamable':
        mcpClient = StreamableClient(serverConfig: serverConfig);
        break;
      case 'stdio':
        mcpClient = StdioClient(serverConfig: serverConfig);
        break;
      case 'inmemory':
        final memoryServer =
            MemoryServerFactory.createMemoryServer(serverConfig.command);
        if (memoryServer == null) {
          Logger.root.severe('Failed to create memory server');

          ToastUtils.error('Memory server creation failed');

          return null;
        }
        mcpClient = InMemoryClient(server: memoryServer);
        break;
      default:
        // 降级为基于命令的逻辑
        if (serverConfig.command.startsWith('http')) {
          mcpClient = SSEClient(serverConfig: serverConfig);
        } else {
          mcpClient = StdioClient(serverConfig: serverConfig);
        }
    }
  } else {
    // 降级为原来的逻辑
    if (serverConfig.command.startsWith('http')) {
      mcpClient = SSEClient(serverConfig: serverConfig);
    } else {
      mcpClient = StdioClient(serverConfig: serverConfig);
    }
  }

  try {
    await mcpClient.initialize();
    final initResponse = await mcpClient.sendInitialize();
    Logger.root.info('Initialization response: $initResponse');

    final toolListResponse = await mcpClient.sendToolList();
    Logger.root.info('Tool list response: $toolListResponse');

    return mcpClient;
  } catch (e) {
    Logger.root.severe('Failed to initialize MCP server: $e');

    // 显示错误 toast 通知
    ToastUtils.error('MCP Error: ${e.toString()}');

    return null;
  }
}

Future<bool> verifyMcpServer(Map<String, dynamic> mcpServerConfig) async {
  final serverConfig = ServerConfig.fromJson(mcpServerConfig);

  McpClient mcpClient;

  if (serverConfig.type.isNotEmpty) {
    switch (serverConfig.type) {
      case 'sse':
        mcpClient = SSEClient(serverConfig: serverConfig);
        break;
      case 'streamable':
        mcpClient = StreamableClient(serverConfig: serverConfig);
        break;
      case 'stdio':
        mcpClient = StdioClient(serverConfig: serverConfig);
        break;
      default:
        // 降级为基于命令的逻辑
        if (serverConfig.command.startsWith('http')) {
          mcpClient = SSEClient(serverConfig: serverConfig);
        } else {
          mcpClient = StdioClient(serverConfig: serverConfig);
        }
    }
  } else {
    // 降级为原来的逻辑
    if (serverConfig.command.startsWith('http')) {
      mcpClient = SSEClient(serverConfig: serverConfig);
    } else {
      mcpClient = StdioClient(serverConfig: serverConfig);
    }
  }

  try {
    await mcpClient.sendInitialize();
    return true;
  } catch (e) {
    Logger.root.warning('Failed to verify MCP server: $e');

    ToastUtils.warn('MCP server verification failed: ${e.toString()}');

    return false;
  }
}
