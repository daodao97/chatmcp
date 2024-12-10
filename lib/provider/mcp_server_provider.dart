import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../mcp/stdio/stdio_client.dart';
import '../mcp/mcp.dart';
import 'package:logging/logging.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:dio/dio.dart';

class McpServerProvider extends ChangeNotifier {
  static const _configFileName = 'mcp_server.json';

  Map<String, StdioClient> _servers = {};

  Map<String, StdioClient> get clients => _servers;

  // 获取配置文件路径
  Future<String> get _configFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_configFileName';
  }

  // 检查并创建初始配置文件
  Future<void> _initConfigFile() async {
    final file = File(await _configFilePath);

    if (!await file.exists()) {
      // 从 assets 加载默认配置
      final defaultConfig =
          await rootBundle.loadString('assets/mcp_server.json');
      // 写入默认配置到配置文件
      await file.writeAsString(defaultConfig);
      Logger.root.info('已从 assets 初始化默认配置文件');
    }
  }

  // 读取服务器配置
  Future<Map<String, dynamic>> loadServers() async {
    try {
      await _initConfigFile();
      final file = File(await _configFilePath);
      final String contents = await file.readAsString();
      final Map<String, dynamic> data = json.decode(contents);
      if (data['mcpServers'] == null) {
        data['mcpServers'] = <String, dynamic>{};
      }
      return data;
    } catch (e, stackTrace) {
      Logger.root.severe('读取配置文件失败: $e, stackTrace: $stackTrace');
      return {'mcpServers': <String, dynamic>{}};
    }
  }

  // 保存服务器配置
  Future<void> saveServers(Map<String, dynamic> servers) async {
    try {
      final file = File(await _configFilePath);
      final prettyContents =
          const JsonEncoder.withIndent('  ').convert(servers);
      Logger.root.info('保存的配置文件内容:\n$prettyContents');
      await file.writeAsString(prettyContents);
      // 保存后重新初始化客户端
      await _reinitializeClients();
    } catch (e, stackTrace) {
      Logger.root.severe('保存配置文件失败: $e, stackTrace: $stackTrace');
    }
  }

  // 重新初始化客户端
  Future<void> _reinitializeClients() async {
    _servers.clear();
    await init();
    notifyListeners();
  }

  void addClient(String key, StdioClient client) {
    _servers[key] = client;
    notifyListeners();
  }

  StdioClient? getClient(String key) {
    return _servers[key];
  }

  Future<Map<String, List<Map<String, dynamic>>>> getTools() async {
    Map<String, List<Map<String, dynamic>>> result = {};

    for (var entry in _servers.entries) {
      final clientName = entry.key;
      final client = entry.value;
      final response = await client.sendToolList();
      final tools = (response.toJson()['result']['tools'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      result[clientName] = tools;
    }

    if (result.isEmpty) {
      result = {};
    }

    return result;
  }

  Future<void> init() async {
    try {
      // 先确保配置文件存在
      await _initConfigFile();

      final configFilePath = await _configFilePath;
      Logger.root.info('mcp_server path: $configFilePath');

      // 添加配置文件内容日志
      final configFile = File(configFilePath);
      final configContent = await configFile.readAsString();
      Logger.root.info('配置文件内容: $configContent');

      _servers = await initializeAllMcpServers(configFilePath);
      Logger.root.info('mcp_server count: ${_servers.length}');
      for (var entry in _servers.entries) {
        addClient(entry.key, entry.value);
      }
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.root.severe('初始化 MCP 服务器失败: $e, stackTrace: $stackTrace');
      // 打印更详细的错误信息
      if (e is TypeError) {
        final configFile = File(await _configFilePath);
        final content = await configFile.readAsString();
        Logger.root.severe('配置文件解析错误，当前配置内容: $content');
      }
    }
  }

  String mcpServerMarket =
      "https://gh-proxy.com/raw.githubusercontent.com/daodao97/chatmcp/refs/heads/main/assets/mcp_server_market.json";

  Future<Map<String, dynamic>> loadMarketServers() async {
    try {
      final dio = Dio();
      final response = await dio.get(mcpServerMarket);
      if (response.statusCode == 200) {
        Logger.root.info('加载市场服务器成功: ${response.data}');
        final Map<String, dynamic> jsonData = json.decode(response.data);
        return jsonData;
      }
      throw Exception('加载市场服务器失败: ${response.statusCode}');
    } catch (e, stackTrace) {
      Logger.root.severe('加载市场服务器失败: $e, stackTrace: $stackTrace');
      throw Exception('加载市场服务器失败: $e');
    }
  }
}
