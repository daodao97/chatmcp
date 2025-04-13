import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatmcp/provider/mcp_server_provider.dart';
import 'package:chatmcp/provider/serve_state_provider.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_popup/flutter_popup.dart';

class McpTools extends StatefulWidget {
  const McpTools({super.key});

  @override
  State<McpTools> createState() => _McpToolsState();
}

class _McpToolsState extends State<McpTools> {
  List<String>? _cachedServers;
  bool _isLoading = true;
  String? _error;

  // 服务器状态提供者
  final ServerStateProvider _stateProvider = ServerStateProvider();

  @override
  void initState() {
    super.initState();
    _loadServers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 监听 provider 变化并重新加载服务器列表
    final provider = Provider.of<McpServerProvider>(context);
    if (provider.loadingServerTools == false) {
      _loadServers();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadServers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = Provider.of<McpServerProvider>(context, listen: false);
      final servers = await provider.mcpServers;

      setState(() {
        _cachedServers = servers;
        _isLoading = false;
      });

      _stateProvider.syncFromProvider(provider, servers);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // 处理服务器的状态切换
  Future<void> _handleServerToggle(
      BuildContext context, String serverName, bool newValue) async {
    final provider = Provider.of<McpServerProvider>(context, listen: false);

    // 更新启用状态
    _stateProvider.setEnabled(serverName, newValue);

    // 更新Provider中的状态
    provider.toggleToolCategory(serverName, newValue);

    // 如果新状态为true且服务器未运行，则启动服务器
    if (newValue && !provider.mcpServerIsRunning(serverName)) {
      // 设置启动中状态
      _stateProvider.setStarting(serverName, true);

      try {
        await provider.startMcpServer(serverName);
        // 更新运行状态
        _stateProvider.setRunning(serverName, true);
      } catch (e) {
        // 启动失败，更新状态
        _stateProvider.setRunning(serverName, false);
        _stateProvider.setStarting(serverName, false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<McpServerProvider>(
      builder: (context, mcpServerProvider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_cachedServers != null) {
            _stateProvider.syncFromProvider(mcpServerProvider, _cachedServers!);
          }
        });

        return CustomPopup(
          showArrow: true,
          arrowColor: Theme.of(context).popupMenuTheme.color ?? Colors.white,
          backgroundColor:
              Theme.of(context).popupMenuTheme.color ?? Colors.white,
          barrierColor: Colors.transparent,
          content: Container(
            constraints: BoxConstraints(
              maxWidth: 400,
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: _isLoading
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Text(_error!,
                            style: Theme.of(context).textTheme.bodyMedium),
                      )
                    : _cachedServers == null || _cachedServers!.isEmpty
                        ? Center(
                            child: Text('没有可用的服务器',
                                style: Theme.of(context).textTheme.bodyMedium),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: _buildMenuItems(context),
                            ),
                          ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<ServerStateProvider>(
                  builder: (context, stateProvider, _) {
                    return Text(
                        'MCP${stateProvider.enabledCount > 0 ? ': ${stateProvider.enabledCount}' : ''}');
                  },
                ),
                const SizedBox(width: 4),
                Icon(
                  mcpServerProvider.loadingServerTools
                      ? CupertinoIcons.clock
                      : Icons.expand_more,
                  size: 18,
                  color: Theme.of(context).iconTheme.color,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    final McpServerProvider provider =
        Provider.of<McpServerProvider>(context, listen: false);
    final List<Widget> menuItems = [];

    // 处理加载状态
    if (_isLoading) {
      return [
        const SizedBox(
          height: 40,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        )
      ];
    }

    // 处理错误状态
    if (_error != null) {
      return [
        SizedBox(
          height: 40,
          child: Center(
            child: Text('加载出错: $_error',
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        )
      ];
    }

    // 处理无数据状态
    if (_cachedServers == null || _cachedServers!.isEmpty) {
      return [
        SizedBox(
          height: 40,
          child: Center(
            child:
                Text('没有可用的服务器', style: Theme.of(context).textTheme.bodyMedium),
          ),
        )
      ];
    }

    // 使用缓存的服务器列表构建菜单项
    for (String serverName in _cachedServers!) {
      // 添加分隔线
      if (menuItems.isNotEmpty) {
        menuItems.add(const Divider(height: 1));
      }

      // 使用普通的 Container 替代 CustomPopupMenuWidget
      menuItems.add(
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ChangeNotifierProvider.value(
            value: _stateProvider,
            child: Consumer<ServerStateProvider>(
              builder: (context, stateProvider, _) {
                bool isEnabled = stateProvider.isEnabled(serverName);
                bool isRunning = stateProvider.isRunning(serverName);
                bool isStarting = stateProvider.isStarting(serverName);

                // 获取服务器工具数量
                List<Map<String, dynamic>>? serverTools =
                    provider.tools[serverName];
                int toolCount = serverTools?.length ?? 0;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(serverName),
                        if (isEnabled && isRunning && toolCount > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$toolCount',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    FlutterSwitch(
                      width: 55.0,
                      height: 25.0,
                      value: isEnabled,
                      onToggle: (val) {
                        if (!isStarting) {
                          _handleServerToggle(context, serverName, val);
                        }
                      },
                      toggleSize: 20.0,
                      activeColor: Colors.blue,
                      inactiveColor: Colors.grey[300]!,
                      activeToggleColor: Colors.white,
                      inactiveToggleColor: Colors.blue,
                      showOnOff: true,
                      activeText: "ON",
                      inactiveText: "OFF",
                      valueFontSize: 10.0,
                      activeTextColor: Colors.white,
                      inactiveTextColor: Colors.black,
                      activeIcon: isStarting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.orange),
                              ),
                            )
                          : isRunning
                              ? const Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: Colors.green,
                                )
                              : null,
                      disabled: isStarting,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    }

    return menuItems;
  }
}
