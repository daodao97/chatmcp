import 'package:chatmcp/components/widgets/base.dart';
import 'package:chatmcp/utils/color.dart';
import 'package:chatmcp/widgets/ink_icon.dart';
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

  // Server status provider
  final ServerStateProvider _stateProvider = ServerStateProvider();

  @override
  void initState() {
    super.initState();
    _loadServers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to provider changes and reload the server list
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
      final servers = await provider.loadServersAll();

      setState(() {
        _cachedServers = servers['mcpServers'].keys.toList();
        _isLoading = false;
      });

      _stateProvider.syncFromProvider(provider, _cachedServers!);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Handle server status switching
  Future<void> _handleServerToggle(
      BuildContext context, String serverName, bool newValue) async {
    final provider = Provider.of<McpServerProvider>(context, listen: false);

    // Update enabled status
    _stateProvider.setEnabled(serverName, newValue);

    // Update the status in the Provider
    provider.toggleToolCategory(serverName, newValue);

    // If the new status is true and the server is not running, start the server
    if (newValue && !provider.mcpServerIsRunning(serverName)) {
      // Set starting status
      _stateProvider.setStarting(serverName, true);

      try {
        await provider.startMcpServer(serverName);
        // Update running status
        _stateProvider.setRunning(serverName, true);
      } catch (e) {
        // Start failed, update status
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

        final backgroundColor = AppColors.getThemeColor(context,
            lightColor: Colors.white, darkColor: Colors.grey[800]);

        return CustomPopup(
          showArrow: true,
          arrowColor: backgroundColor,
          backgroundColor: backgroundColor,
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
                            child: Text('No available servers',
                                style: Theme.of(context).textTheme.bodyMedium),
                          )
                        : Container(
                            constraints: const BoxConstraints(
                              maxHeight: 400, // Limit the maximum height of the menu item list
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: _buildMenuItems(context),
                              ),
                            ),
                          ),
          ),
          child: Consumer<ServerStateProvider>(
            builder: (context, stateProvider, _) {
              return InkIcon(
                icon: CupertinoIcons.hammer,
                text: stateProvider.enabledCount > 0
                    ? ' ${stateProvider.enabledCount}'
                    : null,
              );
            },
          ),
        );
      },
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    final McpServerProvider provider =
        Provider.of<McpServerProvider>(context, listen: false);
    final List<Widget> menuItems = [];

    // Handle loading status
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

    // Handle error status
    if (_error != null) {
      return [
        SizedBox(
          height: 40,
          child: Center(
            child: Text('Load failed: $_error',
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        )
      ];
    }

    // Handle no data status
    if (_cachedServers == null || _cachedServers!.isEmpty) {
      return [
        SizedBox(
          height: 40,
          child: Center(
            child: Text('No available servers',
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        )
      ];
    }

    // Build menu items using the cached server list
    for (String serverName in _cachedServers!) {
      // Add a divider
      if (menuItems.isNotEmpty) {
        menuItems.add(const Divider(height: 1));
      }

      // Use a normal Container instead of CustomPopupMenuWidget
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

                // Get the number of server tools
                List<Map<String, dynamic>>? serverTools =
                    provider.tools[serverName];
                int toolCount = serverTools?.length ?? 0;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        serverName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isRunning ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        if (isEnabled && isRunning && toolCount > 0)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withAlpha(51),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$toolCount tools',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                          activeColor: AppColors.getThemeColor(context,
                              lightColor: Colors.blue,
                              darkColor: Colors.blue.shade700),
                          inactiveColor: AppColors.getThemeColor(context,
                              lightColor: Colors.grey[300]!,
                              darkColor: Colors.grey[600]!),
                          activeToggleColor: AppColors.getThemeColor(context,
                              lightColor: Colors.white,
                              darkColor: Colors.white),
                          inactiveToggleColor: AppColors.getThemeColor(context,
                              lightColor: Colors.blue,
                              darkColor: Colors.blue.shade300),
                          showOnOff: true,
                          activeText: "ON",
                          inactiveText: "OFF",
                          valueFontSize: 10.0,
                          activeTextColor: AppColors.getThemeColor(context,
                              lightColor: Colors.white,
                              darkColor: Colors.white),
                          inactiveTextColor: AppColors.getThemeColor(context,
                              lightColor: Colors.black,
                              darkColor: Colors.white),
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
