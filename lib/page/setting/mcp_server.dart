import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/mcp_server_provider.dart';
import 'utils.dart';
import 'package:logging/logging.dart';

class McpServer extends StatefulWidget {
  const McpServer({super.key});

  @override
  State<McpServer> createState() => _McpServerState();
}

class _McpServerState extends State<McpServer> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTab = 'All'; // 'All' 或 'Installed'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 搜索框
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search server...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // 标签选择
            Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Installed'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => setState(() {}),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 服务器列表
            Expanded(
              child: Consumer<McpServerProvider>(
                builder: (context, provider, child) {
                  return FutureBuilder<Map<String, dynamic>>(
                    future: _selectedTab == 'All'
                        ? provider.loadMarketServers()
                        : provider.loadServers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                            child: Text('Failed to load: ${snapshot.error}'));
                      }

                      if (snapshot.hasData) {
                        // 获取 mcpServers 对象
                        final servers = snapshot.data?['mcpServers']
                                as Map<String, dynamic>? ??
                            {};

                        if (servers.isEmpty) {
                          return const Center(
                              child: Text('No server configurations found'));
                        }

                        return ListView.builder(
                          itemCount: servers.length,
                          itemBuilder: (context, index) {
                            final serverName = servers.keys.elementAt(index);
                            final serverConfig = servers[serverName];

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              child: ListTile(
                                title: Text(serverName),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Command: ${serverConfig['command'] ?? ''}'),
                                    Text(
                                        'Arguments: ${(serverConfig['args'] as List?)?.join(' ') ?? ''}'),
                                    if (serverConfig['env'] != null)
                                      Text(
                                          'Environment Variables: ${(serverConfig['env'] as Map?)?.entries.map((e) => '${e.key}=${e.value}').join('\n') ?? ''}'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_selectedTab == 'All')
                                      FutureBuilder<Map<String, dynamic>>(
                                        future: provider.loadServers(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            final installedServers = snapshot
                                                        .data?['mcpServers']
                                                    as Map<String, dynamic>? ??
                                                {};
                                            final isInstalled = installedServers
                                                .containsKey(serverName);

                                            return Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (isInstalled) ...[
                                                  IconButton(
                                                    icon:
                                                        const Icon(Icons.edit),
                                                    onPressed: () {
                                                      _showEditDialog(
                                                          context,
                                                          serverName,
                                                          provider,
                                                          null);
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete),
                                                    onPressed: () {
                                                      _showDeleteConfirmDialog(
                                                          context,
                                                          serverName,
                                                          provider);
                                                    },
                                                  ),
                                                ] else
                                                  TextButton.icon(
                                                    icon: const Icon(
                                                        Icons.download),
                                                    label:
                                                        const Text('Install'),
                                                    onPressed: () async {
                                                      final cmdExists =
                                                          await checkCommand(
                                                              serverConfig[
                                                                  'command']);
                                                      if (!cmdExists) {
                                                        throw Exception(
                                                            'Command "${serverConfig['command']}" does not exist, please install it first');
                                                      } else {
                                                        // 安装服务器配置
                                                        Logger.root.info(
                                                            'Install server configuration: $serverName ${serverConfig['command']} ${serverConfig['args']}');
                                                        await _showEditDialog(
                                                            context,
                                                            serverName,
                                                            provider,
                                                            serverConfig);
                                                      }
                                                    },
                                                  ),
                                              ],
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                    if (_selectedTab == 'Installed') ...[
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          _showEditDialog(context, serverName,
                                              provider, null);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          _showDeleteConfirmDialog(
                                              context, serverName, provider);
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  );
                },
              ),
            ),
          ],
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

    final config = await provider.loadServers();
    final servers = config['mcpServers'] ?? {};

    if (!context.mounted) return;

    final serverConfig = newServerConfig ??
        servers[serverName] as Map<String, dynamic>? ??
        {
          'command': '',
          'args': <String>[],
          'env': <String, String>{},
        };

    final commandController = TextEditingController(
      text: serverConfig['command']?.toString() ?? '',
    );
    final argsController = TextEditingController(
      text: (serverConfig['args'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .join(' ') ??
          '',
    );
    final envController = TextEditingController(
      text: (serverConfig['env'] as Map<String, dynamic>?)
              ?.entries
              .map((e) => '${e.key}=${e.value}')
              .join('\n') ??
          '',
    );

    try {
      if (!context.mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: Text('MCP Server - $serverName'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: commandController,
                  decoration: const InputDecoration(
                    labelText: 'Command',
                    hintText: 'For example: npx, uvx',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: argsController,
                  decoration: const InputDecoration(
                    labelText: 'Arguments',
                    hintText:
                        'Separate arguments with spaces, for example: -m mcp.server',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: envController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Environment Variables',
                    hintText: 'One per line, format: KEY=VALUE',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save'),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        // 解析环境变量
        final env = Map<String, String>.fromEntries(
          envController.text
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

        // 更新服务器配置
        if (config['mcpServers'] == null) {
          config['mcpServers'] = <String, dynamic>{};
        }
        config['mcpServers'][serverName] = {
          'command': commandController.text.trim(),
          'args': argsController.text.trim().split(RegExp(r'\s+')),
          'env': env,
        };

        await provider.saveServers(config);
        setState(() {});
      }
    } finally {
      // 确保控制器被释放
      commandController.dispose();
      argsController.dispose();
      envController.dispose();
    }
  }

  Future<void> _showDeleteConfirmDialog(
    BuildContext context,
    String serverName,
    McpServerProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete server "$serverName" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final config = await provider.loadServers();
      config['mcpServers'].remove(serverName);
      await provider.saveServers(config);
      setState(() {});
    }
  }

  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: _selectedTab == label,
      onSelected: (selected) {
        setState(() {
          _selectedTab = label;
        });
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
    );
  }

  Future<void> showErrorDialog(BuildContext context, String message) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
