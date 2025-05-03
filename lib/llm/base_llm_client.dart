import 'package:chatmcp/provider/provider_manager.dart';
import 'package:logging/logging.dart';
import 'model.dart';
import 'utils.dart';
import 'package:http/http.dart' as http;

abstract class BaseLLMClient {
  Future<LLMResponse> chatCompletion(CompletionRequest request);

  Stream<LLMResponse> chatStreamCompletion(CompletionRequest request);

  String joinPaths(String first, String second) {
    if (first.isEmpty) return second;
    if (second.isEmpty) return first;

    final firstWithoutTrailing =
        first.endsWith('/') ? first.substring(0, first.length - 1) : first;
    final secondWithoutLeading =
        second.startsWith('/') ? second.substring(1) : second;

    return '$firstWithoutTrailing/$secondWithoutLeading';
  }

  String getEndpoint(String url, String path) {
    final urlObj = Uri.parse(url);
    final newPath = joinPaths(urlObj.path, path);
    return urlObj.replace(path: newPath).toString();
  }

  Future<Map<String, dynamic>> checkToolCall(
    String model,
    CompletionRequest request,
    Map<String, List<Map<String, dynamic>>> toolsResponse,
  ) async {
    final openaiTools = convertToOpenAITools(toolsResponse);

    try {
      final response = await chatCompletion(
        CompletionRequest(
          model: model,
          messages: request.messages,
          tools: openaiTools,
        ),
      );

      if (!response.needToolCall) {
        return {
          'need_tool_call': false,
          'content': response.content,
        };
      }

      // Return tool call details
      return {
        'need_tool_call': true,
        'content': response.content,
        'tool_calls': response.toolCalls
            ?.map((call) => {
                  'id': call.id,
                  'name': call.function.name,
                  'arguments': call.function.parsedArguments,
                })
            .toList(),
      };
    } catch (e) {
      rethrow; // Re-throw the exception for outer handling
    }
  }

  Future<LLMException> handleError(
      dynamic e, String name, String endpoint, String bodyStr) async {
    if (e is http.ClientException) {
      return LLMException(
        name: name,
        endpoint: endpoint,
        requestBody: bodyStr,
        originalError: e,
      );
    } else if (e is Exception && e.toString().contains('HTTP')) {
      // Handle HTTP errors (like "HTTP 400: Bad Request")
      final errorMsg = e.toString();
      final statusCodeMatch = RegExp(r'HTTP (\d+)').firstMatch(errorMsg);
      final statusCode = statusCodeMatch != null
          ? int.tryParse(statusCodeMatch.group(1) ?? '')
          : null;

      return LLMException(
        name: name,
        endpoint: endpoint,
        requestBody: bodyStr,
        statusCode: statusCode,
        responseData: errorMsg,
        originalError: e,
      );
    } else {
      return LLMException(
        name: name,
        endpoint: endpoint,
        requestBody: bodyStr,
        originalError: e,
      );
    }
  }

  String getGenTitleModel() {
    final model = ProviderManager.chatModelProvider.currentModel;
    final providerSetting =
        ProviderManager.settingsProvider.getProviderSetting(model.providerId);
    return providerSetting.genTitleModel != null &&
            providerSetting.genTitleModel!.isNotEmpty
        ? providerSetting.genTitleModel!
        : model.name;
  }

  Future<String> genTitle(List<ChatMessage> messages) async {
    final conversationText = messages.map((msg) {
      final role = msg.role == MessageRole.user ? "Human" : "Assistant";
      return "$role: ${msg.content}";
    }).join("\n");

    try {
      final prompt = ChatMessage(
        role: MessageRole.user,
        content:
            """You are a conversation title generator. Generate a concise title (max 20 characters) for the following conversation.
The title should summarize the main topic. Return only the title without any explanation or extra punctuation.

Conversation:
$conversationText""",
      );

      final response = await chatCompletion(CompletionRequest(
        model: getGenTitleModel(),
        messages: [prompt],
      ));

      return response.content?.trim() ?? "New Chat";
    } catch (e, trace) {
      Logger.root.severe('OpenAI gen title error: $e, trace: $trace');
      return "New Chat";
    }
  }

  Future<List<String>> models();
}

class LLMException implements Exception {
  final String name;
  final String endpoint;
  final String requestBody;
  final int? statusCode;
  final dynamic responseData;
  final dynamic originalError;

  LLMException({
    required this.name,
    required this.endpoint,
    required this.requestBody,
    this.statusCode,
    this.responseData,
    this.originalError,
  });

  @override
  String toString() {
    return '''
$name API call failed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Endpoint: $endpoint
${statusCode != null ? 'Status code: $statusCode\n' : ''}Request body: $requestBody
${responseData != null ? 'Response data: $responseData\n' : ''}Error message: $originalError
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''';
  }
}
