import 'package:chatmcp/llm/llm_factory.dart';
import 'package:chatmcp/llm/model.dart' as llm_model;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:logging/logging.dart';

class LLMProviderSetting {
  String apiKey;
  String apiEndpoint;
  String? apiStyle;
  String? providerName;
  List<String>? models;
  List<String>? enabledModels;
  String? providerId;
  bool custom = false;
  String icon = '';
  String? genTitleModel;

  LLMProviderSetting({
    required this.apiKey,
    required this.apiEndpoint,
    this.apiStyle,
    this.providerName,
    this.models,
    this.enabledModels,
    this.providerId,
    this.custom = false,
    this.icon = '',
    this.genTitleModel,
  });

  Map<String, dynamic> toJson() {
    return {
      'apiKey': apiKey,
      'apiEndpoint': apiEndpoint,
      'apiStyle': apiStyle,
      'providerName': providerName,
      'models': models,
      'enabledModels': enabledModels,
      'provider': providerId,
      'custom': custom,
      'icon': icon,
      'genTitleModel': genTitleModel,
    };
  }

  factory LLMProviderSetting.fromJson(Map<String, dynamic> json) {
    return LLMProviderSetting(
      apiKey: json['apiKey'] as String,
      apiEndpoint: json['apiEndpoint'] as String,
      apiStyle: json['apiStyle'] as String? ?? 'openai',
      providerName: json['providerName'] as String,
      models: json['models'] != null ? List<String>.from(json['models']) : [],
      enabledModels: json['enabledModels'] != null
          ? List<String>.from(json['enabledModels'])
          : [],
      providerId: json['provider'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      custom: json['custom'] as bool? ?? false,
      genTitleModel: json['genTitleModel'] as String? ?? '',
    );
  }
}

var defaultSystemPrompt =
    '''You are an intelligent and helpful AI assistant. Please:
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

  GeneralSetting({
    required this.theme,
    this.showAssistantAvatar = false,
    this.showUserAvatar = false,
    this.systemPrompt = 'You are a helpful assistant.',
    this.locale = 'en',
    this.maxMessages = 50,
    this.maxLoops = 100,
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
    );
  }
}

class ChatSetting {
  double temperature = 1.0;
  int? maxTokens;
  double topP = 1.0;
  double frequencyPenalty = 0.0;
  double presencePenalty = 0.0;

  ChatSetting({
    this.temperature = 1.0,
    this.maxTokens,
    this.topP = 1.0,
    this.frequencyPenalty = 0.0,
    this.presencePenalty = 0.0,
  });

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
];

final apiSettingsKey = 'apiSettings_v6';

class SettingsProvider extends ChangeNotifier {
  static final SettingsProvider _instance = SettingsProvider._internal();
  factory SettingsProvider() => _instance;
  SettingsProvider._internal();

  List<LLMProviderSetting> _apiSettings = [];

  GeneralSetting _generalSetting = GeneralSetting(
    theme: 'light',
    systemPrompt: defaultSystemPrompt,
  );

  ChatSetting _modelSetting = ChatSetting();

  List<LLMProviderSetting> get apiSettings => _apiSettings;

  LLMProviderSetting getProviderSetting(String providerId) =>
      _apiSettings.firstWhere(
        (element) => element.providerId == providerId,
      );

  GeneralSetting get generalSetting => _generalSetting;

  ChatSetting get modelSetting => _modelSetting;

  int sandboxServerPort = 0;

  Future<void> updateSandboxServerPort({required int port}) async {
    sandboxServerPort = port;
    notifyListeners();
  }

  List<llm_model.Model> _availableModels = [];

  List<llm_model.Model> get availableModels => _availableModels;

  Future<void> updateAvailableModels(
      {required List<llm_model.Model> models}) async {
    _availableModels = models;
    notifyListeners();
  }

  Future<List<llm_model.Model>> getAvailableModels() async {
    final models = <llm_model.Model>[];
    for (var setting in _apiSettings) {
      for (var model in setting.enabledModels ?? []) {
        var m = llm_model.Model(
            name: model,
            label: model,
            providerId: setting.providerId ?? '',
            icon: setting.icon,
            providerName: setting.providerName ?? '',
            apiStyle: setting.apiStyle ?? '');

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
        settings = decoded
            .map((value) =>
                LLMProviderSetting.fromJson(value as Map<String, dynamic>))
            .toList();
      } catch (e) {
        Logger.root.severe('Error parsing $apiSettingsKey: $e');
        settings = [..._apiSettings];
      }
    }

    for (var setting in defaultApiSettings) {
      if (!settings
          .any((element) => element.providerId == setting.providerId)) {
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

    return _apiSettings;
  }

  Future<void> updateApiSettings({
    required List<LLMProviderSetting> apiSettings,
  }) async {
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
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _generalSetting = GeneralSetting(
      theme: theme ?? _generalSetting.theme,
      showAssistantAvatar:
          showAssistantAvatar ?? _generalSetting.showAssistantAvatar,
      showUserAvatar: showUserAvatar ?? _generalSetting.showUserAvatar,
      systemPrompt: systemPrompt ?? _generalSetting.systemPrompt,
      locale: locale ?? _generalSetting.locale,
      maxMessages: maxMessages ?? _generalSetting.maxMessages,
      maxLoops: maxLoops ?? _generalSetting.maxLoops,
    );
    await prefs.setString(
        'generalSettings', jsonEncode(_generalSetting.toJson()));
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
    await prefs.setString(
        'generalSettings', jsonEncode(_generalSetting.toJson()));
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
