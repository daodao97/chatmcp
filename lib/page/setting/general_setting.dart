import 'package:chatmcp/components/widgets/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../provider/settings_provider.dart';
import 'package:chatmcp/generated/app_localizations.dart';
import 'package:chatmcp/utils/platform.dart';
import 'package:chatmcp/utils/toast.dart';
import 'package:chatmcp/file_logger.dart';

import 'setting_switch.dart';

class GeneralSettings extends StatefulWidget {
  const GeneralSettings({super.key});

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(height: 10),
                      _buildThemeCard(context),
                      _buildLocaleCard(context),
                      _buildAvatarCard(context),
                      if (!kIsBrowser) _buildProxyCard(context),
                      _buildSystemPromptCard(context),
                      if (!kIsBrowser) _buildMaintenanceCard(context),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildLocaleCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, l10n.languageSettings, CupertinoIcons.globe),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(50)),
              ),
              child: ListTile(
                title: CText(text: l10n.language),
                trailing: DropdownButton<String>(
                  value: settings.generalSetting.locale,
                  underline: const SizedBox(),
                  icon: Icon(CupertinoIcons.chevron_right, size: 16, color: Theme.of(context).colorScheme.onSurface.withAlpha(50)),
                  items: const [
                    DropdownMenuItem(
                      value: 'en',
                      child: CText(text: 'English'),
                    ),
                    DropdownMenuItem(
                      value: 'ru',
                      child: CText(text: 'Русский'),
                    ),
                    DropdownMenuItem(
                      value: 'zh',
                      child: CText(text: '中文'),
                    ),
                    DropdownMenuItem(
                      value: 'tr',
                      child: CText(text: 'Türkçe'),
                    ),
                    DropdownMenuItem(
                      value: 'de',
                      child: CText(text: 'Deutsch'),
                    ),
                  ],
                  onChanged: (String? value) {
                    if (value != null) {
                      settings.updateGeneralSettingsPartially(locale: value);
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, l10n.themeSettings, CupertinoIcons.paintbrush),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
                side: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(50)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 1.0),
                child: DropdownButtonFormField<String>(
                  value: settings.generalSetting.theme,
                  decoration: InputDecoration(border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 2.0)),
                  icon: Icon(CupertinoIcons.chevron_right, size: 16, color: Theme.of(context).colorScheme.onSurface.withAlpha(50)),
                  items: [
                    DropdownMenuItem(
                      value: 'light',
                      child: CText(text: l10n.lightTheme),
                    ),
                    DropdownMenuItem(
                      value: 'dark',
                      child: CText(text: l10n.darkTheme),
                    ),
                    DropdownMenuItem(
                      value: 'system',
                      child: CText(text: l10n.followSystem),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      settings.updateGeneralSettingsPartially(theme: value);
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvatarCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, l10n.showAvatar, CupertinoIcons.person_crop_circle),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(50)),
              ),
              child: Column(
                children: [
                  SettingSwitch(
                    title: l10n.showAssistantAvatar,
                    subtitle: l10n.showAssistantAvatarDescription,
                    value: settings.generalSetting.showAssistantAvatar,
                    titleFontSize: 14,
                    subtitleFontSize: 12,
                    onChanged: (bool value) {
                      settings.updateGeneralSettingsPartially(showAssistantAvatar: value);
                    },
                  ),
                  Divider(height: 1, indent: 16, endIndent: 16, color: Theme.of(context).colorScheme.outline.withAlpha(50)),
                  SettingSwitch(
                    title: l10n.showUserAvatar,
                    subtitle: l10n.showUserAvatarDescription,
                    value: settings.generalSetting.showUserAvatar,
                    titleFontSize: 14,
                    subtitleFontSize: 12,
                    onChanged: (bool value) {
                      settings.updateGeneralSettingsPartially(showUserAvatar: value);
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProxyCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, l10n.proxySettings, CupertinoIcons.globe),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(50)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 启用代理开关
                    SettingSwitch(
                      title: l10n.enableProxy,
                      subtitle: l10n.enableProxyDescription,
                      value: settings.generalSetting.enableProxy,
                      titleFontSize: 14,
                      subtitleFontSize: 12,
                      onChanged: (bool value) {
                        settings.updateGeneralSettingsPartially(enableProxy: value);
                        ToastUtils.success(l10n.saved);
                      },
                    ),

                    // 如果启用代理，显示代理配置选项
                    if (settings.generalSetting.enableProxy) ...[
                      const SizedBox(height: 16),
                      Divider(height: 1, color: Theme.of(context).colorScheme.outline.withAlpha(50)),
                      const SizedBox(height: 16),

                      // 代理类型选择
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              l10n.proxyType,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              value: settings.generalSetting.proxyType,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(20)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'HTTP',
                                  child: CText(text: 'HTTP'),
                                ),
                                DropdownMenuItem(
                                  value: 'HTTPS',
                                  child: CText(text: 'HTTPS'),
                                ),
                                DropdownMenuItem(
                                  value: 'SOCKS4',
                                  child: CText(text: 'SOCKS4'),
                                ),
                                DropdownMenuItem(
                                  value: 'SOCKS5',
                                  child: CText(text: 'SOCKS5'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  settings.updateGeneralSettingsPartially(proxyType: value);
                                  ToastUtils.success(l10n.saved);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 代理地址和端口
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              initialValue: settings.generalSetting.proxyHost,
                              decoration: InputDecoration(
                                labelText: l10n.proxyHost,
                                hintText: l10n.enterProxyHost,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                              validator: (value) {
                                if (settings.generalSetting.enableProxy && (value == null || value.isEmpty)) {
                                  return l10n.proxyHostRequired;
                                }
                                return null;
                              },
                              onChanged: (value) {
                                settings.updateGeneralSettingsPartially(proxyHost: value);
                                if (value.isNotEmpty) {
                                  ToastUtils.success(l10n.saved);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              initialValue: settings.generalSetting.proxyPort.toString(),
                              decoration: InputDecoration(
                                labelText: l10n.proxyPort,
                                hintText: l10n.enterProxyPort,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return null;
                                }
                                final port = int.tryParse(value);
                                if (port == null || port < 1 || port > 65535) {
                                  return l10n.proxyPortInvalid;
                                }
                                return null;
                              },
                              onChanged: (value) {
                                final port = int.tryParse(value);
                                if (port != null && port >= 1 && port <= 65535) {
                                  settings.updateGeneralSettingsPartially(proxyPort: port);
                                  ToastUtils.success(l10n.saved);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 用户名和密码（可选）
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: settings.generalSetting.proxyUsername,
                              decoration: InputDecoration(
                                labelText: l10n.proxyUsername,
                                hintText: l10n.enterProxyUsername,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                              onChanged: (value) {
                                settings.updateGeneralSettingsPartially(proxyUsername: value);
                                ToastUtils.success(l10n.saved);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: settings.generalSetting.proxyPassword,
                              decoration: InputDecoration(
                                labelText: l10n.proxyPassword,
                                hintText: l10n.enterProxyPassword,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                              obscureText: true,
                              onChanged: (value) {
                                settings.updateGeneralSettingsPartially(proxyPassword: value);
                                ToastUtils.success(l10n.saved);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSystemPromptCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, l10n.systemPrompt, CupertinoIcons.text_quote),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(50)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: settings.generalSetting.systemPrompt,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(20)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(20)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                      maxLines: 5,
                      onChanged: (value) {
                        settings.updateGeneralSettingsPartially(systemPrompt: value);
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.systemPromptDescription, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withAlpha(60))),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMaintenanceCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, l10n.maintenance, CupertinoIcons.wrench),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(50)),
          ),
          child: ListTile(
            leading: Icon(CupertinoIcons.delete, color: Theme.of(context).colorScheme.onSurface.withAlpha(200)),
            title: CText(text: l10n.cleanupLogs),
            subtitle: CText(text: l10n.cleanupLogsDescription),
            trailing: Icon(CupertinoIcons.chevron_right, size: 16, color: Theme.of(context).colorScheme.onSurface.withAlpha(50)),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: CText(text: l10n.confirmCleanup),
                  content: CText(text: l10n.confirmCleanupMessage),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: CText(text: l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: CText(text: l10n.confirm),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                try {
                  await FileLogger.cleanupOldLogs(days: 0);
                  if (mounted) {
                    ToastUtils.success(l10n.cleanupSuccess);
                  }
                } catch (e) {
                  if (mounted) {
                    ToastUtils.error('${l10n.cleanupFailed}: $e');
                  }
                }
              }
            },
          ),
        ),
      ],
    );
  }
}
