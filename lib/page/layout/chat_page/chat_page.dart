import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ChatMcp/llm/model.dart';
import 'package:ChatMcp/llm/prompt.dart';
import 'package:ChatMcp/llm/llm_factory.dart';
import 'package:ChatMcp/llm/base_llm_client.dart';
import 'package:logging/logging.dart';
import 'dart:convert';
import 'chat_message.dart';
import 'input_area.dart';
import 'package:ChatMcp/provider/provider_manager.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;
  late final BaseLLMClient _llmClient;
  String _currentResponse = '';

  @override
  void initState() {
    super.initState();
    final apiKey =
        ProviderManager.settingsProvider.apiSettings['openai']?.apiKey ?? '';
    if (apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY is not set in the environment variables');
    }
    Logger.root.fine('Using API Key: ${apiKey.substring(0, 5)}... (truncated)');
    _llmClient = LLMFactory.create(LLMProvider.openAI, apiKey: apiKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageList(messages: _messages.toList()),
          ),
          InputArea(
            textController: _textController,
            isComposing: _isComposing,
            onTextChanged: _handleTextChanged,
            onSubmitted: _handleSubmitted,
          ),
        ],
      ),
    );
  }

  void _handleTextChanged(String text) {
    setState(() {
      _isComposing = text.isNotEmpty;
    });
  }

  void _handleSubmitted(String text) async {
    _textController.clear();
    setState(() {
      _isComposing = false;
      _messages.add(
        ChatMessage(
          content: text,
          role: MessageRole.user,
        ),
      );
    });

    try {
      final mcpServerProvider = ProviderManager.mcpServerProvider;

      final tools = await mcpServerProvider.getTools();

      final promptGenerator = SystemPromptGenerator();
      final systemPrompt =
          promptGenerator.generatePrompt(tools: {'tools': tools});
      final toolCall = await _llmClient.checkToolCall(text, tools);

      if (toolCall['need_tool_call']) {
        final toolName = toolCall['tool_calls'][0]['name'];
        final toolArguments =
            toolCall['tool_calls'][0]['arguments'] as Map<String, dynamic>;

        String? clientName;
        for (var entry in tools.entries) {
          final clientTools = entry.value;
          if (clientTools.any((tool) => tool['name'] == toolName)) {
            clientName = entry.key;
            break;
          }
        }

        setState(() {
          _messages.add(ChatMessage(
              content: null,
              role: MessageRole.assistant,
              McpServerName: clientName,
              toolCalls: [
                {
                  'id': 'call_$toolName',
                  'type': 'function',
                  'function': {
                    'name': toolName,
                    'arguments': jsonEncode(toolArguments)
                  }
                }
              ]));
        });

        if (clientName != null) {
          final mcpClient = mcpServerProvider.getClient(clientName);

          if (mcpClient != null) {
            final response = await mcpClient.sendToolCall(
              name: toolName,
              arguments: toolArguments,
            );

            setState(() {
              _currentResponse = response.result['content'].toString();
              if (_currentResponse.isNotEmpty) {
                _messages.add(ChatMessage(
                  content: _currentResponse,
                  role: MessageRole.tool,
                  McpServerName: clientName,
                  name: toolName,
                  toolCallId: 'call_$toolName',
                ));
              }
            });
          }
        }
      }

      // 先将消息转换为 ChatMessage 列表
      final List<ChatMessage> messageList = _messages
          .map((m) => ChatMessage(
                role: m.role,
                content: m.content,
                toolCallId: m.toolCallId,
                name: m.name,
                toolCalls: m.toolCalls,
              ))
          .toList();

      // 重新排序消息，确保 user 和 tool 消息的正确顺序
      for (int i = 0; i < messageList.length - 1; i++) {
        if (messageList[i].role == MessageRole.user &&
            messageList[i + 1].role == MessageRole.tool) {
          // 交换相邻的 user 和 tool 消息
          final temp = messageList[i];
          messageList[i] = messageList[i + 1];
          messageList[i + 1] = temp;
          // 跳过下一个消息，因为已经处理过了
          i++;
        }
      }

      final messages = [
        // 添加生成的 system prompt
        ChatMessage(
          role: MessageRole.system,
          content: systemPrompt,
        ),
        // 添加重新排序后的历史消息
        ...messageList,
      ];

      final stream = _llmClient.chatStreamCompletion(messages);

      setState(() {
        _currentResponse = '';
        _messages.add(
          ChatMessage(
            content: _currentResponse,
            role: MessageRole.assistant,
          ),
        );
      });

      // 取消注释并使用流处理响应
      await for (final chunk in stream) {
        setState(() {
          _currentResponse += chunk.content ?? '';
          _messages.last = ChatMessage(
            content: _currentResponse,
            role: MessageRole.assistant,
          );
        });
      }
    } catch (e, stack) {
      Logger.root.severe('Error: $e\n$stack');
      // 错误处理
      setState(() {
        _messages.last = ChatMessage(
          content: "抱歉，发生错误：${e.toString()}",
          role: MessageRole.assistant,
        );
      });
    }
  }
}

class MessageList extends StatelessWidget {
  final List<ChatMessage> messages;

  const MessageList({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final reversedIndex = messages.length - 1 - index;
        final msg = messages[reversedIndex];

        // 检查前一条消息是否也是非用户消息
        final showAvatar = msg.role != MessageRole.user &&
            (reversedIndex == 0 ||
                messages[reversedIndex - 1].role == MessageRole.user);

        return ChatUIMessage(
          msg: msg,
          showAvatar: showAvatar,
        );
      },
    );
  }
}
