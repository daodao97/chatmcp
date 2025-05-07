import 'package:logging/logging.dart';
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

  // First check the type field
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
          return null;
        }
        mcpClient = InMemoryClient(server: memoryServer);
        break;
      default:
        // Fallback to the command-based logic
        if (serverConfig.command.startsWith('http')) {
          mcpClient = SSEClient(serverConfig: serverConfig);
        } else {
          mcpClient = StdioClient(serverConfig: serverConfig);
        }
    }
  } else {
    // Fallback to the original logic
    if (serverConfig.command.startsWith('http')) {
      mcpClient = SSEClient(serverConfig: serverConfig);
    } else {
      mcpClient = StdioClient(serverConfig: serverConfig);
    }
  }

  // Initialize client
  await mcpClient.initialize();
  final initResponse = await mcpClient.sendInitialize();
  Logger.root.info('Initialization response: $initResponse');

  final toolListResponse = await mcpClient.sendToolList();
  Logger.root.info('Tool list response: $toolListResponse');
  return mcpClient;
}

Future<bool> verifyMcpServer(Map<String, dynamic> mcpServerConfig) async {
  final serverConfig = ServerConfig.fromJson(mcpServerConfig);

  McpClient mcpClient;

  // First check the type field
  if (serverConfig.type != null && serverConfig.type.isNotEmpty) {
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
        // Fallback to the command-based logic
        if (serverConfig.command.startsWith('http')) {
          mcpClient = SSEClient(serverConfig: serverConfig);
        } else {
          mcpClient = StdioClient(serverConfig: serverConfig);
        }
    }
  } else {
    // Fallback to the original logic
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
    return false;
  }
}
