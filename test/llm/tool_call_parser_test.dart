import 'package:chatmcp/llm/tool_call_parser.dart';
import 'package:chatmcp/llm/model.dart'; // For ToolCall, FunctionCall
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart'; // For Logger
import 'dart:convert'; // For jsonEncode, jsonDecode

void main() {
  group('ToolCallParser', () {
    late ToolCallParser parser;
    List<LogRecord> capturedLogs;
    Logger? loggerInstance; // Holder for the specific logger instance if needed for more complex scenarios

    setUp(() {
      parser = ToolCallParser();
      capturedLogs = [];
      // It's better to listen to the specific logger if possible, or a known parent.
      // For simplicity, using Logger.root, but in a large app, you might have a dedicated logger.
      loggerInstance = Logger.root; // Or Logger('ToolCallParser') if it used its own logger
      loggerInstance?.level = Level.ALL;
      loggerInstance?.onRecord.listen((record) {
        capturedLogs.add(record);
      });
    });

    tearDown(() {
      // Important to clear listeners to prevent them from affecting other tests
      // or accumulating logs from other test groups.
      loggerInstance?.clearListeners();
      // Reset level if it was changed, though Level.ALL is often default for tests.
      // Logger.root.level = Level.INFO;
    });

    test('should parse a single valid tool call', () {
      const xml = '<function name="get_weather">{\"location\": \"Boston\", \"unit\": \"celsius\"}</function>';
      final result = parser.parseXmlToolCalls(xml);
      expect(result.length, 1);
      expect(result[0].function.name, 'get_weather');
      final args = jsonDecode(result[0].function.arguments);
      expect(args['location'], 'Boston');
      expect(args['unit'], 'celsius');
      expect(result[0].type, 'function');
      expect(result[0].id, startsWith('tool_call_'));
    });

    test('should parse multiple valid tool calls', () {
      const xml =
          '<function name="get_weather">{\"location\": \"Tokyo\"}</function>\n'
          '<function name="get_stock_price">{\"ticker\": \"GOOG\"}</function>';
      final result = parser.parseXmlToolCalls(xml);
      expect(result.length, 2);

      expect(result[0].function.name, 'get_weather');
      expect(jsonDecode(result[0].function.arguments)['location'], 'Tokyo');

      expect(result[1].function.name, 'get_stock_price');
      expect(jsonDecode(result[1].function.arguments)['ticker'], 'GOOG');

      expect(result[0].id, isNot(equals(result[1].id)));
    });

    test('should parse a tool call with empty JSON object arguments', () {
      const xml = '<function name="trigger_event">{}</function>';
      final result = parser.parseXmlToolCalls(xml);
      expect(result.length, 1);
      expect(result[0].function.name, 'trigger_event');
      expect(jsonDecode(result[0].function.arguments), isEmpty);
    });

    test('should handle XML with no tool calls', () {
      const xml = '<note>This is not a tool call.</note><text>Some other text</text>';
      final result = parser.parseXmlToolCalls(xml);
      expect(result.isEmpty, isTrue);
      expect(capturedLogs.where((r) => r.level == Level.WARNING).isEmpty, isTrue);
    });

    test('should handle XML with a malformed tool call tag (missing name)', () {
      const xml = '<function>{\"location\": \"Boston\"}</function>';
      final result = parser.parseXmlToolCalls(xml);
      expect(result.isEmpty, isTrue);
      expect(capturedLogs.where((r) => r.level == Level.WARNING).length, 1);
      expect(capturedLogs.firstWhere((r) => r.level == Level.WARNING).message, contains('Failed to extract tool name or arguments'));
    });

    test('should handle a tool call with malformed JSON arguments (syntax error)', () {
      const xml = '<function name="submit_form">{\'name\': \'test\', \"value\":</function>'; // Invalid JSON: unquoted key, missing value
      final result = parser.parseXmlToolCalls(xml);
      expect(result.isEmpty, isTrue);
      final warningLogs = capturedLogs.where((r) => r.level == Level.WARNING).toList();
      expect(warningLogs.length, 1);
      expect(warningLogs[0].message, contains('Failed to parse JSON arguments for tool "submit_form"'));
      expect(warningLogs[0].message, contains('Error: FormatException:'));
    });

    test('should handle a tool call with JSONC features (comments, trailing commas)', () {
      const xml = '<function name="process_data">{/* some comment */ "key": "value",}</function>';
      final result = parser.parseXmlToolCalls(xml);
      expect(result.length, 1);
      expect(result[0].function.name, 'process_data');
      expect(jsonDecode(result[0].function.arguments)['key'], 'value');
    });

    test('should log warning and skip tool call if arguments are not a JSON object (e.g., a JSON array)', () {
      const xml = '<function name="set_config">[1, 2, 3]</function>';
      final result = parser.parseXmlToolCalls(xml);
      expect(result.isEmpty, isTrue);
      final warningLogs = capturedLogs.where((r) => r.level == Level.WARNING).toList();
      expect(warningLogs.length, 1);
      expect(warningLogs[0].message, contains('Tool arguments for "set_config" are valid JSON but not a JSON object'));
    });

    test('should log warning and skip tool call if arguments are a simple JSON string', () {
      const xml = '<function name="echo_message">"Hello World"</function>';
      final result = parser.parseXmlToolCalls(xml);
      expect(result.isEmpty, isTrue);
      final warningLogs = capturedLogs.where((r) => r.level == Level.WARNING).toList();
      expect(warningLogs.length, 1);
      expect(warningLogs[0].message, contains('Tool arguments for "echo_message" are valid JSON but not a JSON object'));
    });

    test('should handle tool calls with extra whitespace in and around XML tags and JSON content', () {
      const xml =
          '  <function name="get_weather" >\n'
          '    { \n'
          '      "location": "  New York  ", \n'
          '      "details" : true \n'
          '    } \n'
          '  </function>  ';
      final result = parser.parseXmlToolCalls(xml);
      expect(result.length, 1);
      expect(result[0].function.name, 'get_weather');
      final args = jsonDecode(result[0].function.arguments);
      expect(args['location'], '  New York  '); // Whitespace within JSON string values is preserved
      expect(args['details'], true);
    });

    test('should generate unique enough IDs for multiple calls in a single parse run', () {
      const xml =
          '<function name="tool1">{}</function>\n'
          '<function name="tool2">{}</function>\n'
          '<function name="tool3">{}</function>';
      final result = parser.parseXmlToolCalls(xml);
      expect(result.length, 3);
      final ids = result.map((tc) => tc.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'IDs should be unique');
    });

    test('should handle mixed valid and invalid tool calls', () {
      const xml =
          '<function name="valid_one">{\"key\": \"value\"}</function>\n'
          '<function name="invalid_json">{key_no_quotes: "value"}</function>\n'
          '<function name="valid_two">{}</function>\n'
          '<function name_typo="no_name_attr">{}</function>'; // This one won't be matched by regex due to name_typo

      final result = parser.parseXmlToolCalls(xml);
      expect(result.length, 2);
      expect(result[0].function.name, 'valid_one');
      expect(result[1].function.name, 'valid_two');

      final warningLogs = capturedLogs.where((r) => r.level == Level.WARNING).toList();
      // One for invalid_json, one for the tag with "name_typo" (if it was matched and failed, but regex might not match it)
      // The current regex `name=["\']` is strict on the attribute name. So "name_typo" won't be a match.
      // The `Failed to extract tool name or arguments` is for when the regex matches but groups are null.
      // So only one warning for "invalid_json".
      expect(warningLogs.length, 1);
      expect(warningLogs[0].message, contains('Failed to parse JSON arguments for tool "invalid_json"'));
    });

     test('should correctly parse arguments that are themselves JSON strings if wrapped in an object', () {
      // This tests if the re-encoding of arguments is robust.
      // If the tool expects a JSON string *as a value* in its arguments map.
      const innerJsonString = '{\"nestedKey\": \"nestedValue\"}';
      final Map<String, dynamic> argsMap = {'config_json': innerJsonString};
      final String argsString = jsonEncode(argsMap); // "{\"config_json\":\"{\\\"nestedKey\\\": \\\"nestedValue\\\"}\"}"

      final xml = '<function name="complex_args">$argsString</function>';
      final result = parser.parseXmlToolCalls(xml);
      expect(result.length, 1);
      expect(result[0].function.name, 'complex_args');

      final parsedArgsOuter = jsonDecode(result[0].function.arguments);
      expect(parsedArgsOuter['config_json'], innerJsonString); // The value should be the original JSON string

      // Optionally, decode the inner string to verify it too
      final parsedArgsInner = jsonDecode(parsedArgsOuter['config_json']);
      expect(parsedArgsInner['nestedKey'], 'nestedValue');
    });

    test('should handle empty input string', () {
      const xml = '';
      final result = parser.parseXmlToolCalls(xml);
      expect(result.isEmpty, isTrue);
      expect(capturedLogs.where((r) => r.level == Level.WARNING).isEmpty, isTrue);
    });

    test('should handle input string with only whitespace', () {
      const xml = '   \n  \t  ';
      final result = parser.parseXmlToolCalls(xml);
      expect(result.isEmpty, isTrue);
      expect(capturedLogs.where((r) => r.level == Level.WARNING).isEmpty, isTrue);
    });
  });
}
