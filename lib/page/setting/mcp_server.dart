import 'dart:async';

import 'package:chatmcp/components/widgets/base.dart';
import 'package:chatmcp/page/setting/mcp_info.dart';
import 'package:chatmcp/provider/provider_manager.dart';
import 'package:chatmcp/utils/platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../provider/mcp_server_provider.dart';
import 'package:logging/logging.dart';
import 'package:chatmcp/utils/process.dart';
import 'package:chatmcp/generated/app_localizations.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:chatmcp/utils/oauth_discovery.dart';

class McpServer extends StatefulWidget {
  const McpServer({super.key});

  @override
  State<McpServer> createState() => _McpServerState();
}

class _McpServerState extends State<McpServer> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTab = 'installed'; // 使用固定的英文标识符
  int _refreshCounter = 0;
  final Map<String, bool> _serverLoading = {};
  
  // OAuth auto-discovery state
  OAuthDiscoveryResult? _oauthDiscovery;
  bool _isCheckingOAuth = false;

  // 标签映射：内部标识符 -> 显示文本
  Map<String, String> _getTabLabels(AppLocalizations l10n) {
    return {'all': l10n.all, 'installed': l10n.installed, 'inmemory': 'inmemory'};
  }

  // 验证URL是否合法
  bool isValidUrl(String urlString) {
    try {
      final uri = Uri.parse(urlString);
      return uri.scheme.isNotEmpty && uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Check OAuth requirement for URL
  Future<void> _checkOAuthRequirement(String url) async {
    if (!kIsWeb || !isValidUrl(url)) return;
    
    setState(() {
      _isCheckingOAuth = true;
    });
    
    try {
      final provider = Provider.of<McpServerProvider>(context, listen: false);
      final result = await provider.discoverOAuthForServer(url);
      
      setState(() {
        _oauthDiscovery = result;
        _isCheckingOAuth = false;
      });
    } catch (e) {
      Logger.root.warning('OAuth discovery failed: $e');
      setState(() {
        _oauthDiscovery = null;
        _isCheckingOAuth = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Consumer<McpServerProvider>(
          builder: (context, provider, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // 搜索框
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(26)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: l10n.searchServer,
                        prefixIcon: Icon(CupertinoIcons.search, color: Theme.of(context).colorScheme.onSurface.withAlpha(153)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 标签选择和操作按钮
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // 在宽屏设备上使用Row实现两边对齐
                      if (constraints.maxWidth > 500) {
                        // 设定一个合理的宽度阈值
                        return Row(
                          children: [
                            Wrap(
                              spacing: 12,
                              children: [
                                _buildFilterChip('all', l10n.all),
                                _buildFilterChip('installed', l10n.installed),
                                _buildFilterChip('inmemory', l10n.inmemory),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildActionButton(
                                  icon: CupertinoIcons.add,
                                  tooltip: l10n.addMcpServer,
                                  onPressed: () {
                                    final provider = ProviderManager.mcpServerProvider;
                                    _showEditDialog(context, '', provider, null);
                                  },
                                ),
                                const SizedBox(width: 8),
                                _buildActionButton(icon: CupertinoIcons.refresh, tooltip: l10n.refresh, onPressed: () => setState(() {})),
                              ],
                            ),
                          ],
                        );
                      } else {
                        // 在窄屏设备上继续使用Wrap自动换行
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 12,
                                  children: [
                                    _buildFilterChip('all', l10n.all),
                                    _buildFilterChip('installed', l10n.installed),
                                    _buildFilterChip('inmemory', l10n.inmemory),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _buildActionButton(
                                  icon: CupertinoIcons.add,
                                  tooltip: l10n.addMcpServer,
                                  onPressed: () {
                                    final provider = ProviderManager.mcpServerProvider;
                                    _showEditDialog(context, '', provider, null);
                                  },
                                ),
                                const SizedBox(width: 8),
                                _buildActionButton(icon: CupertinoIcons.refresh, tooltip: l10n.refresh, onPressed: () => setState(() {})),
                              ],
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // 服务器列表
                  Expanded(
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: (_selectedTab == 'all'
                          ? provider.loadMarketServers()
                          : _selectedTab == 'inmemory'
                          ? provider.loadInMemoryServers()
                          : provider.loadServers()),
                      key: ValueKey('server_list_$_refreshCounter'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CupertinoActivityIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.exclamationmark_circle, size: 48, color: Theme.of(context).colorScheme.error),
                                const SizedBox(height: 16),
                                Text('Failed to load: ${snapshot.error}', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                              ],
                            ),
                          );
                        }

                        if (snapshot.hasData) {
                          final servers = snapshot.data?['mcpServers'] as Map<String, dynamic>? ?? {};

                          if (servers.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(CupertinoIcons.desktopcomputer, size: 64, color: Theme.of(context).colorScheme.onSurface.withAlpha(153)),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n.noServerConfigs,
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(153), fontSize: 16),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: servers.length,
                            itemBuilder: (context, index) {
                              final serverName = servers.keys.elementAt(index);
                              final serverConfig = servers[serverName];

                              return _buildServerCard(context, serverName, serverConfig, provider, serverConfig['installed'] ?? false);
                            },
                          );
                        }
                        return const Center(child: CupertinoActivityIndicator());
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  bool isActive(String serverName) {
    final provider = ProviderManager.mcpServerProvider.clients;
    for (var client in provider.entries) {
      if (client.key == serverName) {
        return true;
      }
    }
    return false;
  }

  Widget _buildServerCard(BuildContext context, String serverName, dynamic serverConfig, McpServerProvider provider, bool installed) {
    final l10n = AppLocalizations.of(context)!;
    bool serverActive = isActive(serverName);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(26)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(serverActive ? CupertinoIcons.checkmark : CupertinoIcons.desktopcomputer, color: Theme.of(context).colorScheme.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Text(
                    serverName,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (serverConfig['type'] != null) ...[
                    const Gap(size: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withAlpha(80),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).colorScheme.primary.withAlpha(30), width: 1),
                      ),
                      child: Text(
                        (serverConfig['type'] ?? '').toString().toLowerCase(),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface.withAlpha(180)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (installed) ...[
              // OAuth authentication button (web only)
              if (kIsWeb) ...[
                FutureBuilder<Map<String, dynamic>>(
                  future: provider.getServerOAuthStatus(serverName),
                  builder: (context, snapshot) {
                    final oauthStatus = snapshot.data ?? {};
                    final oauthEnabled = oauthStatus['enabled'] == true;
                    final isAuthenticated = oauthStatus['authenticated'] == true;
                    final needsRefresh = oauthStatus['needs_refresh'] == true;
                    
                    if (!oauthEnabled) return const SizedBox.shrink();
                    
                    return _buildActionButton(
                      icon: isAuthenticated 
                        ? (needsRefresh ? CupertinoIcons.refresh : CupertinoIcons.checkmark_shield)
                        : CupertinoIcons.lock,
                      tooltip: isAuthenticated 
                        ? (needsRefresh ? 'Refresh OAuth Token' : 'OAuth Authenticated')
                        : 'Authenticate with OAuth',
                      onPressed: () async {
                        setState(() {
                          _serverLoading[serverName] = true;
                        });
                        try {
                          if (needsRefresh) {
                            await provider.refreshServerToken(serverName);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('OAuth token refreshed successfully')),
                            );
                          } else if (!isAuthenticated) {
                            await provider.authenticateServer(serverName);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('OAuth authentication successful')),
                            );
                          }
                          setState(() {
                            _refreshCounter++;
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('OAuth error: ${e.toString()}')),
                          );
                        } finally {
                          if (mounted) {
                            setState(() {
                              _serverLoading[serverName] = false;
                            });
                          }
                        }
                      },
                      isLoading: _serverLoading[serverName] == true,
                    );
                  },
                ),
                const Gap(size: 10),
              ],
              
              _buildActionButton(
                icon: provider.mcpServerIsRunning(serverName) ? CupertinoIcons.stop : CupertinoIcons.play,
                tooltip: provider.mcpServerIsRunning(serverName) ? l10n.stop : l10n.start,
                onPressed: () async {
                  if (provider.mcpServerIsRunning(serverName)) {
                    await provider.stopMcpServer(serverName);
                  } else {
                    setState(() {
                      _serverLoading[serverName] = true;
                    });
                    try {
                      await provider.startMcpServer(serverName);
                    } finally {
                      if (mounted) {
                        setState(() {
                          _serverLoading[serverName] = false;
                        });
                      }
                    }
                  }
                },
                isLoading: _serverLoading[serverName] == true,
              ),
              const Gap(size: 10),
              if (provider.mcpServerIsRunning(serverName))
                _buildActionButton(icon: CupertinoIcons.info_circle, tooltip: "info", onPressed: () => _showInfoDialog(context, serverName)),
              const Gap(size: 10),
              _buildActionButton(
                icon: CupertinoIcons.pencil,
                tooltip: l10n.edit,
                onPressed: () => _showEditDialog(context, serverName, provider, null),
              ),
              const Gap(size: 10),
              _buildActionButton(
                icon: CupertinoIcons.delete,
                tooltip: l10n.delete,
                color: Theme.of(context).colorScheme.error,
                onPressed: () => _showDeleteConfirmDialog(context, serverName, provider),
              ),
            ] else ...[
              ElevatedButton.icon(
                icon: Icon(CupertinoIcons.cloud_download, color: Theme.of(context).colorScheme.onPrimary),
                label: Text(l10n.install),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  final command = (serverConfig['command']?.toString() ?? '').trim();
                  final type = serverConfig['type']?.toString() ?? '';
                  // Remote (sse/streamable) market entries carry a URL in `command`;
                  // `which https://…` can never succeed, so validate the URL instead of PATH.
                  // Mirrors initializeMcpServer: explicit sse/streamable are remote, explicit
                  // stdio/inmemory are not, and only an unknown/empty type falls back to the command prefix.
                  final isRemote = type == 'sse' || type == 'streamable' || (type != 'stdio' && type != 'inmemory' && command.startsWith('http'));
                  if (isRemote) {
                    final uri = Uri.tryParse(command);
                    final isHttpUrl = uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
                    if (!isHttpUrl) {
                      showErrorDialog(context, 'Server command must be a valid http(s) URL');
                      return;
                    }
                  } else if (!await isCommandAvailable(command)) {
                    showErrorDialog(context, l10n.commandNotExist(serverConfig['command'], getPlatformPath() ?? ''));
                    return;
                  }
                  Logger.root.info('Install server configuration: $serverName ${serverConfig['command']} ${serverConfig['args']}');
                  await _showEditDialog(context, serverName, provider, serverConfig);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String serverName) {
    if (kIsMobile) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            body: SafeArea(child: McpInfo(serverName: serverName)),
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              child: McpInfo(serverName: serverName),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    Color? color,
    bool isLoading = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isLoading ? null : onPressed,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color ?? Theme.of(context).colorScheme.primary.withAlpha(51)),
            ),
            child: isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: color ?? Theme.of(context).colorScheme.primary),
                  )
                : Icon(icon, size: 18, color: color ?? Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String tabKey, String displayLabel) {
    final isSelected = _selectedTab == tabKey;
    return FilterChip(
      label: Text(
        displayLabel,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTab = tabKey;
        });
      },
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primary.withAlpha(31),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline.withAlpha(26)),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, String serverName, McpServerProvider provider, Map<String, dynamic>? newServerConfig) async {
    if (!context.mounted) return;

    var config = await provider.loadServers();
    if (_selectedTab == 'inmemory') {
      config = await provider.loadInMemoryServers();
    }

    var servers = config['mcpServers'] ?? {};

    if (!context.mounted) return;

    final serverConfig =
        newServerConfig ??
        servers[serverName] as Map<String, dynamic>? ??
        {
          'type': 'sse', // streamable, sse, stdio, inmemory
          'command': '',
          'args': <String>[],
          'env': <String, String>{},
          'auto_approve': false,
        };

    String resultServerName = serverName;
    String resultType = serverConfig['type']?.toString() ?? '';
    String resultCommand = serverConfig['command']?.toString() ?? '';
    String resultArgs = (serverConfig['args'] as List<dynamic>?)?.map((e) => e.toString()).join(' ') ?? '';
    String resultEnv = (serverConfig['env'] as Map<String, dynamic>?)?.entries.map((e) => '${e.key}=${e.value}').join('\n') ?? '';
    bool autoApprove = serverConfig['auto_approve'] as bool? ?? false;

    final formKey = GlobalKey<FormBuilderState>();

    final isEdit = serverName.isNotEmpty;

    try {
      if (!context.mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context)!;
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            title: Text(
              serverName.isEmpty ? l10n.addMcpServer : serverName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            content: SingleChildScrollView(
              child: FormBuilder(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isEdit)
                      FormBuilderTextField(
                        name: 'serverName',
                        initialValue: resultServerName,
                        decoration: InputDecoration(
                          labelText: l10n.serverName,
                          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(102)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(51)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(51)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                          ),
                          prefixIcon: Icon(CupertinoIcons.command, color: Theme.of(context).colorScheme.primary, size: 20),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.fieldRequired;
                          }
                          if (value.length > 50) {
                            return l10n.serverNameTooLong;
                          }
                          return null;
                        },
                      ),
                    if (!isEdit) const SizedBox(height: 16),
                    FormBuilderDropdown<String>(
                      name: 'type',
                      initialValue: resultType,
                      enabled: _selectedTab != 'inmemory',
                      decoration: InputDecoration(
                        labelText: l10n.serverType,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(51)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(51)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
                        prefixIcon: Icon(CupertinoIcons.gear, color: Theme.of(context).colorScheme.primary, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: [
                        DropdownMenuItem(value: 'sse', child: Text('SSE')),
                        DropdownMenuItem(value: 'stdio', child: Text('STDIO')),
                        DropdownMenuItem(value: 'streamable', child: Text('Streamable')),
                        if (isEdit) DropdownMenuItem(value: 'inmemory', enabled: false, child: Text('InMemory')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.fieldRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'command',
                      enabled: resultType != 'inmemory',
                      initialValue: resultCommand,
                      decoration: InputDecoration(
                        labelText: l10n.command,
                        hintText: l10n.commandExample,
                        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(102)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(51)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(51)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
                        prefixIcon: Icon(CupertinoIcons.command, color: Theme.of(context).colorScheme.primary, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.fieldRequired;
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value != null && value.trim().isNotEmpty && value.startsWith('http')) {
                          _checkOAuthRequirement(value.trim());
                        }
                      },
                    ),
                    
                    // OAuth discovery status
                    if (_isCheckingOAuth) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const SizedBox(width: 40), // Align with field content
                          SizedBox(
                            width: 16, 
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Checking authentication requirements...',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ] else if (_oauthDiscovery?.requiresOAuth == true) ...[
                      const SizedBox(height: 8),
                      Container(
                        margin: const EdgeInsets.only(left: 40),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withAlpha(100),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withAlpha(100),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.security,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This server requires OAuth authentication. You\'ll be prompted to login after saving.',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'args',
                      initialValue: resultArgs,
                      decoration: InputDecoration(
                        labelText: l10n.arguments,
                        hintText: l10n.argumentsExample,
                        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(102)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(51)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(51)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
                        prefixIcon: Icon(CupertinoIcons.command, color: Theme.of(context).colorScheme.primary, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'env',
                      initialValue: resultEnv,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: l10n.environmentVariables,
                        hintText: l10n.envVarsFormat,
                        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(102)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(51)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(51)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
                        prefixIcon: Icon(CupertinoIcons.command, color: Theme.of(context).colorScheme.primary, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderCheckbox(
                      name: 'auto_approve',
                      initialValue: autoApprove,
                      title: Text(l10n.autoApprove, style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
                      decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero),
                    ),
                    const SizedBox(height: 16),
                    
                    // OAuth Auto-Discovery Information
                    if (kIsWeb) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withAlpha(100),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Authentication',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Authentication is now handled automatically. When you enter a server URL that requires authentication, you\'ll be prompted to login after saving.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface.withAlpha(200),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () async {
                  if (!formKey.currentState!.saveAndValidate()) {
                    return;
                  }

                  final values = formKey.currentState!.value;
                  final saveServerName = serverName.isEmpty ? (values['serverName'] as String).trim() : serverName;
                  final type = values['type'] as String;
                  final command = (values['command'] as String).trim();
                  final argsString = (values['args'] as String).trim();

                  // 改进的参数解析逻辑，支持引号包围的参数
                  List<String> args = [];
                  if (argsString.isNotEmpty) {
                    // 匹配单引号、双引号包围的参数，或者不包含空格的参数
                    RegExp regExp = RegExp(r'''"[^"]*"|'[^']*'|\S+''');
                    Iterable<RegExpMatch> matches = regExp.allMatches(argsString);
                    for (RegExpMatch match in matches) {
                      // 保留原始引号
                      args.add(match.group(0)!);
                    }
                  }

                  final envStr = values['env'] as String;

                  bool isRemote = type == 'sse' || type == 'streamable';
                  bool isUrl = isValidUrl(command.trim());

                  if (kIsMobile && kIsWeb) {
                    if (type == "stdio") {
                      showErrorDialog(dialogContext, 'Mobile only supports mcp sse and streamable servers');
                      return;
                    }
                    if (isRemote && !isUrl) {
                      showErrorDialog(dialogContext, 'Server command must be a valid URL');
                      return;
                    }
                  }

                  final env = Map<String, String>.fromEntries(
                    envStr.split('\n').where((line) => line.trim().isNotEmpty).map((line) {
                      final parts = line.split('=');
                      if (parts.length < 2) {
                        return MapEntry(parts[0].trim(), '');
                      }
                      return MapEntry(parts[0].trim(), parts.sublist(1).join('=').trim());
                    }),
                  );

                  if (config['mcpServers'] == null) {
                    config['mcpServers'] = <String, dynamic>{};
                  }

                  // Build server configuration
                  final serverConfigData = {
                    'name': saveServerName,
                    'type': type,
                    'command': command,
                    'args': args,
                    'env': env,
                    'auto_approve': values['auto_approve'] as bool? ?? false,
                  };

                  await provider.addMcpServer(serverConfigData);

                  if (mounted) {
                    setState(() {
                      _refreshCounter++;
                    });
                  }

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext, true);
                  }

                  // Handle auto-discovered OAuth authentication BEFORE starting server
                  if (_oauthDiscovery?.requiresOAuth == true && kIsWeb) {
                    if (mounted) {
                      // Always try automatic OAuth first
                      final shouldAuth = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Authentication Required'),
                          content: Text(
                            'This server requires OAuth authentication. Would you like to login now?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Later'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Login Now'),
                            ),
                          ],
                        ),
                      );

                      if (shouldAuth == true) {
                        try {
                          Logger.root.info('Starting OAuth authentication for $saveServerName');
                          
                          final success = await provider.autoAuthenticateServer(
                            saveServerName, 
                            _oauthDiscovery!
                          );
                          
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Authentication successful for $saveServerName'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Authentication failed: No success response'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        } catch (e) {
                          Logger.root.severe('OAuth authentication error: $e');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Authentication failed: ${e.toString()}'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          }
                        }
                      }
                    }
                  }

                  // if server is running, restart it (AFTER OAuth authentication)
                  if (provider.mcpServerIsRunning(saveServerName)) {
                    await provider.stopMcpServer(saveServerName);
                    setState(() {
                      _serverLoading[serverName] = true;
                    });
                    await provider.startMcpServer(saveServerName);
                    setState(() {
                      _serverLoading[serverName] = false;
                    });
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(31),
                ),
                child: Text(l10n.save, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
            backgroundColor: Theme.of(context).colorScheme.surface,
          );
        },
      );

      if (confirmed == true && context.mounted) {
        setState(() {
          _refreshCounter++;
        });
      }
    } finally {
      // No controllers to dispose as FormBuilder handles that internally
    }
  }

  Future<void> _showDeleteConfirmDialog(BuildContext context, String serverName, McpServerProvider provider) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteServer(serverName)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.delete)),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await provider.removeMcpServer(serverName);
      setState(() {
        _refreshCounter++;
      });
    }
  }

  Future<void> showErrorDialog(BuildContext context, String message) async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        title: Text(l10n.error),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.ok))],
      ),
    );
  }
}
