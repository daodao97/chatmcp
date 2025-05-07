import 'openai_client.dart';
import 'claude_client.dart';
import 'deepseek_client.dart';
import 'base_llm_client.dart';
import 'ollama_client.dart';
import 'gemini_client.dart';
import 'package:chatmcp/provider/provider_manager.dart';
import 'package:chatmcp/provider/settings_provider.dart';
import 'package:logging/logging.dart';
import 'model.dart' as llm_model;

enum LLMProvider { openai, claude, ollama, deepseek, gemini }

class LLMFactory {
  static BaseLLMClient create(LLMProvider provider,
      {required String apiKey, required String baseUrl}) {
    switch (provider) {
      case LLMProvider.openai:
        return OpenAIClient(apiKey: apiKey, baseUrl: baseUrl);
      case LLMProvider.claude:
        return ClaudeClient(apiKey: apiKey, baseUrl: baseUrl);
      case LLMProvider.deepseek:
        return DeepSeekClient(apiKey: apiKey, baseUrl: baseUrl);
      case LLMProvider.ollama:
        return OllamaClient(baseUrl: baseUrl);
      case LLMProvider.gemini:
        return GeminiClient(apiKey: apiKey, baseUrl: baseUrl);
    }
  }
}

class LLMFactoryHelper {
  static final nonChatModelKeywords = {"whisper", "tts", "dall-e", "embedding"};

  static bool isChatModel(llm_model.Model model) {
    return !nonChatModelKeywords.any((keyword) => model.name.contains(keyword));
  }

  static final Map<String, LLMProvider> providerMap = {
    "openai": LLMProvider.openai,
    "claude": LLMProvider.claude,
    "deepseek": LLMProvider.deepseek,
    "ollama": LLMProvider.ollama,
    "gemini": LLMProvider.gemini,
  };

  static BaseLLMClient createFromModel(llm_model.Model currentModel) {
    try {
      final setting = ProviderManager.settingsProvider.apiSettings.firstWhere(
          (element) => element.providerId == currentModel.providerId);

      // Get configuration information
      final apiKey = setting.apiKey;
      final baseUrl = setting.apiEndpoint;

      Logger.root.fine(
          'Using API Key: ${apiKey.isEmpty ? 'empty' : apiKey.substring(0, 10)}***** for provider: ${currentModel.providerId} model: $currentModel');

      var provider = LLMFactoryHelper.providerMap[currentModel.providerId];

      provider ??= LLMProvider.values.byName(currentModel.apiStyle);

      // Create LLM client
      return LLMFactory.create(provider, apiKey: apiKey, baseUrl: baseUrl);
    } catch (e) {
      // If no matching provider is found, use the default OpenAI
      Logger.root
          .warning('No matching provider configuration found: ${currentModel.providerId}, using default OpenAI configuration');

      var openAISetting = ProviderManager.settingsProvider.apiSettings
          .firstWhere((element) => element.providerId == "openai",
              orElse: () => LLMProviderSetting(
                  apiKey: '', apiEndpoint: '', providerId: 'openai'));

      return OpenAIClient(
          apiKey: openAISetting.apiKey, baseUrl: openAISetting.apiEndpoint);
    }
  }
}
