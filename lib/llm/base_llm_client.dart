import 'model.dart';
import 'utils.dart';

abstract class BaseLLMClient {
  Future<LLMResponse> chatCompletion(
    List<ChatMessage> messages, {
    List<Map<String, dynamic>>? tools,
  });

  Stream<LLMResponse> chatStreamCompletion(
    List<ChatMessage> messages, {
    List<Map<String, dynamic>>? tools,
  });

  Future<Map<String, dynamic>> checkToolCall(
    String content,
    Map<String, List<Map<String, dynamic>>> toolsResponse,
  ) async {
    final openaiTools = convertToOpenAITools(toolsResponse);

    final response = await chatCompletion(
      [ChatMessage(role: MessageRole.user, content: content)],
      tools: openaiTools,
    );

    if (!response.needToolCall) {
      return {
        'need_tool_call': false,
        'content': response.content,
      };
    }

    // 返回工具调用详情
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
  }
}
