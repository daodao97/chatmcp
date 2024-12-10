import 'dart:async';
import 'package:provider/provider.dart';
import 'settings_provider.dart';
import 'mcp_server_provider.dart';
import 'chat_provider.dart';

class ProviderManager {
  static List<ChangeNotifierProvider> providers = [
    ChangeNotifierProvider<SettingsProvider>(
      create: (_) => SettingsProvider(),
    ),
    ChangeNotifierProvider<McpServerProvider>(
      create: (_) => McpServerProvider(),
    ),
    ChangeNotifierProvider<ChatProvider>(
      create: (_) => ChatProvider(),
    ),
    // 在这里添加其他 Provider
  ];

  static SettingsProvider? _settingsProvider;

  static SettingsProvider get settingsProvider {
    _settingsProvider ??= SettingsProvider();
    return _settingsProvider!;
  }

  static McpServerProvider? _mcpServerProvider;

  static McpServerProvider get mcpServerProvider {
    _mcpServerProvider ??= McpServerProvider();
    return _mcpServerProvider!;
  }

  static ChatProvider? _chatProvider;

  static ChatProvider get chatProvider {
    _chatProvider ??= ChatProvider();
    return _chatProvider!;
  }

  static Future<void> init() async {
    await SettingsProvider().loadSettings();
    _mcpServerProvider = McpServerProvider();
    unawaited(_mcpServerProvider!.init());
    await ChatProvider().loadChats();
  }
}
