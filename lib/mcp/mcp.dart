import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';
import './models/server.dart';
import './stdio/stdio_client.dart';

Future<StdioClient> initializeMcpServer(
    Map<String, dynamic> mcpServerConfig) async {
  // 获取服务器配置
  final serverConfig = ServerConfig.fromJson(mcpServerConfig);

  // 创建并初始化 StdioClient
  final mcpClient = StdioClient(serverConfig: serverConfig);
  await mcpClient.initialize();

  // 发送初始化消息
  try {
    final initResponse = await mcpClient.sendInitialize();
    Logger.root.info('初始化响应: $initResponse');

    final toolListResponse = await mcpClient.sendToolList();
    Logger.root.info('工具列表响应: $toolListResponse');
  } catch (e, stackTrace) {
    Logger.root.severe('初始化消息发送失败: $e\n堆栈跟踪:\n$stackTrace');
    rethrow;
  }

  return mcpClient;
}

Future<Map<String, StdioClient>> initializeAllMcpServers(
    String configPath) async {
  final file = File(configPath);
  final contents = await file.readAsString();

  // 添加空值检查和默认值
  final Map<String, dynamic> config =
      json.decode(contents) as Map<String, dynamic>? ?? {};

  final mcpServers = config['mcpServers'] as Map<String, dynamic>;

  final Map<String, StdioClient> clients = {};

  for (var entry in mcpServers.entries) {
    final serverConfig = entry.value as Map<String, dynamic>;
    final client = await initializeMcpServer(serverConfig);
    clients[entry.key] = client;
  }

  return clients;
}

Future<bool> verifyMcpServer(Map<String, dynamic> mcpServerConfig) async {
  final serverConfig = ServerConfig.fromJson(mcpServerConfig);
  final mcpClient = StdioClient(serverConfig: serverConfig);
  try {
    await mcpClient.sendInitialize();
    return true;
  } catch (e) {
    return false;
  }
}
