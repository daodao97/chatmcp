import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:jsonc/jsonc.dart';
import 'model.dart'; // For ToolCall, FunctionCall

class ToolCallParser {
  // Regex to match <function name="tool_name">{json_arguments}</function>
  // Ensures dotAll: true for multi-line JSON arguments.
  static final RegExp _functionTagRegex = RegExp(
    r'<function\s+name=["\']([^"\']*)["\']\s*>(.*?)</function>',
    dotAll: true,
  );

  List<ToolCall> parseXmlToolCalls(String text) {
    final List<ToolCall> parsedCalls = [];
    final matches = _functionTagRegex.allMatches(text);

    for (final match in matches) {
      final String? toolName = match.group(1);
      final String? toolArgumentsJson = match.group(2);

      if (toolName == null || toolArgumentsJson == null) {
        Logger.root.warning('Failed to extract tool name or arguments from match: ${match.input.substring(match.start, match.end)}');
        continue;
      }

      final String cleanedArgs = toolArgumentsJson
          .replaceAll('\r\n', ' ')
          .replaceAll('\n', ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      try {
        final dynamic decodedJson = jsonc.decode(cleanedArgs);

        Map<String, dynamic> argumentsMap;
        if (decodedJson is Map) {
          // If it's already a Map, try to cast its keys and values if necessary.
          // JSON objects should have String keys. Values can be dynamic.
          try {
            argumentsMap = Map<String, dynamic>.from(decodedJson);
          } catch (e) {
             Logger.root.warning(
              'Tool arguments for "$toolName" could not be cast to Map<String, dynamic>. Raw: $cleanedArgs. Parsed: $decodedJson. Error: $e. Skipping this tool call.',
            );
            continue;
          }
        } else {
          Logger.root.warning(
            'Tool arguments for "$toolName" are valid JSON but not a JSON object (expected a Map). Raw: $cleanedArgs. Parsed type: ${decodedJson.runtimeType}. Skipping this tool call.',
          );
          continue; // Skip this tool call as arguments are not a JSON object
        }

        final String uniqueId = 'tool_call_${DateTime.now().millisecondsSinceEpoch}_${parsedCalls.length}';

        final toolCall = ToolCall(
          id: uniqueId,
          type: 'function',
          function: FunctionCall(
            name: toolName,
            // Re-encode the parsed map to ensure it's a valid, minified JSON string for the FunctionCall arguments.
            arguments: jsonEncode(argumentsMap),
          ),
        );
        parsedCalls.add(toolCall);

      } catch (e, stackTrace) {
        Logger.root.warning(
          'Failed to parse JSON arguments for tool "$toolName". Error: $e\nCleaned Args: "$cleanedArgs"\nOriginal Args: "$toolArgumentsJson"\nStackTrace: $stackTrace',
        );
        // Continue to the next match, do not let a single malformed call stop others.
      }
    }
    return parsedCalls;
  }
}
