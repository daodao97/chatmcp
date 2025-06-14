import 'package:chatmcp/components/widgets/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../provider/settings_provider.dart';
import 'package:chatmcp/generated/app_localizations.dart';

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
                      _buildSystemPromptCard(context),
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
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
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
            _buildSectionTitle(
                context, l10n.languageSettings, CupertinoIcons.globe),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withAlpha(50),
                ),
              ),
              child: ListTile(
                title: CText(text: l10n.language),
                trailing: DropdownButton<String>(
                  value: settings.generalSetting.locale,
                  underline: const SizedBox(),
                  icon: Icon(
                    CupertinoIcons.chevron_right,
                    size: 16,
                    color:
                        Theme.of(context).colorScheme.onSurface.withAlpha(50),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'en',
                      child: CText(text: 'English'),
                    ),
                    DropdownMenuItem(
                      value: 'zh',
                      child: CText(text: '中文'),
                    ),
                    DropdownMenuItem(
                      value: 'tr',
                      child: CText(text: 'Türkçe'),
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
            _buildSectionTitle(
                context, l10n.themeSettings, CupertinoIcons.paintbrush),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withAlpha(50),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 1.0),
                child: DropdownButtonFormField<String>(
                  value: settings.generalSetting.theme,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 2.0),
                  ),
                  icon: Icon(
                    CupertinoIcons.chevron_right,
                    size: 16,
                    color:
                        Theme.of(context).colorScheme.onSurface.withAlpha(50),
                  ),
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
                      settings.updateGeneralSettingsPartially(
                        theme: value,
                      );
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
            _buildSectionTitle(
                context, l10n.showAvatar, CupertinoIcons.person_crop_circle),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withAlpha(50),
                ),
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
                      settings.updateGeneralSettingsPartially(
                          showAssistantAvatar: value);
                    },
                  ),
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Theme.of(context).colorScheme.outline.withAlpha(50),
                  ),
                  SettingSwitch(
                    title: l10n.showUserAvatar,
                    subtitle: l10n.showUserAvatarDescription,
                    value: settings.generalSetting.showUserAvatar,
                    titleFontSize: 14,
                    subtitleFontSize: 12,
                    onChanged: (bool value) {
                      settings.updateGeneralSettingsPartially(
                          showUserAvatar: value);
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

  Widget _buildSystemPromptCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
                context, l10n.systemPrompt, CupertinoIcons.text_quote),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withAlpha(50),
                ),
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
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withAlpha(20),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withAlpha(20),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 5,
                      onChanged: (value) {
                        settings.updateGeneralSettingsPartially(
                          systemPrompt: value,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.systemPromptDescription,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(60),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
