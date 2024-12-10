import 'package:flutter/material.dart';
import 'package:ChatMcp/llm/model.dart';
import 'package:ChatMcp/llm/prompt.dart';
import 'package:ChatMcp/llm/llm_factory.dart';
import 'package:ChatMcp/llm/base_llm_client.dart';
import 'package:logging/logging.dart';
import 'dart:convert';
import 'chat_message.dart';
import 'input_area.dart';
import 'package:ChatMcp/provider/provider_manager.dart';

import 'package:ChatMcp/dao/chat.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Chat? _chat;
  List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;
  late final BaseLLMClient _llmClient;
  String _currentResponse = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final apiKey =
        ProviderManager.settingsProvider.apiSettings['openai']?.apiKey ?? '';
    Logger.root.fine('Using API Key: [HIDDEN]');
    _llmClient = LLMFactory.create(LLMProvider.openAI, apiKey: apiKey);

    // 添加监听器
    ProviderManager.chatProvider.addListener(_onActiveChatChanged);
    _initializeHistoryMessages();
  }

  @override
  void dispose() {
    // 移除监听器
    ProviderManager.chatProvider.removeListener(_onActiveChatChanged);
    super.dispose();
  }

  void _onActiveChatChanged() {
    _initializeHistoryMessages();
  }

  Future<void> _initializeHistoryMessages() async {
    final activeChat = ProviderManager.chatProvider.activeChat;
    if (activeChat == null) {
      setState(() {
        _messages = [];
        _chat = null;
      });
      return;
    }
    if (_chat?.id != activeChat.id) {
      final messages = await activeChat.getChatMessages();
      setState(() {
        _messages = messages;
        _chat = activeChat;
      });
    }
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
            child: MessageList(
              messages: _isLoading
                  ? [
                      ..._messages,
                      ChatMessage(content: '', role: MessageRole.loading)
                    ]
                  : _messages.toList(),
            ),
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
      _isLoading = true;
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

      Logger.root
          .info('tools:\n${const JsonEncoder.withIndent('  ').convert(tools)}');

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
              mcpServerName: clientName,
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
                  mcpServerName: clientName,
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
      if (ProviderManager.chatProvider.activeChat == null) {
        String title =
            await _llmClient.genTitle([_messages.first, _messages.last]);
        await ProviderManager.chatProvider.createChat(
            Chat(
              title: title,
            ),
            _messages);
      } else {
        await ProviderManager.chatProvider.updateChat(Chat(
          id: ProviderManager.chatProvider.activeChat!.id!,
          title: ProviderManager.chatProvider.activeChat!.title,
          createdAt: ProviderManager.chatProvider.activeChat!.createdAt,
          updatedAt: DateTime.now(),
        ));

        final lastFiveMessages = _messages.length <= 5
            ? _messages
            : _messages.sublist(_messages.length - 5);

        await ProviderManager.chatProvider.addChatMessage(
            ProviderManager.chatProvider.activeChat!.id!, lastFiveMessages);
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
    setState(() {
      _isLoading = false;
    });
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
