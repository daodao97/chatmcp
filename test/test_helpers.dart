import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:chatmcp/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:chatmcp/provider/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock SettingsProvider
class MockSettingsProvider extends ChangeNotifier implements SettingsProvider {
  @override
  GeneralSetting generalSetting = GeneralSetting(
    themeMode: "system",
    locale: "en",
    showUserAvatar: true,
    showAssistantAvatar: true,
    fontSize: 14.0,
    useMarkdown: true,
  );

  @override
  Map<String, McpModelSetting> modelSettings = {};

  @override
  Future<void> loadSettings() async {}

  @override
  Future<void> saveGeneralSetting() async {}

  @override
  Future<void> saveModelSettings() async {}

  @override
  void notify() {
    notifyListeners();
  }

  @override
  bool get mounted => false; // Mock as not mounted for simplicity in tests

  // Implement other abstract members if any, or if needed by tests
  @override
  List<McpModelSetting> get models => [];

  @override
  McpModelSetting? getModelSetting(String modelId) => null;
  
  @override
  void setModelSetting(McpModelSetting setting) {}

  @override
  void resetToDefaults() {}
}


Future<Widget> pumpWidgetWithShell(WidgetTester tester, Widget widget, { SharedPreferences? mockPrefs }) async {
  // Initialize SharedPreferences if not provided (required by SettingsProvider)
  if (mockPrefs == null) {
    SharedPreferences.setMockInitialValues({});
    mockPrefs = await SharedPreferences.getInstance();
  }
  
  final settingsProvider = MockSettingsProvider();
  // You might need to await settingsProvider.loadSettings() if it does async work you depend on.

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        // Add other mock providers here if needed by the widget tree
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Material(child: widget), // Material provides text styles, directionality
      ),
    ),
  );
  return widget;
}
