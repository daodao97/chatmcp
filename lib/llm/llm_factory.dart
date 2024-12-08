import 'openai_client.dart';
import 'claude_client.dart';
import 'base_llm_client.dart';

enum LLMProvider { openAI, claude, llama }

class LLMFactory {
  static BaseLLMClient create(LLMProvider provider, {required String apiKey}) {
    switch (provider) {
      case LLMProvider.openAI:
        return OpenAIClient(apiKey: apiKey);
      case LLMProvider.claude:
        return ClaudeClient(apiKey: apiKey);
      default:
        throw Exception('Unsupported LLM provider');
    }
  }
}
