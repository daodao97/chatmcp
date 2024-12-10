import 'package:flutter_test/flutter_test.dart';
import 'package:chatmcp/llm/prompt.dart';
import 'package:chatmcp/llm/utils.dart';

void main() {
  // 创建模拟工具列表
  final tools = [
    {
      'name': 'read-query',
      'description': 'Execute a SELECT query on the SQLite database',
      'inputSchema': {
        'type': 'object',
        'properties': {
          'query': {
            'type': 'string',
            'description': 'SELECT SQL query to execute'
          }
        },
        'required': ['query']
      }
    },
    {
      'name': 'write-query',
      'description':
          'Execute an INSERT, UPDATE, or DELETE query on the SQLite database',
      'inputSchema': {
        'type': 'object',
        'properties': {
          'query': {'type': 'string', 'description': 'SQL query to execute'}
        },
        'required': ['query']
      }
    }
  ];

  test('Generate and print system prompt', () {
    final promptGenerator = SystemPromptGenerator();
    final systemPrompt =
        promptGenerator.generatePrompt(tools: {'tools': tools});

    // 打印生成的提示
    print('生成的系统提示:\n');
    print(systemPrompt);

    final openaiTools = convertToOpenAITools(tools);
    print('转换后的 OpenAI 工具:\n');
    print(openaiTools);

    // 添加一些基本断言
    expect(systemPrompt, contains('read-query'));
    expect(systemPrompt, contains('write-query'));
    expect(systemPrompt, contains('SELECT SQL query to execute'));
  });
}
