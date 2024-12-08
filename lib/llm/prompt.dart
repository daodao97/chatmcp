import 'dart:convert';

class SystemPromptGenerator {
  /// 默认的提示模板
  final String template = '''
In this environment you have access to a set of tools you can use to answer the user's question.
{{ FORMATTING INSTRUCTIONS }}
String and scalar parameters should be specified as is, while lists and objects should use JSON format. Note that spaces for string values are not stripped. The output is not expected to be valid XML and is parsed with regular expressions.
Here are the functions available in JSONSchema format:
{{ TOOL DEFINITIONS IN JSON SCHEMA }}
{{ USER SYSTEM PROMPT }}
{{ TOOL CONFIGURATION }}
''';

  /// 默认的用户系统提示
  final String defaultUserSystemPrompt =
      'You are an intelligent assistant capable of using tools to solve user queries effectively.';

  /// 默认的工具配置
  final String defaultToolConfig = 'No additional configuration is required.';

  /// 生成系统提示
  ///
  /// [tools] - 工具定义的JSON
  /// [userSystemPrompt] - 可选的用户系统提示
  /// [toolConfig] - 可选的工具配置信息
  String generatePrompt({
    required Map<String, dynamic> tools,
    String? userSystemPrompt,
    String? toolConfig,
  }) {
    // 使用提供的值或默认值
    final finalUserPrompt = userSystemPrompt ?? defaultUserSystemPrompt;
    final finalToolConfig = toolConfig ?? defaultToolConfig;

    // 将工具JSON转换为格式化的字符串
    final toolsJsonSchema = const JsonEncoder.withIndent('  ').convert(tools);

    // 替换模板中的占位符
    var prompt = template
        .replaceAll('{{ TOOL DEFINITIONS IN JSON SCHEMA }}', toolsJsonSchema)
        .replaceAll('{{ FORMATTING INSTRUCTIONS }}', '')
        .replaceAll('{{ USER SYSTEM PROMPT }}', finalUserPrompt)
        .replaceAll('{{ TOOL CONFIGURATION }}', finalToolConfig);

    return prompt;
  }

  /// 生成系统提示
  ///
  /// [tools] - 可用工具列表
  /// 返回一个简洁的、面向行动的系统提示
  String generateSystemPrompt(List<Map<String, dynamic>> tools) {
    final promptGenerator = SystemPromptGenerator();
    final toolsJson = {'tools': tools};

    // 生成基础工具提示
    var systemPrompt = promptGenerator.generatePrompt(tools: toolsJson);

    // 添加简洁的工具使用指南
    systemPrompt += '''

**GENERAL GUIDELINES:**

1. **Step-by-step reasoning:**
   - Analyze tasks systematically.
   - Break down complex problems into smaller, manageable parts.
   - Verify assumptions at each step to avoid errors.
   - Reflect on results to improve subsequent actions.

2. **Effective tool usage:**
   - **Explore:** 
     - Identify available information and verify its structure.
     - Check assumptions and understand data relationships.
   - **Iterate:**
     - Start with simple queries or actions.
     - Build upon successes, adjusting based on observations.
   - **Handle errors:**
     - Carefully analyze error messages.
     - Use errors as a guide to refine your approach.
     - Document what went wrong and suggest fixes.

3. **Clear communication:**
   - Explain your reasoning and decisions at each step.
   - Share discoveries transparently with the user.
   - Outline next steps or ask clarifying questions as needed.

**EXAMPLES OF BEST PRACTICES:**

- **Working with databases:**
  - Check schema before writing queries.
  - Verify the existence of columns or tables.
  - Start with basic queries and refine based on results.

- **Processing data:**
  - Validate data formats and handle edge cases.
  - Ensure the integrity and correctness of results.

- **Accessing resources:**
  - Confirm resource availability and permissions.
  - Handle missing or incomplete data gracefully.

**REMEMBER:**
- Be thorough and systematic in your approach.
- Ensure that each tool call serves a clear and well-explained purpose.
- When faced with ambiguity, make reasonable assumptions to move forward.
- Minimize unnecessary user interactions by offering actionable insights and solutions.

**EXAMPLES OF ASSUMPTIONS YOU CAN MAKE:**
- Use default sorting (e.g., descending order for rankings) unless specified.
- Assume basic user intentions (e.g., fetching the top 10 items by a common metric like price or popularity).
''';

    return systemPrompt;
  }
}
