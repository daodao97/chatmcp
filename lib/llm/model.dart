import 'dart:convert';

// 消息角色枚举
enum MessageRole {
  system,
  user,
  assistant,
  function,
  tool;

  String get value => name;
}

// 消息结构体
class ChatMessage {
  final MessageRole role;
  final String? content;
  final String? name;
  final String? McpServerName;
  final String? toolCallId;
  final List<Map<String, dynamic>>? toolCalls;

  ChatMessage({
    required this.role,
    this.content,
    this.name,
    this.McpServerName,
    this.toolCallId,
    this.toolCalls,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'role': role.value,
      if (content != null) 'content': content,
    };

    if (role == MessageRole.tool && name != null && toolCallId != null) {
      json['name'] = name!;
      json['tool_call_id'] = toolCallId!;
    }

    if (toolCalls != null) {
      json['tool_calls'] = toolCalls;
    }

    return json;
  }
}

// 添加工具调用的数据结构
class ToolCall {
  final String id;
  final String type;
  final FunctionCall function;

  ToolCall({
    required this.id,
    required this.type,
    required this.function,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'function': function.toJson(),
      };
}

class FunctionCall {
  final String name;
  final String arguments;

  FunctionCall({
    required this.name,
    required this.arguments,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'arguments': arguments,
      };

  // 解析参数为 Map
  Map<String, dynamic> get parsedArguments =>
      json.decode(arguments) as Map<String, dynamic>;
}

class LLMResponse {
  final String? content;
  final List<ToolCall>? toolCalls;
  final bool needToolCall;

  LLMResponse({
    this.content,
    this.toolCalls,
  }) : needToolCall = toolCalls != null && toolCalls.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'content': content,
        'tool_calls': toolCalls?.map((t) => t.toJson()).toList(),
        'need_tool_call': needToolCall,
      };
}
