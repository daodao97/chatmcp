import 'dart:async';

import 'package:chatmcp/components/widgets/base.dart';
import 'package:chatmcp/provider/provider_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../provider/mcp_server_provider.dart';
import 'package:logging/logging.dart';
import 'dart:io';
import 'package:chatmcp/utils/process.dart';
import 'package:chatmcp/generated/app_localizations.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class McpServer extends StatefulWidget {
  const McpServer({super.key});

  @override
  State<McpServer> createState() => _McpServerState();
}

class _McpServerState extends State<McpServer> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTab = 'Installed';
  int _refreshCounter = 0;
  final Map<String, bool> _serverLoading = {};

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
                      side: BorderSide(
                        color:
                            Theme.of(context).colorScheme.outline.withAlpha(26),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: l10n.searchServer,
                        prefixIcon: Icon(
                          CupertinoIcons.search,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(153),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 标签选择和操作按钮
                  Row(
                    children: [
                      _buildFilterChip(l10n.all),
                      const SizedBox(width: 12),
                      _buildFilterChip(l10n.installed),
                      const SizedBox(width: 12),
                      _buildFilterChip("inmemory"),
                      const Spacer(),
                      _buildActionButton(
                        icon: CupertinoIcons.add,
                        tooltip: l10n.addProvider,
                        onPressed: () {
                          final provider = ProviderManager.mcpServerProvider;
                          _showEditDialog(context, '', provider, null);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        icon: CupertinoIcons.refresh,
                        tooltip: l10n.refresh,
                        onPressed: () => setState(() {}),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 服务器列表
                  Expanded(
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: (_selectedTab == l10n.all
                          ? provider.loadMarketServers()
                          : _selectedTab == "inmemory"
                              ? provider.loadInMemoryServers()
                              : provider.loadServers()),
                      key: ValueKey('server_list_$_refreshCounter'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CupertinoActivityIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.exclamationmark_circle,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Failed to load: ${snapshot.error}',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (snapshot.hasData) {
                          final servers = snapshot.data?['mcpServers']
                                  as Map<String, dynamic>? ??
                              {};

                          if (servers.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.desktopcomputer,
                                    size: 64,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withAlpha(153),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n.noServerConfigs,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withAlpha(153),
                                      fontSize: 16,
                                    ),
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

                              return _buildServerCard(
                                context,
                                serverName,
                                serverConfig,
                                provider,
                                serverConfig['installed'] ?? false,
                              );
                            },
                          );
                        }
                        return const Center(
                            child: CupertinoActivityIndicator());
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

  Widget _buildServerCard(
    BuildContext context,
    String serverName,
    dynamic serverConfig,
    McpServerProvider provider,
    bool installed,
  ) {
    final l10n = AppLocalizations.of(context)!;
    bool serverActive = isActive(serverName);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withAlpha(26),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              serverActive
                  ? CupertinoIcons.checkmark
                  : CupertinoIcons.desktopcomputer,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                serverName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (installed) ...[
              _buildActionButton(
                icon: provider.mcpServerIsRunning(serverName)
                    ? CupertinoIcons.stop
                    : CupertinoIcons.play,
                tooltip: provider.mcpServerIsRunning(serverName)
                    ? l10n.edit
                    : l10n.edit,
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
              _buildActionButton(
                icon: CupertinoIcons.pencil,
                tooltip: l10n.edit,
                onPressed: () =>
                    _showEditDialog(context, serverName, provider, null),
              ),
              const Gap(size: 10),
              _buildActionButton(
                icon: CupertinoIcons.delete,
                tooltip: l10n.delete,
                color: Theme.of(context).colorScheme.error,
                onPressed: () =>
                    _showDeleteConfirmDialog(context, serverName, provider),
              ),
            ] else ...[
              ElevatedButton.icon(
                icon: Icon(
                  CupertinoIcons.cloud_download,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                label: Text(l10n.install),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  final cmdExists =
                      await isCommandAvailable(serverConfig['command']);
                  if (!cmdExists) {
                    showErrorDialog(
                      context,
                      l10n.commandNotExist(serverConfig['command'],
                          Platform.environment['PATH'] ?? ''),
                    );
                  } else {
                    Logger.root.info(
                      'Install server configuration: $serverName ${serverConfig['command']} ${serverConfig['args']}',
                    );
                    await _showEditDialog(
                        context, serverName, provider, serverConfig);
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
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
              border: Border.all(
                color: color ??
                    Theme.of(context).colorScheme.primary.withAlpha(51),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color ?? Theme.of(context).colorScheme.primary,
                    ),
                  )
                : Icon(
                    icon,
                    size: 18,
                    color: color ?? Theme.of(context).colorScheme.primary,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedTab == 'All') {
      _selectedTab = l10n.all;
    }
    final isSelected = _selectedTab == label;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTab = label;
        });
      },
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primary.withAlpha(31),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withAlpha(26),
        ),
      ),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    String serverName,
    McpServerProvider provider,
    Map<String, dynamic>? newServerConfig,
  ) async {
    if (!context.mounted) return;

    var config = await provider.loadServers();
    if (_selectedTab == "inmemory") {
      config = await provider.loadInMemoryServers();
    }

    var servers = config['mcpServers'] ?? {};

    if (!context.mounted) return;

    final serverConfig = newServerConfig ??
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
    String resultArgs = (serverConfig['args'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .join(' ') ??
        '';
    String resultEnv = (serverConfig['env'] as Map<String, dynamic>?)
            ?.entries
            .map((e) => '${e.key}=${e.value}')
            .join('\n') ??
        '';
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
            title: Text(
              'MCP Server - ${serverName.isEmpty ? l10n.addProvider : serverName}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
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
                          hintStyle: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(102),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withAlpha(51),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withAlpha(51),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          prefixIcon: Icon(
                            CupertinoIcons.command,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
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
                      enabled: _selectedTab != "inmemory",
                      decoration: InputDecoration(
                        labelText: l10n.serverType,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withAlpha(51),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withAlpha(51),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        prefixIcon: Icon(
                          CupertinoIcons.gear,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'sse',
                          child: Text('SSE'),
                        ),
                        DropdownMenuItem(
                          value: 'stdio',
                          child: Text('STDIO'),
                        ),
                        DropdownMenuItem(
                          value: 'streamable',
                          child: Text('Streamable'),
                        ),
                        if (isEdit)
                          DropdownMenuItem(
                            value: 'inmemory',
                            enabled: false,
                            child: Text('InMemory'),
                          ),
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
                        hintStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(102),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withAlpha(51),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withAlpha(51),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        prefixIcon: Icon(
                          CupertinoIcons.command,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.fieldRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'args',
                      initialValue: resultArgs,
                      decoration: InputDecoration(
                        labelText: l10n.arguments,
                        hintText: l10n.argumentsExample,
                        hintStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(102),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withAlpha(51),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withAlpha(51),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        prefixIcon: Icon(
                          CupertinoIcons.command,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'env',
                      initialValue: resultEnv,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: l10n.environmentVariables,
                        hintText: l10n.envVarsFormat,
                        hintStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(102),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withAlpha(51),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withAlpha(51),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        prefixIcon: Icon(
                          CupertinoIcons.command,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderCheckbox(
                      name: 'auto_approve',
                      initialValue: autoApprove,
                      title: Text(
                        l10n.autoApprove,
                        style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () async {
                  if (!formKey.currentState!.saveAndValidate()) {
                    return;
                  }

                  final values = formKey.currentState!.value;
                  final saveServerName = serverName.isEmpty
                      ? (values['serverName'] as String).trim()
                      : serverName;
                  final type = values['type'] as String;
                  final command = (values['command'] as String).trim();
                  final args =
                      (values['args'] as String).trim().split(RegExp(r'\s+'));
                  final envStr = values['env'] as String;

                  if ((Platform.isIOS || Platform.isAndroid) &&
                      type != 'sse' &&
                      type != 'streamable' &&
                      !command.trim().startsWith('http')) {
                    showErrorDialog(dialogContext,
                        'Mobile only supports mcp sse and streamable servers');
                    return;
                  }

                  final env = Map<String, String>.fromEntries(
                    envStr
                        .split('\n')
                        .where((line) => line.trim().isNotEmpty)
                        .map((line) {
                      final parts = line.split('=');
                      if (parts.length < 2) {
                        return MapEntry(parts[0].trim(), '');
                      }
                      return MapEntry(
                        parts[0].trim(),
                        parts.sublist(1).join('=').trim(),
                      );
                    }),
                  );

                  if (config['mcpServers'] == null) {
                    config['mcpServers'] = <String, dynamic>{};
                  }

                  await provider.addMcpServer({
                    'name': saveServerName,
                    'type': type,
                    'command': command,
                    'args': args,
                    'env': env,
                    'auto_approve': values['auto_approve'] as bool? ?? false,
                  });

                  if (mounted) {
                    setState(() {
                      _refreshCounter++;
                    });
                  }

                  Navigator.pop(dialogContext, true);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withAlpha(31),
                ),
                child: Text(
                  l10n.save,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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

  Future<void> _showDeleteConfirmDialog(
    BuildContext context,
    String serverName,
    McpServerProvider provider,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteServer(serverName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
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
        title: Text(l10n.error),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}
