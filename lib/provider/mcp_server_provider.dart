import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../mcp/mcp.dart';
import 'package:logging/logging.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:chatmcp/utils/platform.dart';
import '../mcp/client/mcp_client_interface.dart';

var defaultInMemoryServers = [
  {
    'name': 'Math',
    'type': 'inmemory',
    'command': 'math',
    'env': {},
    'args': [],
    'tools': [],
  },
  {
    'name': 'Artifact Instructions',
    'type': 'inmemory',
    'command': 'artifact_instructions',
    'env': {},
    'args': [],
    'tools': [],
  },
];

class McpServerProvider extends ChangeNotifier {
  static final McpServerProvider _instance = McpServerProvider._internal();
  factory McpServerProvider() => _instance;
  McpServerProvider._internal() {
    init();
  }

  static const _configFileName = 'mcp_server.json';

  final Map<String, McpClient> _servers = {};

  Map<String, McpClient> get clients => _servers;

  // Check if current platform supports MCP Server
  bool get isSupported {
    return !Platform.isIOS && !Platform.isAndroid;
  }

  // Get configuration file path
  Future<String> get _configFilePath async {
    final directory = await getAppDir('ChatMcp');
    return '${directory.path}/$_configFileName';
  }

  // Check and create initial configuration file
  Future<void> _initConfigFile() async {
    final file = File(await _configFilePath);

    if (!await file.exists()) {
      // Load default configuration from assets
      final defaultConfig =
          await rootBundle.loadString('assets/mcp_server.json');
      // Write default configuration to file
      await file.writeAsString(defaultConfig);
      Logger.root.info('Default configuration file initialized from assets');
    }
  }

  // get installed servers count
  Future<int> get installedServersCount async {
    final allServerConfig = await _loadServers();
    final serverConfig = allServerConfig['mcpServers'] as Map<String, dynamic>;
    return serverConfig.length;
  }

  // Read server configuration
  Future<Map<String, dynamic>> _loadServers() async {
    File? file; // Make file nullable or assign later
    try {
      await _initConfigFile();
      final configPath = await _configFilePath;
      file = File(configPath); // Assign file here
      final String contents = await file.readAsString();

      // Check if contents are empty before attempting to decode
      if (contents.trim().isEmpty) {
        Logger.root.warning(
            'Configuration file ($configPath) is empty. Returning default configuration.');
        return {
          'mcpServers': <String, dynamic>{},
          'mcpServerMarket': <dynamic>[],
        };
      }

      final Map<String, dynamic> data = json.decode(contents);
      if (data['mcpServers'] == null) {
        data['mcpServers'] = <String, dynamic>{};
      }
      if (data['mcpServerMarket'] == null) {
        data['mcpServerMarket'] = <dynamic>[];
      }
      // 遍历data['mcpServers']，直接设置installed为true，
      for (var server in data['mcpServers'].entries) {
        server.value['installed'] = true;
      }
      return data;
    } on FormatException catch (e, stackTrace) {
      // Catch specific exception
      final configPath = await _configFilePath;
      Logger.root.severe(
          'Failed to parse configuration file ($configPath): $e, stackTrace: $stackTrace');
      // Log the problematic content if possible and file is not null
      if (file != null) {
        try {
          final String errorContents = await file
              .readAsString(); // Read again or use already read contents if file was assigned earlier
          Logger.root.severe(
              'Problematic configuration file content: "$errorContents"');
        } catch (readError) {
          Logger.root.severe(
              'Could not read configuration file content after format error: $readError');
        }
      }
      return {
        'mcpServers': <String, dynamic>{},
        'mcpServerMarket': <dynamic>[],
      }; // Return default on format error
    } catch (e, stackTrace) {
      // Catch other potential errors
      final configPath = await _configFilePath;
      Logger.root.severe(
          'Failed to read configuration file ($configPath): $e, stackTrace: $stackTrace');
      return {
        'mcpServers': <String, dynamic>{},
        'mcpServerMarket': <dynamic>[],
      };
    }
  }

  Future<Map<String, dynamic>> loadServersAll() async {
    final allServerConfig = await _loadServers();
    return allServerConfig;
  }

  Future<Map<String, dynamic>> loadServers() async {
    final allServerConfig = await _loadServers();
    final serverConfig = allServerConfig['mcpServers'] as Map<String, dynamic>;
    final servers = Map.fromEntries(serverConfig.entries
        .where((entry) => entry.value['type'] != 'inmemory'));
    return {
      'mcpServers': servers,
    };
  }

  Future<Map<String, dynamic>> loadInMemoryServers() async {
    final allServerConfig = await _loadServers();
    final serverConfig = allServerConfig['mcpServers'] as Map<String, dynamic>;

    // 检查默认内存服务器是否已存在，如不存在则添加
    bool needSave = false;
    for (var server in defaultInMemoryServers) {
      if (!serverConfig.containsKey(server['name'])) {
        serverConfig[server['name'] as String] = server;
        needSave = true;
      }
    }

    // 如果有新增服务器，保存配置
    if (needSave) {
      // 保留原有的 mcpServerMarket 字段
      final configToSave = {
        'mcpServers': serverConfig,
        'mcpServerMarket': allServerConfig['mcpServerMarket'],
      };
      await saveServers(configToSave);
    }

    // 过滤得到所有内存类型服务器
    final servers = Map.fromEntries(serverConfig.entries
        .where((entry) => entry.value['type'] == 'inmemory'));

    return {
      'mcpServers': servers,
    };
  }

  Future<void> addMcpServer(Map<String, dynamic> server) async {
    final allServerConfig = await _loadServers();
    // 创建一个新的Map，先放入新元素，再放入旧元素
    final newServers = <String, dynamic>{};
    newServers[server['name']] = server;
    // 添加原有的服务器配置
    newServers.addAll(allServerConfig['mcpServers'] as Map<String, dynamic>);
    // 更新配置
    allServerConfig['mcpServers'] = newServers;
    await saveServers(allServerConfig);
    notifyListeners();
  }

  Future<void> removeMcpServer(String serverName) async {
    final allServerConfig = await _loadServers();
    allServerConfig['mcpServers'].remove(serverName);
    await saveServers(allServerConfig);
    notifyListeners();
  }

  // Save server configuration
  Future<void> saveServers(Map<String, dynamic> servers) async {
    try {
      final file = File(await _configFilePath);
      final prettyContents =
          const JsonEncoder.withIndent('  ').convert(servers);
      await file.writeAsString(prettyContents);
      // Reinitialize clients after saving
      await _reinitializeClients();
    } catch (e, stackTrace) {
      Logger.root.severe(
          'Failed to save configuration file: $e, stackTrace: $stackTrace');
    }
  }

  // Reinitialize clients
  Future<void> _reinitializeClients() async {
    // _servers.clear();
    await init();
    notifyListeners();
  }

  void addClient(String key, McpClient client) {
    _servers[key] = client;
    notifyListeners();
  }

  void removeClient(String key) {
    _servers.remove(key);
    notifyListeners();
  }

  McpClient? getClient(String key) {
    return _servers[key];
  }

  final Map<String, List<Map<String, dynamic>>> _tools = {};
  Map<String, List<Map<String, dynamic>>> get tools {
    return _tools;
  }

  // 存储工具类别的启用状态
  final Map<String, bool> _toolCategoryEnabled = {};
  Map<String, bool> get toolCategoryEnabled => _toolCategoryEnabled;

  // 切换工具类别的启用状态
  void toggleToolCategory(String category, bool enabled) {
    _toolCategoryEnabled[category] = enabled;
    notifyListeners();
  }

  // 获取工具类别的启用状态，默认为启用
  bool isToolCategoryEnabled(String category) {
    return _toolCategoryEnabled[category] ?? false;
  }

  bool loadingServerTools = false;

  Future<List<Map<String, dynamic>>> getServerTools(
      String serverName, McpClient client) async {
    final tools = <Map<String, dynamic>>[];
    final response = await client.sendToolList();
    final toolsList = response.toJson()['result']['tools'] as List<dynamic>;
    tools.addAll(toolsList.cast<Map<String, dynamic>>());
    return tools;
  }

  Future<void> init() async {
    try {
      // Ensure configuration file exists
      await _initConfigFile();

      // // add default inmemory servers
      // final allServerConfig = await _loadServers();
      // final serverConfig =
      //     allServerConfig['mcpServers'] as Map<String, dynamic>;
      // for (var server in defaultInMemoryServers) {
      //   if (!serverConfig.containsKey(server['name'])) {
      //     serverConfig[server['name']!] = server;
      //   }
      // }
      // await saveServers({'mcpServers': serverConfig});

      final configFilePath = await _configFilePath;
      Logger.root.info('mcp_server path: $configFilePath');

      // Add configuration file content log
      final configFile = File(configFilePath);
      final configContent = await configFile.readAsString();
      Logger.root.info('mcp_server config: $configContent');

      final ignoreServers = <String>[];
      for (var entry in clients.entries) {
        ignoreServers.add(entry.key);
      }

      Logger.root.info('mcp_server ignoreServers: $ignoreServers');

      // _servers = await initializeAllMcpServers(configFilePath, ignoreServers);
      // Logger.root.info('mcp_server count: ${_servers.length}');
      // for (var entry in _servers.entries) {
      //   addClient(entry.key, entry.value);
      // }

      notifyListeners();
    } catch (e, stackTrace) {
      Logger.root.severe(
          'Failed to initialize MCP servers: $e, stackTrace: $stackTrace');
      // Print more detailed error information
      if (e is TypeError) {
        final configFile = File(await _configFilePath);
        final content = await configFile.readAsString();
        Logger.root.severe(
            'Configuration file parsing error, current content: $content');
      }
    }
  }

  Future<int> get mcpServerCount async {
    final allServerConfig = await _loadServers();
    final serverConfig = allServerConfig['mcpServers'] as Map<String, dynamic>;
    return serverConfig.length;
  }

  Future<List<String>> get mcpServers async {
    final allServerConfig = await _loadServers();
    final serverConfig = allServerConfig['mcpServers'] as Map<String, dynamic>;
    return serverConfig.keys.toList();
  }

  bool mcpServerIsRunning(String serverName) {
    final client = clients[serverName];
    return client != null;
  }

  Future<void> stopMcpServer(String serverName) async {
    final client = clients[serverName];
    if (client != null) {
      await client.dispose();
      clients.remove(serverName);
      notifyListeners();
    }
  }

  Future<McpClient?> startMcpServer(String serverName) async {
    final allServerConfig = await _loadServers();
    final serverConfig = allServerConfig['mcpServers'][serverName];
    final client = await initializeMcpServer(serverConfig);
    if (client != null) {
      clients[serverName] = client;
      loadingServerTools = true;
      notifyListeners();
      final tools = await getServerTools(serverName, client);
      _tools[serverName] = tools;
      loadingServerTools = false;
      notifyListeners();
    }
    return client;
  }

  Future<Map<String, McpClient>> initializeAllMcpServers(
      String configPath, List<String> ignoreServers) async {
    final file = File(configPath);
    final contents = await file.readAsString();

    final Map<String, dynamic> config =
        json.decode(contents) as Map<String, dynamic>? ?? {};

    final mcpServers = config['mcpServers'] as Map<String, dynamic>;

    final Map<String, McpClient> clients = {};

    for (var entry in mcpServers.entries) {
      if (ignoreServers.contains(entry.key)) {
        continue;
      }

      final serverName = entry.key;
      final serverConfig = entry.value as Map<String, dynamic>;

      try {
        // Create async task and add to list
        final client = await initializeMcpServer(serverConfig);
        if (client != null) {
          clients[serverName] = client;
          loadingServerTools = true;
          notifyListeners();
          final tools = await getServerTools(serverName, client);
          _tools[serverName] = tools;
          loadingServerTools = false;
          notifyListeners();
        }
      } catch (e, stackTrace) {
        Logger.root.severe(
            'Failed to initialize MCP server: $serverName, $e, stackTrace: $stackTrace');
      }
    }

    return clients;
  }

  // 从mcpServerMarket中加载服务器
  Future<Map<String, dynamic>> loadMarketServers() async {
    try {
      final file = File(await _configFilePath);
      final String contents = await file.readAsString();
      final Map<String, dynamic> data = json.decode(contents);
      
      final List<dynamic>? marketConfigs = data['mcpServerMarket'] as List<dynamic>?;
      if (marketConfigs == null) {
        Logger.root.warning('No market configs found in config file');
        return {'mcpServers': <String, dynamic>{}};
      }

      final Map<String, dynamic> allServers = {};

      for (var marketConfig in marketConfigs) {
        try {
          if (marketConfig['type'] == 'local') {
            final Map<String, dynamic>? servers = marketConfig['mcpServers'] as Map<String, dynamic>?;
            if (servers != null) {
              allServers.addAll(servers);
            }
          } else if (marketConfig['type'] == 'remote') {
            final String? url = marketConfig['url'] as String?;
            if (url != null) {
              try {
                final Map<String, dynamic> servers = await loadMarketRemoteServers(url);
                allServers.addAll(servers);
              } catch (e) {
                Logger.root.warning('Failed to load remote servers from $url: $e');
              }
            }
          }
        } catch (e) {
          Logger.root.warning('Failed to process market config: $e');
          continue;
        }
      }

      // 获取本地已安装的mcp服务器
      final localInstalledServers = await _loadServers();
      final Map<String, dynamic> processedServers = {};
      
      // 创建新的Map来存储处理后的数据
      for (var server in allServers.entries) {
        final bool isInstalled = localInstalledServers['mcpServers']?[server.key] != null;
        processedServers[server.key] = {
          ...server.value,
          'installed': isInstalled,
        };
      }

      return {
        'mcpServers': processedServers,
      };
    } catch (e, stackTrace) {
      Logger.root.severe('Failed to load local market servers: $e, stackTrace: $stackTrace');
      return {
        'mcpServers': <String, dynamic>{},
      };
    }
  }

  Future<Map<String, dynamic>> loadMarketRemoteServers(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Logger.root
            .info('Successfully loaded market servers: ${response.body}');
        final Map<String, dynamic> jsonData = json.decode(response.body);

        final Map<String, dynamic> servers =
            jsonData['mcpServers'] as Map<String, dynamic>;

        var serverMap = <String, dynamic>{};

        // For mobile platforms, only keep servers with commands starting with http
        if (Platform.isIOS || Platform.isAndroid) {
          for (var server in servers.entries) {
            if (server.value['command'] != null &&
                server.value['command'].toString().startsWith('http')) {
              serverMap[server.key] = server.value;
            }
          }
        } else {
          serverMap = servers;
        }

        return serverMap;
      }
      // 打印日志不要直接报错
      Logger.root.severe('Failed to load remote market servers: ${response.statusCode}');
      return <String, dynamic>{};
    } catch (e, stackTrace) {
      Logger.root.severe('Failed to load remote market servers: $e, stackTrace: $stackTrace');
      return <String, dynamic>{};
    }
  }
}
