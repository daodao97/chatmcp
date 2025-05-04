import 'package:http/http.dart' as http;
import 'base_llm_client.dart';
import 'dart:convert';
import 'model.dart';
import 'package:logging/logging.dart';
import './openai_client.dart';

class DeepSeekClient extends BaseLLMClient {
  final String apiKey;
  String baseUrl;
  final Map<String, String> _headers;

  DeepSeekClient({
    required this.apiKey,
    String? baseUrl,
  })  : baseUrl = (baseUrl == null || baseUrl.isEmpty)
            ? 'https://api.deepseek.com/v1'
            : baseUrl,
        _headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        };

  @override
  Future<LLMResponse> chatCompletion(CompletionRequest request) async {
    final body = {
      'model': request.model,
      'messages': chatMessageToOpenAIMessage(request.messages),
    };
    if (request.modelSetting != null) {
      body['temperature'] = request.modelSetting!.temperature;
      body['top_p'] = request.modelSetting!.topP;
      body['frequency_penalty'] = request.modelSetting!.frequencyPenalty;
      body['presence_penalty'] = request.modelSetting!.presencePenalty;
      if (request.modelSetting!.maxTokens != null) {
        body['max_tokens'] = request.modelSetting!.maxTokens!;
      }
    }

    if (request.tools != null && request.tools!.isNotEmpty) {
      body['tools'] = request.tools!;
      body['tool_choice'] = 'auto';
    }

    final bodyStr = jsonEncode(body);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/chat/completions"),
        headers: _headers,
        body: bodyStr,
      );

      final responseBody = utf8.decode(response.bodyBytes);
      Logger.root.fine('DeepSeek response: $responseBody');

      if (response.statusCode >= 400) {
        throw Exception('HTTP ${response.statusCode}: $responseBody');
      }

      final jsonData = jsonDecode(responseBody);
      final message = jsonData['choices'][0]['message'];

      // Parse tool calls
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
      throw await handleError(
          e, 'DeepSeek', '$baseUrl/chat/completions', jsonEncode(body));
    }
  }

  @override
  Stream<LLMResponse> chatStreamCompletion(CompletionRequest request) async* {
    final body = {
      'model': request.model,
      'messages': chatMessageToOpenAIMessage(request.messages),
      'stream': true,
    };
    if (request.modelSetting != null) {
      body['temperature'] = request.modelSetting!.temperature;
      body['top_p'] = request.modelSetting!.topP;
      body['frequency_penalty'] = request.modelSetting!.frequencyPenalty;
      body['presence_penalty'] = request.modelSetting!.presencePenalty;
      if (request.modelSetting!.maxTokens != null) {
        body['max_tokens'] = request.modelSetting!.maxTokens!;
      }
    }

    try {
      Logger.root.info('deepseek request chat stream completion: $body');
      final request =
          http.Request('POST', Uri.parse('$baseUrl/chat/completions'));
      request.headers.addAll(_headers);
      request.body = jsonEncode(body);

      final response = await http.Client().send(request);

      if (response.statusCode >= 400) {
        final responseBody = await response.stream.bytesToString();
        Logger.root.fine('DeepSeek response: $responseBody');

        throw Exception('HTTP ${response.statusCode}: $responseBody');
      }

      final stream = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      Logger.root.info('deepseek start stream response');
      String buffer = '';
      bool reasoningContentStart = false;
      bool reasoningContentEnd = false;
      bool reasoningStyle = false;

      await for (final line in stream) {
        if (!line.startsWith('data: ')) continue;
        final jsonStr = line.substring(6).trim();
        if (jsonStr.isEmpty || jsonStr == '[DONE]') continue;

        try {
          final json = jsonDecode(jsonStr);

          // Check if choices array is empty
          if (json['choices'] == null ||
              json['choices'].isEmpty ||
              json['choices'].length < 1) {
            continue;
          }

          final delta = json['choices'][0]['delta'];
          if (delta == null) continue;

          // Parse tool calls
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

          final reasoningContent =
              delta != null ? (delta['reasoning_content'] ?? '') : '';

          if (reasoningContent.isNotEmpty) {
            reasoningStyle = true;
            if (!reasoningContentStart) {
              reasoningContentStart = true;
              yield LLMResponse(
                content:
                    '\n<think start-time="${DateTime.now().toIso8601String()}">\n$reasoningContent',
                toolCalls: toolCalls,
              );
            } else {
              yield LLMResponse(
                content: reasoningContent,
                toolCalls: toolCalls,
              );
            }
          }

          if (reasoningStyle) {
            final content = delta != null ? (delta['content'] ?? '') : '';
            if (content.isNotEmpty) {
              if (!reasoningContentEnd) {
                reasoningContentEnd = true;
                yield LLMResponse(
                  content:
                      '\n</think end-time="${DateTime.now().toIso8601String()}">\n$content',
                  toolCalls: toolCalls,
                );
              } else {
                yield LLMResponse(
                  content: content,
                  toolCalls: toolCalls,
                );
              }
            }
          } else {
            // Only yield response when there is content or tool calls
            if (delta != null && delta['content'] != null) {
              String content = delta != null ? (delta['content'] ?? '') : '';
              if (content.isNotEmpty && content.contains('<think>')) {
                content = content.replaceAll('<think>',
                    '<think start-time="${DateTime.now().toIso8601String()}">');
              }
              if (content.isNotEmpty && content.contains('</think>')) {
                content = content.replaceAll('</think>',
                    '</think end-time="${DateTime.now().toIso8601String()}">');
              }

              yield LLMResponse(
                content: content,
                toolCalls: toolCalls,
              );
            }
          }
        } catch (e, trace) {
          Logger.root.severe(
              'Failed to parse chunk: $jsonStr, error: $e, trace: $trace');
          continue;
        }
      }
    } catch (e, trace) {
      Logger.root.severe('DeepSeek stream completion error: $e, trace: $trace');
      throw await handleError(
          e, 'DeepSeek', '$baseUrl/chat/completions', jsonEncode(body));
    }
  }

  @override
  Future<List<String>> models() async {
    if (apiKey.isEmpty) {
      Logger.root
          .info('DeepSeek API key not set, skipping model list retrieval');
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/models"),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      final data = jsonDecode(response.body);
      final models = (data['data'] as List)
          .map((m) => m['id'].toString())
          .where((id) => id.contains('deepseek'))
          .toList();

      return models;
    } catch (e, trace) {
      Logger.root.severe('Failed to get model list: $e, trace: $trace');
      return [];
    }
  }
}
