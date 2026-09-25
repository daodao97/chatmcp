import 'package:chatmcp/llm/llm_factory.dart';
import 'package:chatmcp/llm/model.dart' as llm_model;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:logging/logging.dart';

class LLMProviderSetting {
  String apiKey;
  String apiEndpoint;
  String? apiVersion;
  String? apiStyle;
  String? providerName;
  List<String>? models;
  List<String>? enabledModels;
  String? providerId;
  bool custom = false;
  String icon = '';
  String? genTitleModel;
  String? link;
  int? priority;
  bool? enable;

  LLMProviderSetting({
    required this.apiKey,
    required this.apiEndpoint,
    this.apiVersion,
    this.apiStyle,
    this.providerName,
    this.models,
    this.enabledModels,
    this.providerId,
    this.custom = false,
    this.icon = '',
    this.genTitleModel,
    this.link,
    this.priority,
    this.enable,
  });

  Map<String, dynamic> toJson() {
    return {
      'apiKey': apiKey,
      'apiEndpoint': apiEndpoint,
      'apiVersion': apiVersion,
      'apiStyle': apiStyle,
      'providerName': providerName,
      'models': models,
      'enabledModels': enabledModels,
      'provider': providerId,
      'custom': custom,
      'icon': icon,
      'genTitleModel': genTitleModel,
      'link': link,
      'priority': priority,
      'enable': enable,
    };
  }

  factory LLMProviderSetting.fromJson(Map<String, dynamic> json) {
    return LLMProviderSetting(
      apiKey: json['apiKey'] as String,
      apiEndpoint: json['apiEndpoint'] as String,
      apiVersion: json['apiVersion'] as String?,
      apiStyle: json['apiStyle'] as String? ?? 'openai',
      providerName: json['providerName'] as String,
      models: json['models'] != null ? List<String>.from(json['models']) : [],
      enabledModels: json['enabledModels'] != null ? List<String>.from(json['enabledModels']) : [],
      providerId: json['provider'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      custom: json['custom'] as bool? ?? false,
      genTitleModel: json['genTitleModel'] as String? ?? '',
      link: json['link'] as String? ?? '',
      priority: json['priority'] as int? ?? 0,
      enable: json['enable'] as bool?,
    );
  }
}

var defaultSystemPrompt = '''You are an intelligent and helpful AI assistant. Please:
1. Provide clear and concise responses
2. If you're not sure about something, please say so
3. When appropriate, provide examples to illustrate your points
4. If a user messages you in a specific language, respond in that language
5. Format responses using markdown when helpful
6. Use mermaid to generate diagrams''';

class GeneralSetting {
  String theme;
  bool showAssistantAvatar = false;
  bool showUserAvatar = false;
  String systemPrompt;
  String locale;
  int maxMessages;
  int maxLoops;

  // 代理设置
  bool enableProxy = false;
  String proxyType = 'HTTP'; // HTTP, HTTPS, SOCKS4, SOCKS5
  String proxyHost = '';
  int proxyPort = 8080;
  String proxyUsername = '';
  String proxyPassword = '';

  GeneralSetting({
    required this.theme,
    this.showAssistantAvatar = false,
    this.showUserAvatar = false,
    this.systemPrompt = 'You are a helpful assistant.',
    this.locale = 'en',
    this.maxMessages = 50,
    this.maxLoops = 100,
    this.enableProxy = false,
    this.proxyType = 'HTTP',
    this.proxyHost = '',
    this.proxyPort = 8080,
    this.proxyUsername = '',
    this.proxyPassword = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'showAssistantAvatar': showAssistantAvatar,
      'showUserAvatar': showUserAvatar,
      'systemPrompt': systemPrompt,
      'locale': locale,
      'maxMessages': maxMessages,
      'maxLoops': maxLoops,
      'enableProxy': enableProxy,
      'proxyType': proxyType,
      'proxyHost': proxyHost,
      'proxyPort': proxyPort,
      'proxyUsername': proxyUsername,
      'proxyPassword': proxyPassword,
    };
  }

  factory GeneralSetting.fromJson(Map<String, dynamic> json) {
    return GeneralSetting(
      theme: json['theme'] as String? ?? 'light',
      showAssistantAvatar: json['showAssistantAvatar'] as bool? ?? false,
      showUserAvatar: json['showUserAvatar'] as bool? ?? false,
      systemPrompt: json['systemPrompt'] as String? ?? defaultSystemPrompt,
      locale: json['locale'] as String? ?? 'en',
      maxMessages: json['maxMessages'] as int? ?? 50,
      maxLoops: json['maxLoops'] as int? ?? 100,
      enableProxy: json['enableProxy'] as bool? ?? false,
      proxyType: json['proxyType'] as String? ?? 'HTTP',
      proxyHost: json['proxyHost'] as String? ?? '',
      proxyPort: json['proxyPort'] as int? ?? 8080,
      proxyUsername: json['proxyUsername'] as String? ?? '',
      proxyPassword: json['proxyPassword'] as String? ?? '',
    );
  }
}

class ChatSetting {
  double temperature = 1.0;
  int? maxTokens;
  double topP = 1.0;
  double frequencyPenalty = 0.0;
  double presencePenalty = 0.0;

  ChatSetting({this.temperature = 1.0, this.maxTokens, this.topP = 1.0, this.frequencyPenalty = 0.0, this.presencePenalty = 0.0});

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'maxTokens': maxTokens,
      'topP': topP,
      'frequencyPenalty': frequencyPenalty,
      'presencePenalty': presencePenalty,
    };
  }

  factory ChatSetting.fromJson(Map<String, dynamic> json) {
    return ChatSetting(
      temperature: json['temperature'] as double? ?? 1.0,
      maxTokens: json['maxTokens'] == null ? null : json['maxTokens'] as int,
      topP: json['topP'] as double? ?? 1.0,
      frequencyPenalty: json['frequencyPenalty'] as double? ?? 0.0,
      presencePenalty: json['presencePenalty'] as double? ?? 0.0,
    );
  }
}

final List<LLMProviderSetting> defaultApiSettings = [
  LLMProviderSetting(
    apiKey: '',
    apiEndpoint: 'https://api.githubcopilot.com',
    apiStyle: 'openai',
    providerId: 'copilot',
    providerName: 'GitHub Copilot',
    icon: 'copilot',
    custom: false,
  ),
  LLMProviderSetting(
    apiKey: '',
    apiEndpoint: 'https://YOUR_RESOURCE_NAME.openai.azure.com',
    apiStyle: 'foundry',
    apiVersion: '2025-01-01-preview',
    providerId: 'foundry',
    providerName: 'Azure AI Foundry',
    icon: 'foundry',
    custom: false,
  ),
  LLMProviderSetting(
    apiKey: '',
    apiEndpoint: 'https://api.openai.com/v1',
    apiStyle: 'openai',
    providerId: 'openai',
    providerName: 'OpenAI',
    icon: 'openai',
    custom: false,
  ),
  LLMProviderSetting(
    apiKey: '',
    apiEndpoint: 'https://api.anthropic.com/v1',
    apiStyle: 'claude',
    providerId: 'claude',
    providerName: 'Claude',
    icon: 'claude',
    custom: false,
  ),
  LLMProviderSetting(
    apiKey: '',
    apiEndpoint: '', // Not used by CLI mode
    apiStyle: 'claude-code',
    providerId: 'claude-code',
    providerName: 'Claude Code',
    icon: 'claude',
    custom: false,
    link: 'https://docs.anthropic.com/en/docs/claude-code/sdk',
    models: ['claude-3-7-sonnet', 'claude-3-opus', 'claude-3-5-sonnet', 'claude-3-5-haiku'],
    enabledModels: ['claude-3-7-sonnet', 'claude-3-5-sonnet'],
  ),
  LLMProviderSetting(
    apiKey: '',
    apiEndpoint: 'https://api.deepseek.com',
    apiStyle: 'deepseek',
    providerId: 'deepseek',
    providerName: 'DeepSeek',
    icon: 'deepseek',
    custom: false,
  ),
  LLMProviderSetting(
    apiKey: '',
    apiEndpoint: 'http://localhost:11434',
    apiStyle: 'openai',
    providerId: 'ollama',
    providerName: 'Ollama',
    icon: 'ollama',
    custom: false,
  ),
  LLMProviderSetting(
    apiKey: '',
    apiEndpoint: 'https://generativelanguage.googleapis.com/v1beta',
    apiStyle: 'gemini',
    providerId: 'gemini',
    providerName: 'Gemini',
    icon: 'gemini',
    custom: false,
  ),
  LLMProviderSetting(
    apiKey: '',
    apiEndpoint: 'https://openrouter.ai/api/v1',
    apiStyle: 'openai',
    providerId: 'openrouter',
    providerName: 'OpenRouter',
    icon: 'openrouter',
    custom: false,
  ),
  LLMProviderSetting(
    apiKey: '',
    apiEndpoint: 'https://router.requesty.ai/v1',
    apiStyle: 'openai',
    providerId: 'requesty',
    providerName: 'Requesty',
    icon: 'requesty',
    custom: false,
  ),
  LLMProviderSetting(
    apiKey: '',
    apiEndpoint: 'https://api.302.ai/v1',
    apiStyle: 'openai',
    providerId: '302.AI',
    providerName: '302.AI',
    icon: '302ai',
    custom: false,
    link: 'https://share.302.ai/euPaZh',
    priority: 1,
  ),
];

final apiSettingsKey = 'apiSettings_v6';

class SettingsProvider extends ChangeNotifier {
  static final SettingsProvider _instance = SettingsProvider._internal();
  factory SettingsProvider() => _instance;
  SettingsProvider._internal();

  List<LLMProviderSetting> _apiSettings = [];

  GeneralSetting _generalSetting = GeneralSetting(theme: 'light', systemPrompt: defaultSystemPrompt);

  ChatSetting _modelSetting = ChatSetting();

  List<LLMProviderSetting> get apiSettings => _apiSettings;

  LLMProviderSetting getProviderSetting(String providerId) => _apiSettings.firstWhere((element) => element.providerId == providerId);

  GeneralSetting get generalSetting => _generalSetting;

  ChatSetting get modelSetting => _modelSetting;

  int sandboxServerPort = 0;

  Future<void> updateSandboxServerPort({required int port}) async {
    sandboxServerPort = port;
    notifyListeners();
  }

  List<llm_model.Model> _availableModels = [];

  List<llm_model.Model> get availableModels => _availableModels;

  Future<void> updateAvailableModels({required List<llm_model.Model> models}) async {
    _availableModels = models;
    notifyListeners();
  }

  Future<List<llm_model.Model>> getAvailableModels() async {
    final models = <llm_model.Model>[];
    for (var setting in _apiSettings) {
      // 只有启用的提供商才加入模型列表（null 表示启用，只有 false 为禁用）
      final isEnabled = setting.enable ?? true;
      if (!isEnabled) continue;

      for (var model in setting.enabledModels ?? []) {
        var m = llm_model.Model(
          name: model,
          label: model,
          providerId: setting.providerId ?? '',
          icon: setting.icon,
          providerName: setting.providerName ?? '',
          apiStyle: setting.apiStyle ?? '',
          priority: setting.priority ?? 0,
        );

        if (LLMFactoryHelper.isChatModel(m)) {
          models.add(m);
        }
      }
    }
    return models;
  }

  Future<List<LLMProviderSetting>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? settingsJson = prefs.getString(apiSettingsKey);

    List<LLMProviderSetting> settings = [];

    if (settingsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(settingsJson);
        settings = decoded.map((value) => LLMProviderSetting.fromJson(value as Map<String, dynamic>)).toList();
      } catch (e) {
        Logger.root.severe('Error parsing $apiSettingsKey: $e');
        settings = [..._apiSettings];
      }
    }

    for (var setting in defaultApiSettings) {
      if (!settings.any((element) => element.providerId == setting.providerId)) {
        settings = [...settings, setting];
      }
    }

    _apiSettings = settings;

    final String? generalSettingsJson = prefs.getString('generalSettings');
    if (generalSettingsJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(generalSettingsJson);
      _generalSetting = GeneralSetting.fromJson(decoded);
    }

    final String? modelSettingsJson = prefs.getString('modelSettings');
    if (modelSettingsJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(modelSettingsJson);
      _modelSetting = ChatSetting.fromJson(decoded);
    }

    final availableModels = await getAvailableModels();

    updateAvailableModels(models: availableModels);

    notifyListeners();

    // sort by priority descending _apiSettings
    _apiSettings.sort((a, b) => (b.priority ?? 0).compareTo(a.priority ?? 0));

    return _apiSettings;
  }

  Future<void> updateApiSettings({required List<LLMProviderSetting> apiSettings}) async {
    final prefs = await SharedPreferences.getInstance();

    _apiSettings = apiSettings;

    final encodedSettings = apiSettings.map((value) => value.toJson()).toList();

    await prefs.setString(apiSettingsKey, jsonEncode(encodedSettings));
    Logger.root.info('updateApiSettings: ${jsonEncode(encodedSettings)}');

    final availableModels = await getAvailableModels();
    updateAvailableModels(models: availableModels);

    notifyListeners();
  }

  Future<void> updateGeneralSettingsPartially({
    String? theme,
    bool? showAssistantAvatar,
    bool? showUserAvatar,
    String? systemPrompt,
    String? locale,
    int? maxMessages,
    int? maxLoops,
    bool? enableProxy,
    String? proxyType,
    String? proxyHost,
    int? proxyPort,
    String? proxyUsername,
    String? proxyPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    _generalSetting = GeneralSetting(
      theme: theme ?? _generalSetting.theme,
      showAssistantAvatar: showAssistantAvatar ?? _generalSetting.showAssistantAvatar,
      showUserAvatar: showUserAvatar ?? _generalSetting.showUserAvatar,
      systemPrompt: systemPrompt ?? _generalSetting.systemPrompt,
      locale: locale ?? _generalSetting.locale,
      maxMessages: maxMessages ?? _generalSetting.maxMessages,
      maxLoops: maxLoops ?? _generalSetting.maxLoops,
      enableProxy: enableProxy ?? _generalSetting.enableProxy,
      proxyType: proxyType ?? _generalSetting.proxyType,
      proxyHost: proxyHost ?? _generalSetting.proxyHost,
      proxyPort: proxyPort ?? _generalSetting.proxyPort,
      proxyUsername: proxyUsername ?? _generalSetting.proxyUsername,
      proxyPassword: proxyPassword ?? _generalSetting.proxyPassword,
    );
    await prefs.setString('generalSettings', jsonEncode(_generalSetting.toJson()));

    notifyListeners();
  }

  Future<void> updateGeneralSettings({
    required String theme,
    required bool showAssistantAvatar,
    required bool showUserAvatar,
    required String systemPrompt,
    required String locale,
    int? maxMessages,
    int? maxLoops,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _generalSetting = GeneralSetting(
      theme: theme,
      showAssistantAvatar: showAssistantAvatar,
      showUserAvatar: showUserAvatar,
      systemPrompt: systemPrompt,
      locale: locale,
      maxMessages: maxMessages ?? _generalSetting.maxMessages,
      maxLoops: maxLoops ?? _generalSetting.maxLoops,
    );
    await prefs.setString('generalSettings', jsonEncode(_generalSetting.toJson()));
    notifyListeners();
  }

  Future<void> updateModelSettings({
    required double temperature,
    required int? maxTokens,
    required double topP,
    required double frequencyPenalty,
    required double presencePenalty,
  }) async {
    _modelSetting = ChatSetting(
      temperature: temperature,
      maxTokens: maxTokens,
      topP: topP,
      frequencyPenalty: frequencyPenalty,
      presencePenalty: presencePenalty,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('modelSettings', jsonEncode(_modelSetting.toJson()));
    notifyListeners();
  }

  Future<void> resetModelSettings() async {
    _modelSetting = ChatSetting();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('modelSettings', jsonEncode(_modelSetting.toJson()));
    notifyListeners();
  }
}
