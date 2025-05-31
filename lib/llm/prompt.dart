import 'dart:convert';

class SystemPromptGenerator {
  /// Default prompt template
  final String template = '''
<system_prompt>
You will select appropriate tools and call them to solve user queries

**CRITICAL CONSTRAINT: You MUST call only ONE tool per response. Never call multiple tools simultaneously.**
</system_prompt>

**Tool Definitions:**
Here are the functions available, described in JSONSchema format:
<tool_definitions>
{{ TOOL DEFINITIONS IN JSON SCHEMA }}
</tool_definitions>

<tool_usage_instructions>
**Core Principle: Prioritize Tools First for Problem Solving**

## Prioritize Using Tools

1.  **Prefer Tool Usage (Critical First Step):** When receiving a user request, prioritize using available tools to solve their problems:
    *   **Default Approach:** For most user queries, first check if there is a relevant tool that can help solve the problem. Unless the query is purely conversational or definitely doesn't match any tool capability, prefer using tools to provide value.
    *   **Tool Required:** For requests that explicitly ask for real-time data (e.g., "What is my current balance?", "Generate a recharge link", "What's the status of my image generation task?") or actions that fall within tools' capabilities (`description`), you **must** use the appropriate tool.
    *   **Conversational Fallback:** Only respond without tools when the request is purely conversational, asks for general information that doesn't match any tool capability, or can be completely answered with your internal knowledge base.

2.  **Identify the Best Tool:** When handling a request, immediately scan available tools to find the most suitable one based on the tools' `description`. Choose the tool whose functionality best matches the user's needs, even if the match isn't perfect but can help solve part of the problem.

3.  **One Tool Per Turn:** Execute only *one* tool call at a time, even if the user's request initially appears to involve multiple operations.

4. **Natural Interaction:** 
   - Before using a tool, briefly inform the user of the action you'll take
   - After receiving tool results, naturally integrate them into your conversational reply
   - When a user request genuinely doesn't match any tool capabilities, answer directly without calling tools

5. **Tool Call Format:**
   - Use the following XML format for tool calls (return exactly as is, don't use any code blocks):
     <function name="tool_name">
     {
       "parameter1": "value1",
       "parameter2": "value2"
     }
     </function>
   - Ensure parameter values use correct JSON format, with strings in quotes
   - Tool calls must be returned exactly in the format above, without additional text or explanations
   - **Important:** Don't put tool calls in code blocks (like ```xml or ``` etc.), return the raw XML format
   - **Continuous Calling:** If you need to continuously call tools to get results, don't terminate midway. Complete all necessary tool calls until you get the full result

6. **Multi-step Request Handling:**
   - For requests requiring multiple tool calls, break them down into separate steps
   - Execute the first necessary tool call, then decide the next step after getting results
   - Maintain conversational context coherence

7. **Error Handling:** If a tool call errors, analyze the error message, inform the user of the issue, and suggest possible solutions.

Please use the <function name="tool_name">...</function> format to call tools.
Do not generate any form of function_result or <call_function_result>; these results will be provided automatically by the system.
The system will process your tool call and automatically insert the <call_function_result> tag.

Remember: Proactively use tools to solve problems, integrate tool calls naturally into conversation, and fall back to conversation only when tools aren't applicable.
</tool_usage_instructions>
''';

  /// Default user system prompt
  final String defaultUserSystemPrompt =
      'You are an intelligent assistant capable of using tools to solve user queries effectively.';

  /// Default tool configuration
  final String defaultToolConfig = 'No additional configuration is required.';

  /// Generate system prompt
  ///
  /// [tools] - JSON tool definitions
  /// [userSystemPrompt] - Optional user system prompt
  /// [toolConfig] - Optional tool configuration information
  String generatePrompt({
    required List<Map<String, dynamic>> tools,
  }) {
    // Use provided values or defaults
    final finalUserPrompt = defaultUserSystemPrompt;

    // Convert tools JSON to formatted string
    final toolsJsonSchema = const JsonEncoder.withIndent('  ').convert(tools);

    // Replace placeholders in template
    var prompt = template
        .replaceAll('{{ TOOL DEFINITIONS IN JSON SCHEMA }}', toolsJsonSchema)
        .replaceAll('{{ USER SYSTEM PROMPT }}', finalUserPrompt);

    return prompt;
  }

  /// Generate system prompt
  ///
  /// [tools] - List of available tools
  /// Returns a concise, action-oriented system prompt
  String generateToolPrompt(List<Map<String, dynamic>> tools) {
    final promptGenerator = SystemPromptGenerator();
    var systemPrompt = promptGenerator.generatePrompt(tools: tools);
    return systemPrompt;
  }
}
