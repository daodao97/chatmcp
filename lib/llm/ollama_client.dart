import 'package:http/http.dart' as http;
import 'base_llm_client.dart';
import 'dart:convert';
import 'model.dart';
import 'package:logging/logging.dart';

class OllamaClient extends BaseLLMClient {
  final String baseUrl;
  final Map<String, String> _headers;

  OllamaClient({
    String? baseUrl,
  })  : baseUrl = (baseUrl == null || baseUrl.isEmpty)
            ? 'http://localhost:11434'
            : baseUrl,
        _headers = {
          'Content-Type': 'application/json',
        };

  @override
  Future<List<String>> models() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/tags"),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      final data = jsonDecode(response.body);
      final modelsList = data['models'] as List;
      return modelsList.map((model) => (model['name'] as String)).toList();
    } catch (e, trace) {
      Logger.root.severe('Failed to get model list: $e, trace: $trace');
      return [];
    }
  }

  @override
  Future<LLMResponse> chatCompletion(CompletionRequest request) async {
    final messages = request.messages.map((m) {
      final role = m.role == MessageRole.user ? 'user' : 'assistant';
      return {
        'role': role,
        'content': m.content,
      };
    }).toList();

    final body = {
      'model': request.model,
      'messages': messages,
      'stream': false,
    };

    if (request.tools != null && request.tools!.isNotEmpty) {
      body['tools'] = request.tools!;
    }

    final bodyStr = jsonEncode(body);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/v1/chat/completions"),
        headers: _headers,
        body: bodyStr,
      );

      final responseBody = utf8.decode(response.bodyBytes);
      Logger.root.fine('Ollama request: $bodyStr');
      Logger.root.fine('Ollama response: $responseBody');

      final jsonData = jsonDecode(responseBody);

      if (response.statusCode >= 400) {
        throw Exception('HTTP ${response.statusCode}: $responseBody');
      }

      final message = jsonData['choices'][0]['message'];

      // Parse tool calls
      final toolCalls = message['tool_calls']
          ?.map<ToolCall>((t) => ToolCall(
                id: t['id'] ?? '',
                type: 'function',
                function: FunctionCall(
                  name: t['function']['name'],
                  arguments: jsonEncode(t['function']['arguments']),
                ),
              ))
          ?.toList();

      return LLMResponse(
        content: message['content'] ?? '',
        toolCalls: toolCalls,
      );
    } catch (e) {
      throw await handleError(
          e, 'Ollama', '$baseUrl/v1/chat/completions', bodyStr);
    }
  }

  @override
  Stream<LLMResponse> chatStreamCompletion(CompletionRequest request) async* {
    final messages = request.messages.map((m) {
      final role = m.role == MessageRole.user ? 'user' : 'assistant';
      return {
        'role': role,
        'content': m.content,
      };
    }).toList();

    final body = {
      'model': request.model,
      'messages': messages,
      'stream': true,
    };

    if (request.tools != null && request.tools!.isNotEmpty) {
      body['tools'] = request.tools!;
      body['tool_choice'] = 'auto';
    }

    try {
      final request =
          http.Request('POST', Uri.parse("$baseUrl/v1/chat/completions"));
      request.headers.addAll(_headers);
      request.body = jsonEncode(body);

      final response = await http.Client().send(request);

      if (response.statusCode >= 400) {
        final responseBody = await response.stream.bytesToString();
        Logger.root.fine('Ollama response: $responseBody');

        throw Exception('HTTP ${response.statusCode}: $responseBody');
      }

      final stream = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in stream) {
        if (!line.startsWith('data: ')) continue;
        final jsonStr = line.substring(6).trim();
        if (jsonStr.isEmpty || jsonStr == '[DONE]') continue;

        try {
          final json = jsonDecode(jsonStr);

          // Check if the choices array is empty
          if (json['choices'] == null || json['choices'].isEmpty) {
            continue;
          }

          final delta = json['choices'][0]['delta'];
          if (delta == null) continue;

          // Parse tool calls
          final toolCalls = delta['tool_calls']
              ?.map<ToolCall>((t) => ToolCall(
                    id: t['id'] ?? '',
                    type: 'function',
                    function: FunctionCall(
                      name: t['function']?['name'] ?? '',
                      arguments: jsonEncode(t['function']?['arguments'] ?? {}),
                    ),
                  ))
              ?.toList();

          // Only yield when content is not empty or there are tool calls
          if (delta['content'] != null || toolCalls != null) {
            yield LLMResponse(
              content: delta['content'],
              toolCalls: toolCalls,
            );
          }
        } catch (e) {
          Logger.root.severe('Failed to parse stream chunk: $jsonStr $e');
          continue;
        }
      }
    } catch (e) {
      throw await handleError(
          e, 'Ollama', "$baseUrl/v1/chat/completions", jsonEncode(body));
    }
  }
}
