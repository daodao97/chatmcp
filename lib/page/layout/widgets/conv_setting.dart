import 'package:chatmcp/utils/color.dart';
import 'package:chatmcp/widgets/ink_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:chatmcp/provider/mcp_server_provider.dart';
import 'package:chatmcp/provider/serve_state_provider.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:chatmcp/provider/settings_provider.dart';
import 'package:chatmcp/generated/app_localizations.dart';
import 'package:chatmcp/components/widgets/custom_popup.dart';
import 'dart:async';

class ConvSetting extends StatefulWidget {
  const ConvSetting({super.key});

  @override
  State<ConvSetting> createState() => _ConvSettingState();
}

class _ConvSettingState extends State<ConvSetting> {
  List<String>? _cachedServers;
  bool _isLoading = true;
  String? _error;

  // server state provider
  final ServerStateProvider _stateProvider = ServerStateProvider();

  // add TextEditingController as state variable
  late TextEditingController _maxMessagesController;
  late TextEditingController _maxLoopsController;

  // debounce timer
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadServers();
    // initialize controllers
    _maxMessagesController = TextEditingController();
    _maxLoopsController = TextEditingController();

    // set initial values in the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
        final generalSetting = settingsProvider.generalSetting;
        _maxMessagesController.text = generalSetting.maxMessages.toString();
        _maxLoopsController.text = generalSetting.maxLoops.toString();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // listen to provider changes and reload server list
    final provider = Provider.of<McpServerProvider>(context);
    if (provider.loadingServerTools == false) {
      _loadServers();
    }

    // update controllers only when initialized or values really changed
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final generalSetting = settingsProvider.generalSetting;

    // use WidgetsBinding.instance.addPostFrameCallback to avoid modifying state in the build process
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentMaxMessages = generalSetting.maxMessages.toString();
        final currentMaxLoops = generalSetting.maxLoops.toString();

        if (_maxMessagesController.text != currentMaxMessages) {
          _maxMessagesController.text = currentMaxMessages;
        }
        if (_maxLoopsController.text != currentMaxLoops) {
          _maxLoopsController.text = currentMaxLoops;
        }
      }
    });
  }

  @override
  void dispose() {
    // release controllers
    _maxMessagesController.dispose();
    _maxLoopsController.dispose();
    // cancel debounce timer
    _debounceTimer?.cancel();
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

  // handle server status switch
  Future<void> _handleServerToggle(BuildContext context, String serverName, bool newValue) async {
    final provider = Provider.of<McpServerProvider>(context, listen: false);

    // update enabled state
    _stateProvider.setEnabled(serverName, newValue);

    // update state in Provider
    provider.toggleToolCategory(serverName, newValue);

    // if new state is true and server is not running, start server
    if (newValue && !provider.mcpServerIsRunning(serverName)) {
      _stateProvider.setStarting(serverName, true);

      try {
        await provider.startMcpServer(serverName);
        // update running state
        _stateProvider.setRunning(serverName, true);
      } catch (e) {
        // update state if server start failed
        _stateProvider.setRunning(serverName, false);
        _stateProvider.setStarting(serverName, false);
      }
    }
  }

  // debounce update settings
  void _debouncedUpdateSettings(String field, int value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
        if (field == 'maxMessages') {
          settingsProvider.updateGeneralSettingsPartially(maxMessages: value);
        } else if (field == 'maxLoops') {
          settingsProvider.updateGeneralSettingsPartially(maxLoops: value);
        }
      }
    });
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

        return BasePopup(
          showArrow: true,
          maxWidth: 400,
          padding: EdgeInsets.zero,
          content: _isLoading
              ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
              : _error != null
              ? Center(child: Text(_error!, style: Theme.of(context).textTheme.bodyMedium))
              : Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [_buildSettingsSection(context)]),
                  ),
                ),
          child: Consumer<ServerStateProvider>(
            builder: (context, stateProvider, _) {
              final l10n = AppLocalizations.of(context)!;
              return InkIcon(icon: CupertinoIcons.gear, tooltip: l10n.settings);
            },
          ),
        );
      },
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.conversationSettings, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Max Messages settings
              Row(
                children: [
                  Expanded(child: Text(l10n.maxMessages, style: Theme.of(context).textTheme.bodyMedium)),
                  Container(
                    width: 120,
                    height: 36,
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.outline.withAlpha(77)),
                      borderRadius: BorderRadius.circular(6),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: Row(
                      children: [
                        // decrease button
                        SizedBox(
                          width: 32,
                          height: 36,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), bottomLeft: Radius.circular(6)),
                              hoverColor: AppColors.getInkIconHoverColor(context),
                              onTap: () {
                                final currentValue = int.tryParse(_maxMessagesController.text) ?? 50;
                                if (currentValue > 1) {
                                  final newValue = currentValue - 1;
                                  _maxMessagesController.text = newValue.toString();
                                  _debouncedUpdateSettings('maxMessages', newValue);
                                }
                              },
                              child: Icon(
                                Icons.remove,
                                size: 16,
                                color: AppColors.getThemeColor(context, lightColor: Colors.grey[600], darkColor: Colors.grey[400]),
                              ),
                            ),
                          ),
                        ),
                        // separator
                        Container(width: 1, height: 20, color: Theme.of(context).colorScheme.outline.withAlpha(51)),
                        // number input
                        Expanded(
                          child: TextField(
                            controller: _maxMessagesController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: AppColors.getThemeTextColor(context)),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                              isDense: true,
                            ),
                            onChanged: (value) {
                              final intValue = int.tryParse(value);
                              if (intValue != null && intValue > 0 && intValue <= 1000) {
                                _debouncedUpdateSettings('maxMessages', intValue);
                              }
                            },
                          ),
                        ),
                        // separator
                        Container(width: 1, height: 20, color: Theme.of(context).colorScheme.outline.withAlpha(51)),
                        // increase button
                        SizedBox(
                          width: 32,
                          height: 36,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: const BorderRadius.only(topRight: Radius.circular(6), bottomRight: Radius.circular(6)),
                              hoverColor: AppColors.getInkIconHoverColor(context),
                              onTap: () {
                                final currentValue = int.tryParse(_maxMessagesController.text) ?? 50;
                                if (currentValue < 1000) {
                                  final newValue = currentValue + 1;
                                  _maxMessagesController.text = newValue.toString();
                                  _debouncedUpdateSettings('maxMessages', newValue);
                                }
                              },
                              child: Icon(
                                Icons.add,
                                size: 16,
                                color: AppColors.getThemeColor(context, lightColor: Colors.grey[600], darkColor: Colors.grey[400]),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.maxMessagesDescription,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(128)),
              ),

              const SizedBox(height: 16),

              // Max Loops settings
              Row(
                children: [
                  Expanded(child: Text(l10n.maxLoops, style: Theme.of(context).textTheme.bodyMedium)),
                  Container(
                    width: 120,
                    height: 36,
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.outline.withAlpha(77)),
                      borderRadius: BorderRadius.circular(6),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: Row(
                      children: [
                        // decrease button
                        SizedBox(
                          width: 32,
                          height: 36,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), bottomLeft: Radius.circular(6)),
                              hoverColor: AppColors.getInkIconHoverColor(context),
                              onTap: () {
                                final currentValue = int.tryParse(_maxLoopsController.text) ?? 100;
                                if (currentValue > 1) {
                                  final newValue = currentValue - 1;
                                  _maxLoopsController.text = newValue.toString();
                                  _debouncedUpdateSettings('maxLoops', newValue);
                                }
                              },
                              child: Icon(
                                Icons.remove,
                                size: 16,
                                color: AppColors.getThemeColor(context, lightColor: Colors.grey[600], darkColor: Colors.grey[400]),
                              ),
                            ),
                          ),
                        ),
                        // separator
                        Container(width: 1, height: 20, color: Theme.of(context).colorScheme.outline.withAlpha(51)),
                        // number input
                        Expanded(
                          child: TextField(
                            controller: _maxLoopsController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: AppColors.getThemeTextColor(context)),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                              isDense: true,
                            ),
                            onChanged: (value) {
                              final intValue = int.tryParse(value);
                              if (intValue != null && intValue > 0 && intValue <= 1000) {
                                _debouncedUpdateSettings('maxLoops', intValue);
                              }
                            },
                          ),
                        ),
                        // separator
                        Container(width: 1, height: 20, color: Theme.of(context).colorScheme.outline.withAlpha(51)),
                        // increase button
                        SizedBox(
                          width: 32,
                          height: 36,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: const BorderRadius.only(topRight: Radius.circular(6), bottomRight: Radius.circular(6)),
                              hoverColor: AppColors.getInkIconHoverColor(context),
                              onTap: () {
                                final currentValue = int.tryParse(_maxLoopsController.text) ?? 100;
                                if (currentValue < 1000) {
                                  final newValue = currentValue + 1;
                                  _maxLoopsController.text = newValue.toString();
                                  _debouncedUpdateSettings('maxLoops', newValue);
                                }
                              },
                              child: Icon(
                                Icons.add,
                                size: 16,
                                color: AppColors.getThemeColor(context, lightColor: Colors.grey[600], darkColor: Colors.grey[400]),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.maxLoopsDescription,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(128)),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final McpServerProvider provider = Provider.of<McpServerProvider>(context, listen: false);
    final List<Widget> menuItems = [];

    // handle loading state
    if (_isLoading) {
      return [
        const SizedBox(
          height: 40,
          child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
        ),
      ];
    }

    // handle error state
    if (_error != null) {
      return [
        SizedBox(
          height: 40,
          child: Center(child: Text(AppLocalizations.of(context)!.loadFailed(_error!), style: Theme.of(context).textTheme.bodyMedium)),
        ),
      ];
    }

    // handle no data state
    if (_cachedServers == null || _cachedServers!.isEmpty) {
      return [];
    }

    // add server title
    menuItems.add(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(l10n.mcpServers, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      ),
    );

    // use cached server list to build menu items
    for (String serverName in _cachedServers!) {
      // add separator
      if (menuItems.length > 1) {
        menuItems.add(const Divider(height: 1));
      }

      // use normal Container instead of CustomPopupMenuWidget
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

                // get server tool count
                List<Map<String, dynamic>>? serverTools = provider.tools[serverName];
                int toolCount = serverTools?.length ?? 0;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: Text(serverName, overflow: TextOverflow.ellipsis, maxLines: 1)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: isRunning ? Colors.green : Colors.grey, shape: BoxShape.circle),
                          ),
                        ),
                        if (isEnabled && isRunning && toolCount > 0)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.green.withAlpha(51), borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              '$toolCount tools',
                              style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
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
                          activeColor: AppColors.getThemeColor(context, lightColor: Colors.blue, darkColor: Colors.blue.shade700),
                          inactiveColor: AppColors.getThemeColor(context, lightColor: Colors.grey[300]!, darkColor: Colors.grey[600]!),
                          activeToggleColor: AppColors.getThemeColor(context, lightColor: Colors.white, darkColor: Colors.white),
                          inactiveToggleColor: AppColors.getThemeColor(context, lightColor: Colors.blue, darkColor: Colors.blue.shade300),
                          showOnOff: true,
                          activeText: "ON",
                          inactiveText: "OFF",
                          valueFontSize: 10.0,
                          activeTextColor: AppColors.getThemeColor(context, lightColor: Colors.white, darkColor: Colors.white),
                          inactiveTextColor: AppColors.getThemeColor(context, lightColor: Colors.black, darkColor: Colors.white),
                          activeIcon: isStarting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)),
                                )
                              : isRunning
                              ? const Icon(Icons.check_circle, size: 16, color: Colors.green)
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
