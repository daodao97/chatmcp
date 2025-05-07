import 'package:http/http.dart' as http;
import 'dart:convert';
import 'base_llm_client.dart';
import 'model.dart';
import 'package:logging/logging.dart';
import 'package:chatmcp/provider/provider_manager.dart';
import 'package:chatmcp/utils/file_content.dart';

class ClaudeClient extends BaseLLMClient {
  final String apiKey;
  String baseUrl;
  final Map<String, String> _headers;

  ClaudeClient({
    required this.apiKey,
    String? baseUrl,
  })  : baseUrl = (baseUrl == null || baseUrl.isEmpty)
            ? 'https://api.anthropic.com/v1'
            : baseUrl,
        _headers = {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
        };

  @override
  Future<LLMResponse> chatCompletion(CompletionRequest request) async {
    final messages = chatMessageToClaudeMessage(request.messages);

    final body = {
      'model': request.model,
      'messages': messages,
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
      body['tools'] = {
        'function_calling': {
          'tools': request.tools,
        }
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: _headers,
        body: jsonEncode(body),
      );

      final responseBody = utf8.decode(response.bodyBytes);
      Logger.root.fine('Claude response: $responseBody');

      if (response.statusCode >= 400) {
        throw Exception('HTTP ${response.statusCode}: $responseBody');
      }

      final json = jsonDecode(responseBody);
      final content = json['content'][0]['text'];

      // Parse tool calls if present
      final toolCalls = json['tool_calls']
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
        content: content,
        toolCalls: toolCalls,
      );
    } catch (e) {
      throw Exception(
          "Claude API call failed: $baseUrl/messages body: ${jsonEncode(body)} error: $e");
    }
  }

  @override
  Stream<LLMResponse> chatStreamCompletion(CompletionRequest request) async* {
    final messages = chatMessageToClaudeMessage(request.messages);

    final body = {
      'model': request.model,
      'messages': messages,
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

    if (request.tools != null && request.tools!.isNotEmpty) {
      body['tools'] = {
        'function_calling': {
          'tools': request.tools,
        }
      };
      body['tool_choice'] = {'type': 'any'};
    }

    try {
      final request = http.Request('POST', Uri.parse('$baseUrl/messages'));
      request.headers.addAll(_headers);
      request.body = jsonEncode(body);

      final response = await http.Client().send(request);

      if (response.statusCode >= 400) {
        final responseBody = await response.stream.bytesToString();
        Logger.root.fine('Claude response: $responseBody');

        throw Exception('HTTP ${response.statusCode}: $responseBody');
      }
      final stream = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in stream) {
        if (!line.startsWith('data:')) continue;

        final jsonStr = line.substring(5).trim();
        if (jsonStr.isEmpty) continue;

        try {
          final event = jsonDecode(jsonStr);
          final eventType = event['type'];

          switch (eventType) {
            case 'content_block_start':
              if (event['content_block'] != null &&
                  event['content_block']['text'] != null) {
                yield LLMResponse(content: event['content_block']['text']);
              } else {
                Logger.root
                    .warning('Invalid content_block_start event: $event');
              }
              break;
            case 'content_block_delta':
              final delta = event['delta'];
              if (delta == null) {
                Logger.root
                    .warning('Invalid content_block_delta event: $event');
                break;
              }

              // Handle text content directly
              if (delta['text'] != null) {
                yield LLMResponse(content: delta['text']);
                break;
              }

              // Handle specific types of delta
              if (delta['type'] == 'text_delta' && delta['text'] != null) {
                yield LLMResponse(content: delta['text']);
              } else if (delta['type'] == 'input_json_delta') {
                // Handle tool use delta
                // final partialJson = delta['partial_json'];
                // You may want to accumulate the JSON and parse it when complete
              }
              break;

            case 'content_block_stop':
              // Handle end of a content block
              break;

            case 'message_stop':
              // Handle end of message
              break;

            case 'error':
              final error = event['error'];
              throw Exception('Stream error: ${error['message']}');

            case 'ping':
              // Ignore ping events
              break;
          }
        } catch (e) {
          Logger.root.warning('Failed to parse chunk: $jsonStr error: $e');
          continue;
        }
      }
    } catch (e) {
      throw await handleError(
          e, 'Claude', '$baseUrl/messages', jsonEncode(body));
    }
  }

  @override
  Future<Map<String, dynamic>> checkToolCall(
    String model,
    CompletionRequest request,
    Map<String, List<Map<String, dynamic>>> toolsResponse,
  ) async {
    // Convert tools to Claude's format
    final tools = toolsResponse.entries
        .map((entry) {
          return entry.value.map((tool) {
            final parameters = tool['parameters'];
            if (parameters is! Map<String, dynamic>) {
              return {
                'name': tool['name'],
                'description': tool['description'],
                'input_schema': {
                  'type': 'object',
                  'properties': {},
                  'required': [],
                },
              };
            }

            return {
              'name': tool['name'],
              'description': tool['description'],
              'input_schema': {
                'type': 'object',
                'properties': parameters['properties'] ?? {},
                'required': parameters['required'] ?? [],
              },
            };
          }).toList();
        })
        .expand((x) => x)
        .toList();

    final body = {
      'model': ProviderManager.chatModelProvider.currentModel.name,
      'messages': request.messages,
      'tools': tools,
      'max_tokens': 4096,
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      final jsonData = jsonDecode(response.body);

      // Check if response contains tool calls in the content array
      final contentBlocks = jsonData['content'] as List?;
      if (contentBlocks == null || contentBlocks.isEmpty) {
        return {
          'need_tool_call': false,
          'content': '',
        };
      }

      // Look for tool_calls in the response
      final toolUseBlocks = contentBlocks.where((block) =>
          block['type'] == 'tool_calls' || block['type'] == 'tool_use');

      if (toolUseBlocks.isEmpty) {
        // Get text content from the first text block
        final textBlock = contentBlocks.firstWhere(
          (block) => block['type'] == 'text',
          orElse: () => {'text': ''},
        );
        return {
          'need_tool_call': false,
          'content': textBlock['text'] ?? '',
        };
      }

      // Extract tool calls
      final toolCalls = toolUseBlocks
          .map((block) => {
                'id': block['id'],
                'name': block['name'],
                'arguments': block['input'],
              })
          .toList();

      // Get any accompanying text content
      final textBlock = contentBlocks.firstWhere(
        (block) => block['type'] == 'text',
        orElse: () => {'text': ''},
      );

      return {
        'need_tool_call': true,
        'content': textBlock['text'] ?? '',
        'tool_calls': toolCalls,
      };
    } catch (e) {
      throw await handleError(
          e, 'Claude', '$baseUrl/messages', jsonEncode(body));
    }
  }

  @override
  Future<List<String>> models() async {
    if (apiKey.isEmpty) {
      Logger.root.info('Claude API key not set, skipping model list retrieval');
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/models'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      final data = jsonDecode(response.body);
      final models = (data['data'] as List)
          .map((m) => m['id'].toString())
          .where((id) => id.contains('claude'))
          .toList();

      return models;
    } catch (e, trace) {
      Logger.root.severe('Failed to get model list: $e, trace: $trace');
      return [];
    }
  }
}

List<Map<String, dynamic>> chatMessageToClaudeMessage(
    List<ChatMessage> messages) {
  return messages.map((message) {
    final List<Map<String, dynamic>> contentParts = [];

    // Add file content (if any)
    if (message.files != null) {
      for (final file in message.files!) {
        if (isImageFile(file.fileType)) {
          contentParts.add({
            'type': 'image',
            'source': {
              'type': 'base64',
              'media_type': file.fileType,
              'data': file.fileContent,
            },
          });
        }
        if (isTextFile(file.fileType)) {
          contentParts.add({
            'type': 'text',
            'text': file.fileContent,
          });
        }
      }
    }

    // Add text content
    if (message.content != null) {
      contentParts.add({
        'type': 'text',
        'text': message.content,
      });
    }

    final json = {
      'role': message.role == MessageRole.user ? 'user' : 'assistant',
      'content': contentParts,
    };

    if (contentParts.length == 1 && message.files == null) {
      json['content'] = message.content ?? '';
    } else {
      json['content'] = contentParts;
    }

    return json;
  }).toList();
}
