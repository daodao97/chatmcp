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
      List<dynamic> contentBlocks = json['content'];
      String? textualContent;
      List<ToolCall>? toolCalls;
      String? rawToolCallXml;
      bool needsXmlParsing = false;

      // Check for structured tool calls first
      if (json.containsKey('tool_calls') && json['tool_calls'] != null) {
        toolCalls = (json['tool_calls'] as List)
            .map<ToolCall>((t) => ToolCall(
                  id: t['id'],
                  type: t['type'],
                  function: FunctionCall(
                    name: t['function']['name'],
                    arguments: t['function']['arguments'],
                  ),
                ))
            .toList();
        // If structured tool calls are present, textual content is usually separate or null
        final textBlock = contentBlocks.firstWhere((block) => block['type'] == 'text', orElse: () => null);
        textualContent = textBlock?['text'];
      } else {
        // No structured tool_calls, check for XML in text content
        // Consolidate text from content blocks
        StringBuffer fullTextContent = StringBuffer();
        for (var block in contentBlocks) {
          if (block['type'] == 'text' && block['text'] != null) {
            fullTextContent.write(block['text']);
          }
        }
        String combinedText = fullTextContent.toString();

        // Check for XML tool call patterns
        final functionCallsStart = combinedText.indexOf('<function_calls>');
        final functionCallsEnd = combinedText.indexOf('</function_calls>');
        final invokeStart = combinedText.indexOf('<invoke>');
        final invokeEnd = combinedText.indexOf('</invoke>');

        if (functionCallsStart != -1 && functionCallsEnd != -1) {
          rawToolCallXml = combinedText.substring(functionCallsStart, functionCallsEnd + '</function_calls>'.length);
          needsXmlParsing = true;
          textualContent = combinedText.substring(0, functionCallsStart) + combinedText.substring(functionCallsEnd + '</function_calls>'.length);
        } else if (invokeStart != -1 && invokeEnd != -1) {
          rawToolCallXml = combinedText.substring(invokeStart, invokeEnd + '</invoke>'.length);
          needsXmlParsing = true;
          textualContent = combinedText.substring(0, invokeStart) + combinedText.substring(invokeEnd + '</invoke>'.length);
        } else {
          textualContent = combinedText;
        }
        // Ensure textualContent is null if empty after extraction
        if (textualContent != null && textualContent.trim().isEmpty) {
            textualContent = null;
        }
      }

      return LLMResponse(
        content: textualContent,
        toolCalls: toolCalls,
        rawToolCallXml: rawToolCallXml,
        needsXmlParsing: needsXmlParsing,
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

      String? currentContent;
      List<ToolCall>? currentToolCalls;
      StringBuffer rawToolCallXmlBuffer = StringBuffer();
      bool currentlyNeedsXmlParsing = false;
      String? activeToolCallId; // For structured streaming tool calls

      await for (final line in stream) {
        if (!line.startsWith('data:')) continue;

        final jsonStr = line.substring(5).trim();
        if (jsonStr.isEmpty) continue;

        try {
          final event = jsonDecode(jsonStr);
          final eventType = event['type'];

          // Logger.root.fine('Claude stream event: $eventType, data: $jsonStr');

          switch (eventType) {
            case 'message_start':
              // Potentially initialize things if needed
              break;

            case 'content_block_start':
              final contentType = event['content_block']?['type'];
              if (contentType == 'tool_use') {
                // Start of a structured tool call
                activeToolCallId = event['content_block']?['id'];
                // We don't yield yet, wait for deltas or stop
              } else if (contentType == 'text') {
                // Potentially the start of text that might contain XML
                 currentContent = event['content_block']?['text'] ?? "";
              }
              break;

            case 'content_block_delta':
              final delta = event['delta'];
              if (delta == null) break;

              final deltaType = delta['type'];
              if (deltaType == 'text_delta' && delta['text'] != null) {
                currentContent = (currentContent ?? "") + delta['text'];
                // Check for XML tags
                if (!currentlyNeedsXmlParsing) {
                  if (currentContent!.contains('<invoke>') || currentContent!.contains('<function_calls>')) {
                    currentlyNeedsXmlParsing = true;
                  }
                }
                if (currentlyNeedsXmlParsing) {
                  rawToolCallXmlBuffer.write(delta['text']);
                }
                yield LLMResponse(
                  content: currentlyNeedsXmlParsing ? null : delta['text'], // Yield only new text if not parsing XML here
                  rawToolCallXml: currentlyNeedsXmlParsing ? rawToolCallXmlBuffer.toString() : null,
                  needsXmlParsing: currentlyNeedsXmlParsing,
                );
              } else if (deltaType == 'input_json_delta' && activeToolCallId != null) {
                // Part of a structured tool call's arguments
                // This part is complex as we need to accumulate the json.
                // For now, we acknowledge it. Actual parsing might need to happen at 'content_block_stop' or 'message_stop'.
                // The current LLMResponse model doesn't perfectly support streaming structured tool calls' arguments.
                // We will prioritize XML parsing for now as per the task.
                // TODO: Enhance structured tool call streaming.
              }
              break;

            case 'content_block_stop':
              final contentBlock = event['content_block'];
               if (contentBlock != null && contentBlock['type'] == 'tool_use' && activeToolCallId != null) {
                // This is where a structured tool call block ends.
                // However, Claude sends tool_calls in full at the 'message_delta' or 'message_stop' with 'stop_reason': 'tool_use'
                // So, we might not need to do much here if we rely on the final message assembly for structured tools.
                // For now, just reset activeToolCallId.
                activeToolCallId = null;
              }
              // If we were accumulating XML and this block is text, we might yield here.
              // However, the current delta logic tries to yield incrementally.
              break;

            case 'message_delta':
              // This event can contain the full tool_calls array if stop_reason is 'tool_use'
              if (event['delta']?['stop_reason'] == 'tool_use' && event['usage']?['output_tokens'] != null) {
                  // The 'message' event that Anthropic sends *after* all content blocks when stop_reason is 'tool_use'
                  // often contains the full tool_calls. However, the prompt asks to handle XML primarily.
                  // Let's check if the full message (not delta) contains tool_calls.
                  // This part is tricky as the prompt implies we get tool_calls in the *final* non-streamed response.
                  // For streaming, if we see this stop_reason, it's a strong hint.
                  // The main task is about XML, so we ensure needsXmlParsing is set if XML was seen.
                  // If structured tool calls were also somehow streamed (less common for Claude), they'd be in currentToolCalls.
              }
              // We might yield a final consolidated response here if needed,
              // but individual deltas should have handled most content.
              break;

            case 'message_stop':
              // This is the definitive end of the message.
              // If XML was being parsed, the rawToolCallXmlBuffer should contain it.
              // Yield a final response if there's anything pending.
              // The problem is that the current model yields LLMResponse for each delta.
              // A "final" yield here might be redundant if all content was processed.
              // However, this is a good place to ensure flags are correctly set based on overall stream.
              if (currentlyNeedsXmlParsing && rawToolCallXmlBuffer.isNotEmpty) {
                // This is tricky. If content was already yielded incrementally, what do we yield here?
                // The prompt focuses on identifying the *need* for XML parsing.
                // Perhaps a final LLMResponse that summarizes this need.
                // For now, the incremental yields should have set needsXmlParsing.
              }
              // Reset for next potential message in a session (if applicable)
              currentContent = null;
              currentToolCalls = null;
              rawToolCallXmlBuffer.clear();
              currentlyNeedsXmlParsing = false;
              activeToolCallId = null;
              break;

            case 'error':
              final error = event['error'];
              throw Exception('Stream error: ${error['message']}');

            case 'ping':
              // Ignore ping events
              break;
            default:
              // Logger.root.info('Unknown Claude stream event: $eventType');
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
