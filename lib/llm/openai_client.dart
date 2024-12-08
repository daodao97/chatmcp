import 'package:dio/dio.dart';
import 'base_llm_client.dart';
import 'dart:convert';
import 'model.dart';

class OpenAIClient extends BaseLLMClient {
  final String apiKey;
  final String baseUrl = 'https://api.openai.com/v1/chat/completions';
  final Dio _dio;

  OpenAIClient({required this.apiKey, Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $apiKey',
              },
              responseType: ResponseType.stream,
            ));

  @override
  Future<LLMResponse> chatCompletion(
    List<ChatMessage> messages, {
    List<Map<String, dynamic>>? tools,
  }) async {
    try {
      final response = await _dio.post(
        baseUrl,
        data: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': messages.map((m) => m.toJson()).toList(),
          if (tools != null) 'tools': tools,
          if (tools != null) 'tool_choice': 'auto',
        }),
      );

      // 处理流数据
      final buffer = StringBuffer();

      await for (final chunk in response.data.stream) {
        buffer.write(utf8.decode(chunk));
      }

      final responseBody = buffer.toString();
      final json = jsonDecode(responseBody);

      final message = json['choices'][0]['message'];

      // 解析工具调用
      final toolCalls = message['tool_calls']
          ?.map<ToolCall>((t) => ToolCall(
                id: t['id'],
                type: t['type'],
                function: FunctionCall(
                  name: t['function']['name'],
                  arguments: t['function']['arguments'],
                ),
              ))
          ?.toList();

      return LLMResponse(
        content: message['content'],
        toolCalls: toolCalls,
      );
    } catch (e) {
      print('Failed to get response: $e');
      throw Exception('Failed to get response: $e');
    }
  }

  @override
  Stream<LLMResponse> chatStreamCompletion(
    List<ChatMessage> messages, {
    List<Map<String, dynamic>>? tools,
  }) async* {
    try {
      final response = await _dio.post(
        baseUrl,
        data: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': messages.map((m) => m.toJson()).toList(),
          'stream': true,
        }),
      );

      String buffer = '';
      await for (final chunk in response.data.stream) {
        final decodedChunk = utf8.decode(chunk);
        buffer += decodedChunk;

        // 处理可能的多行数据
        while (buffer.contains('\n')) {
          final index = buffer.indexOf('\n');
          final line = buffer.substring(0, index).trim();
          buffer = buffer.substring(index + 1);

          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6).trim();
            if (jsonStr.isEmpty || jsonStr == '[DONE]') continue;

            try {
              final json = jsonDecode(jsonStr);
              final delta = json['choices'][0]['delta'];
              if (delta == null) continue;

              // 解析工具调用
              final toolCalls = delta['tool_calls']
                  ?.map<ToolCall>((t) => ToolCall(
                        id: t['id'] ?? '',
                        type: t['type'] ?? '',
                        function: FunctionCall(
                          name: t['function']?['name'] ?? '',
                          arguments: t['function']?['arguments'] ?? '{}',
                        ),
                      ))
                  ?.toList();

              yield LLMResponse(
                content: delta['content'],
                toolCalls: toolCalls,
              );
            } catch (e) {
              print('Failed to parse chunk: $jsonStr');
              print('Error: $e');
              continue;
            }
          }
        }
      }
    } catch (e) {
      print('Stream completion failed: $e');
      throw Exception('Stream completion failed: $e');
    }
  }
}
