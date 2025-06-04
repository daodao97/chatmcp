import 'dart:typed_data';

import 'package:chatmcp/llm/prompt.dart';
import 'package:chatmcp/utils/platform.dart';
import 'package:flutter/material.dart';
import 'package:chatmcp/llm/model.dart';
import 'package:chatmcp/llm/llm_factory.dart';
import 'package:chatmcp/llm/base_llm_client.dart';
import 'package:logging/logging.dart';
import 'package:file_picker/file_picker.dart';
import 'input_area.dart';
import 'package:chatmcp/provider/provider_manager.dart';
import 'package:chatmcp/utils/file_content.dart';
import 'package:chatmcp/dao/chat.dart';
import 'package:uuid/uuid.dart';
import 'chat_message_list.dart';
import 'package:chatmcp/utils/color.dart';
import 'package:chatmcp/widgets/widgets_to_image/utils.dart';
import 'chat_message_to_image.dart';
import 'package:chatmcp/utils/event_bus.dart';
import 'chat_code_preview.dart';
import 'package:chatmcp/generated/app_localizations.dart';
import 'package:jsonc/jsonc.dart';
import 'package:chatmcp/llm/tool_call_parser.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Chat? _chat;
  List<ChatMessage> _messages = [];
  bool _isComposing = false; // 是否正在输入
  BaseLLMClient? _llmClient;
  String _currentResponse = '';
  bool _isLoading = false; // 是否正在加载
  String _parentMessageId = ''; // 父消息ID
  bool _isCancelled = false; // 是否取消
  bool _isWating = false; // 是否正在补全

  WidgetsToImageController toImagecontroller = WidgetsToImageController();
  // to save image bytes of widget
  Uint8List? bytes;

  bool mobile = kIsMobile;

  List<RunFunctionEvent> _runFunctionEvents = [];
  bool _isRunningFunction = false;

  num _currentLoop = 0;

  @override
  void initState() {
    super.initState();
    _initializeState();
    // on<CodePreviewEvent>(_onArtifactEvent);
    on<ShareEvent>(_handleShare);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isMobile() != mobile) {
        setState(() {
          mobile = _isMobile();
        });
      }
      if (!mobile && showModalCodePreview) {
        setState(() {
          Navigator.pop(context);
          showModalCodePreview = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _removeListeners();
    super.dispose();
  }

  // 初始化相关方法
  void _initializeState() {
    _initializeLLMClient();
    _addListeners();
    _initializeHistoryMessages();
    on<RunFunctionEvent>(_onRunFunction);
  }

  Future<void> _onRunFunction(RunFunctionEvent event) async {
    setState(() {
      _runFunctionEvents.add(event);
    });

    // 显示授权对话框
    // if (mounted) {
    //   await _showFunctionApprovalDialog(event);
    // }

    if (!_isLoading) {
      _handleSubmitted(SubmitData("", []));
    }
  }

  Future<bool> _showFunctionApprovalDialog(RunFunctionEvent event) async {
    // 检查工具名称的前缀以确定是哪个服务器的工具
    final clientName =
        _findClientName(ProviderManager.mcpServerProvider.tools, event.name);
    if (clientName == null) return false;

    final serverConfig =
        await ProviderManager.mcpServerProvider.loadServersAll();
    final servers = serverConfig['mcpServers'] as Map<String, dynamic>? ?? {};

    if (servers.containsKey(clientName)) {
      final config = servers[clientName] as Map<String, dynamic>? ?? {};
      final autoApprove = config['auto_approve'] as bool? ?? false;

      // 如果设置了自动批准，直接返回true
      if (autoApprove) {
        return true;
      }
    }

    // 在异步操作后检查组件是否仍然挂载
    if (!mounted) return false;

    // 否则显示授权对话框
    var t = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              title: Text(t.functionCallAuth),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(t.allowFunctionExecution),
                    SizedBox(height: 8),
                    Text(event.name),
                    SizedBox(height: 8),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(t.cancel),
                  onPressed: () {
                    setState(() {
                      _runFunctionEvents.clear();
                    });
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text(t.allow),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _addListeners() {
    ProviderManager.settingsProvider.addListener(_onSettingsChanged);
    ProviderManager.chatModelProvider.addListener(_initializeLLMClient);
    ProviderManager.chatProvider.addListener(_onChatProviderChanged);
  }

  void _removeListeners() {
    ProviderManager.settingsProvider.removeListener(_onSettingsChanged);
    ProviderManager.chatProvider.removeListener(_onChatProviderChanged);
    ProviderManager.chatModelProvider.removeListener(_initializeLLMClient);
  }

  void _initializeLLMClient() {
    _llmClient = LLMFactoryHelper.createFromModel(
        ProviderManager.chatModelProvider.currentModel);
    setState(() {});
  }

  void _onSettingsChanged() {
    _initializeLLMClient();
  }

  void _onChatProviderChanged() {
    _initializeHistoryMessages();

    if (ProviderManager.chatProvider.artifactEvent != null) {
      if (_isMobile()) {
        _showMobileCodePreview();
      }
    }

    setState(() {
      _showCodePreview = ProviderManager.chatProvider.showCodePreview;
    });
  }

  bool _showCodePreview = false;

  List<ChatMessage> _allMessages = [];

  Future<List<ChatMessage>> _getHistoryTreeMessages() async {
    final activeChat = ProviderManager.chatProvider.activeChat;
    if (activeChat == null) return [];

    Map<String, List<String>> messageMap = {};

    final messages = await activeChat.getChatMessages();

    for (var message in messages) {
      if (message.role == MessageRole.user) {
        continue;
      }
      if (messageMap[message.parentMessageId] == null) {
        messageMap[message.parentMessageId] = [];
      }

      messageMap[message.parentMessageId]?.add(message.messageId);
    }

    for (var message in messages) {
      final brotherIds = messageMap[message.messageId] ?? [];

      if (brotherIds.length > 1) {
        int index =
            messages.indexWhere((m) => m.messageId == message.messageId);
        if (index != -1) {
          messages[index].childMessageIds ??= brotherIds;
        }

        for (var brotherId in brotherIds) {
          final index = messages.indexWhere((m) => m.messageId == brotherId);
          if (index != -1) {
            messages[index].brotherMessageIds ??= brotherIds;
          }
        }
      }
    }

    setState(() {
      _allMessages = messages;
    });

    // print('messages:\n${const JsonEncoder.withIndent('  ').convert(messages)}');

    if (messages.isEmpty) {
      return [];
    }

    final lastMessage = messages.last;
    return _getTreeMessages(lastMessage.messageId, messages);
  }

  List<ChatMessage> _getTreeMessages(
      String messageId, List<ChatMessage> messages) {
    final lastMessage = messages.firstWhere((m) => m.messageId == messageId);
    List<ChatMessage> treeMessages = [];

    ChatMessage? currentMessage = lastMessage;
    while (currentMessage != null) {
      if (currentMessage.role != MessageRole.user) {
        final childMessageIds = currentMessage.childMessageIds;
        if (childMessageIds != null && childMessageIds.isNotEmpty) {
          for (var childId in childMessageIds.reversed) {
            final childMessage = messages.firstWhere(
              (m) => m.messageId == childId,
              orElse: () => ChatMessage(content: '', role: MessageRole.user),
            );
            if (treeMessages
                .any((m) => m.messageId == childMessage.messageId)) {
              continue;
            }
            treeMessages.insert(0, childMessage);
          }
        }
      }

      treeMessages.insert(0, currentMessage);

      final parentId = currentMessage.parentMessageId;
      if (parentId.isEmpty) break;

      currentMessage = messages.firstWhere(
        (m) => m.messageId == parentId,
        orElse: () => ChatMessage(
          messageId: '',
          content: '',
          role: MessageRole.user,
          parentMessageId: '',
        ),
      );

      if (currentMessage.messageId.isEmpty) break;
    }

    // print('messageId: ${lastMessage.messageId}');

    ChatMessage? nextMessage = messages
        .where((m) => m.role == MessageRole.user)
        .firstWhere(
          (m) => m.parentMessageId == lastMessage.messageId,
          orElse: () =>
              ChatMessage(messageId: '', content: '', role: MessageRole.user),
        );

    // print(
    // 'nextMessage:\n${const JsonEncoder.withIndent('  ').convert(nextMessage)}');

    while (nextMessage != null && nextMessage.messageId.isNotEmpty) {
      if (!treeMessages.any((m) => m.messageId == nextMessage!.messageId)) {
        treeMessages.add(nextMessage);
      }
      final childMessageIds = nextMessage.childMessageIds;
      if (childMessageIds != null && childMessageIds.isNotEmpty) {
        for (var childId in childMessageIds) {
          final childMessage = messages.firstWhere(
            (m) => m.messageId == childId,
            orElse: () =>
                ChatMessage(messageId: '', content: '', role: MessageRole.user),
          );
          if (treeMessages.any((m) => m.messageId == childMessage.messageId)) {
            continue;
          }
          treeMessages.add(childMessage);
        }
      }

      nextMessage = messages.firstWhere(
        (m) => m.parentMessageId == nextMessage!.messageId,
        orElse: () =>
            ChatMessage(messageId: '', content: '', role: MessageRole.user),
      );
    }

    return treeMessages;
  }

  // 消息处理相关方法
  Future<void> _initializeHistoryMessages() async {
    final activeChat = ProviderManager.chatProvider.activeChat;
    if (activeChat == null && _messages.isEmpty) {
      setState(() {
        _messages = [];
        _chat = null;
        _parentMessageId = '';
      });
      _resetState();
      return;
    }
    if (_chat?.id != activeChat?.id) {
      final messages = await _getHistoryTreeMessages();
      // 找到最后一条用户消息的索引
      final lastUserIndex =
          messages.lastIndexWhere((m) => m.role == MessageRole.user);
      String parentId = '';

      // 如果找到用户消息，且其后有助手消息，则使用助手消息的ID
      if (lastUserIndex != -1 && lastUserIndex + 1 < messages.length) {
        parentId = messages[lastUserIndex + 1].messageId;
      } else if (messages.isNotEmpty) {
        // 如果没有找到合适的消息，使用最后一条消息的ID
        parentId = messages.last.messageId;
      }

      ProviderManager.chatProvider.clearArtifactEvent();

      setState(() {
        _messages = messages;
        _chat = activeChat;
        _parentMessageId = parentId;
      });
      _resetState();
    }
  }

  // UI 构建相关方法
  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return Expanded(
        child: Container(
          color: AppColors.transparent,
          child: Center(
            child: Text(
              l10n.welcomeMessage,
              style: TextStyle(
                fontSize: 18,
                color: AppColors.getWelcomeMessageColor(),
              ),
            ),
          ),
        ),
      );
    }

    final parentMsgIndex = _messages.length - 1;
    for (var i = 0; i < parentMsgIndex; i++) {
      if (_messages[i].content?.contains('<function') == true &&
          _messages[i].content?.contains('<function done="true"') == false) {
        _messages[i] = _messages[i].copyWith(
          content: _messages[i]
              .content
              ?.replaceAll("<function ", "<function done=\"true\" "),
        );
      }
    }

    return Expanded(
      child: MessageList(
        messages: _isWating
            ? [
                ..._messages,
                ChatMessage(content: '', role: MessageRole.loading)
              ]
            : _messages.toList(),
        onRetry: _onRetry,
        onSwitch: _onSwitch,
      ),
    );
  }

  void _onSwitch(String messageId) {
    final messages = _getTreeMessages(messageId, _allMessages);
    setState(() {
      _messages = messages;
    });
  }

  // 消息处理相关方法
  void _handleTextChanged(String text) {
    setState(() {
      _isComposing = text.isNotEmpty;
    });
  }

  String? _findClientName(
      Map<String, List<Map<String, dynamic>>> tools, String toolName) {
    for (var entry in tools.entries) {
      final clientTools = entry.value;
      if (clientTools.any((tool) => tool['name'] == toolName)) {
        return entry.key;
      }
    }
    return null;
  }

  Future<void> _sendToolCallAndProcessResponse(
      String toolName, Map<String, dynamic> toolArguments) async {
    final clientName =
        _findClientName(ProviderManager.mcpServerProvider.tools, toolName);
    if (clientName == null) {
      Logger.root.severe('clientName is null');
      return;
    }

    final mcpClient = ProviderManager.mcpServerProvider.getClient(clientName);
    if (mcpClient == null) {
      Logger.root.severe('mcpClient is null');
      return;
    }

    final response = await mcpClient.sendToolCall(
      name: toolName,
      arguments: toolArguments,
    );

    Logger.root.info(
        'send tool call name: $toolName arguments: $toolArguments response: $response');

    setState(() {
      _currentResponse = response.result['content'].toString();
      if (_currentResponse.isNotEmpty) {
        _parentMessageId = _messages.last.messageId;
        final msgId = Uuid().v4();
        _messages.add(ChatMessage(
          messageId: msgId,
          content:
              '<call_function_result name="$toolName">\n$_currentResponse\n</call_function_result>',
          role: MessageRole.tool, // Changed from MessageRole.assistant
          name: toolName,
          toolCallId: null, // This message is a result, not a request. If we need to link it to a request, this might be used.
          parentMessageId: _parentMessageId,
        ));
        _parentMessageId = msgId;
      }
    });
  }

  ChatMessage? _findUserMessage(ChatMessage message) {
    final parentMessage = _messages.firstWhere(
      (m) => m.messageId == message.parentMessageId,
      orElse: () =>
          ChatMessage(messageId: '', content: '', role: MessageRole.user),
    );

    if (parentMessage.messageId.isEmpty) return null;

    if (parentMessage.role != MessageRole.user) {
      return _findUserMessage(parentMessage);
    }

    return parentMessage;
  }

  Future<void> _onRetry(ChatMessage message) async {
    final userMessage = _findUserMessage(message);
    if (userMessage == null) return;

    final messageIndex = _messages.indexOf(userMessage);
    if (messageIndex == -1) return;

    final previousMessages = _messages.sublist(0, messageIndex + 1);

    setState(() {
      _messages = previousMessages;
      _parentMessageId = userMessage.messageId;
      _isLoading = true;
    });

    await _handleSubmitted(
      SubmitData(
        userMessage.content ?? '',
        (userMessage.files ?? []).map((f) => f as PlatformFile).toList(),
      ),
      addUserMessage: false,
    );
  }

  Future<bool> _checkNeedToolCallFunction() async {
    if (_runFunctionEvents.isNotEmpty) return true;

    final lastMessage = _messages.last;

    final content = lastMessage.content ?? '';
    if (content.isEmpty) return false;

    final messages = _messages.toList();

    Logger.root.info('check need tool call: $messages');

    final result = await _llmClient!.checkToolCall(
      ProviderManager.chatModelProvider.currentModel.name,
      CompletionRequest(
        model: ProviderManager.chatModelProvider.currentModel.name,
        messages: [
          ..._prepareMessageList(),
        ],
      ),
      ProviderManager.mcpServerProvider.tools,
    );
    final needToolCall = result['need_tool_call'] ?? false;

    if (!needToolCall) {
      return false;
    }

    final toolCalls = result['tool_calls'] as List;
    for (var toolCall in toolCalls) {
      final functionEvent = RunFunctionEvent(
        toolCall['name'],
        toolCall['arguments'],
      );

      _runFunctionEvents.add(functionEvent);

      _messages.add(ChatMessage(
        content:
            "<function name=\"${functionEvent.name}\">\n${jsonc.encode(functionEvent.arguments)}\n</function>",
        role: MessageRole.assistant,
        parentMessageId: _parentMessageId,
      ));

      _onRunFunction(functionEvent);
    }

    return needToolCall;
  }

  Future<bool> _checkNeedToolCall() async {
    return _runFunctionEvents.isNotEmpty;
  }

  // 消息提交处理
  Future<void> _handleSubmitted(SubmitData data,
      {bool addUserMessage = true}) async {
    setState(() {
      _isCancelled = false;
    });
    final files = data.files.map((file) => platformFileToFile(file)).toList();

    if (addUserMessage && data.text.isNotEmpty) {
      _addUserMessage(data.text, files);
    }

    try {
      final generalSetting = ProviderManager.settingsProvider.generalSetting;
      final maxLoops = generalSetting.maxLoops;

      while (await _checkNeedToolCall()) {
        if (_currentLoop > maxLoops) {
          Logger.root.warning('达到最大循环次数限制: $maxLoops');
          break;
        }

        if (_runFunctionEvents.isNotEmpty) {
          // 顺序处理每个函数调用
          while (_runFunctionEvents.isNotEmpty) {
            final event = _runFunctionEvents.first;

            // 等待用户授权
            final approved = await _showFunctionApprovalDialog(event);

            if (approved) {
              setState(() {
                _isRunningFunction = true;
              });

              await _sendToolCallAndProcessResponse(
                  event.name, event.arguments);
              setState(() {
                _isRunningFunction = false;
              });
              _runFunctionEvents.removeAt(0);
            } else {
              setState(() {
                _runFunctionEvents.clear();
              });
              final msgId = Uuid().v4();
              _messages.add(ChatMessage(
                messageId: msgId,
                content: 'call function rejected',
                role: MessageRole.assistant,
                parentMessageId: _parentMessageId,
              ));
              _parentMessageId = msgId;
              break;
            }
          }
        }

        await _processLLMResponse();
        _currentLoop++;
      }
      await _updateChat();
    } catch (e, stackTrace) {
      _handleError(e, stackTrace);
      await _updateChat();
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _addUserMessage(String text, List<File> files) {
    setState(() {
      _isLoading = true;
      _isComposing = false;
      final msgId = Uuid().v4();
      _messages.add(
        ChatMessage(
          messageId: msgId,
          parentMessageId: _parentMessageId,
          content: text.replaceAll('\n', '\n\n'),
          role: MessageRole.user,
          files: files,
        ),
      );
      _parentMessageId = msgId;
    });
  }

  Future<String> _getSystemPrompt() async {
    return ProviderManager.settingsProvider.generalSetting.systemPrompt;
  }

  Future<String> _getLasstUserMessagePrompt(String userMessage) async {
    final promptGenerator = SystemPromptGenerator();

    var tools = <Map<String, dynamic>>[];
    for (var entry in ProviderManager.mcpServerProvider.tools.entries) {
      if (ProviderManager.serverStateProvider.isEnabled(entry.key)) {
        tools.addAll(entry.value);
      }
    }

    if (tools.isEmpty) {
      return userMessage;
    }

    final toolPrompt = promptGenerator.generateToolPrompt(tools);

    return "<user_message>\n$userMessage\n</user_message>\n\n$toolPrompt\n";
  }

  void _processLLMResponseAndExtractToolCalls(LLMResponse response) {
    _runFunctionEvents.clear(); // Clear previous events

    bool toolCallMadeOrParsed = false;

    if (response.toolCalls != null && response.toolCalls!.isNotEmpty) {
      for (final tc in response.toolCalls!) {
        _runFunctionEvents.add(RunFunctionEvent(tc.function.name, tc.function.parsedArguments));

        final toolCallMsgId = Uuid().v4();
        final toolCallMessage = ChatMessage(
          messageId: toolCallMsgId,
          parentMessageId: _parentMessageId,
          // TODO: Review if this content representation is what we want, or if it should be hidden/different.
          content: '<function name="${tc.function.name}">${tc.function.arguments}</function>',
          role: MessageRole.assistant, // Or MessageRole.tool? Assistant requests a tool.
          // toolCalls: [tc.toJson()], // Storing the structured tool call itself.
        );
        _messages.add(toolCallMessage);
        _parentMessageId = toolCallMsgId; // Update parent ID for the next message
        _onRunFunction(RunFunctionEvent(tc.function.name, tc.function.parsedArguments)); // To trigger UI/dialog if needed
      }
      toolCallMadeOrParsed = true;
    } else if (response.needsXmlParsing && response.rawToolCallXml != null) {
      ToolCallParser parser = ToolCallParser();
      List<ToolCall> parsedXmlToolCalls = parser.parseXmlToolCalls(response.rawToolCallXml!);
      for (final tc in parsedXmlToolCalls) {
        _runFunctionEvents.add(RunFunctionEvent(tc.function.name, tc.function.parsedArguments));

        final xmlToolCallMsgId = Uuid().v4();
        final xmlToolCallMessage = ChatMessage(
          messageId: xmlToolCallMsgId,
          parentMessageId: _parentMessageId,
          content: '<function name="${tc.function.name}">${tc.function.arguments}</function>', // Store the parsed call
          role: MessageRole.assistant, // Or MessageRole.tool?
        );
        _messages.add(xmlToolCallMessage);
        _parentMessageId = xmlToolCallMsgId; // Update parent ID
         _onRunFunction(RunFunctionEvent(tc.function.name, tc.function.parsedArguments)); // To trigger UI/dialog if needed
      }
      if (parsedXmlToolCalls.isNotEmpty) {
        toolCallMadeOrParsed = true;
      }
    }

    // Handle regular content if no tool calls were made or if content can coexist
    // The existing _processResponseStream updates _messages.last.
    // If tool calls were added, _messages.last is now a tool call request.
    // We need to ensure that if there's also final textual content from the LLM, it's added as a separate assistant message.

    if (response.content != null && response.content!.trim().isNotEmpty) {
      if (toolCallMadeOrParsed) {
        // If tool calls were just added, and there's also text content,
        // this text content should be a new assistant message.
        final assistantMsgId = Uuid().v4();
        _messages.add(ChatMessage(
          messageId: assistantMsgId,
          content: response.content,
          role: MessageRole.assistant,
          parentMessageId: _parentMessageId, // Parent is the last tool call message or previous assistant message
        ));
        _parentMessageId = assistantMsgId;
      } else {
        // No tool calls, this is simple text content.
        // The _processResponseStream already updated _messages.last.
        // We just need to ensure its parentMessageId is correct.
        if (_messages.isNotEmpty && _messages.last.role == MessageRole.assistant) {
          // This case should be handled by _initializeAssistantResponse and _processResponseStream
          // _messages.last = _messages.last.copyWith(parentMessageId: _parentMessageId);
          // No, _parentMessageId should already be correct before _processLLMResponse is called.
        }
      }
    }
    // If no content and no tool calls, the empty assistant message initialized earlier might remain.
    // It might be better to remove it if it's still empty.
    // However, _processResponseStream only adds to _currentResponse if chunk.content is not null.
    // _initializeAssistantResponse adds an empty message. If it's still empty and no tool calls, let's remove it.
    if (!toolCallMadeOrParsed && (response.content == null || response.content!.trim().isEmpty)) {
        if (_messages.isNotEmpty && _messages.last.role == MessageRole.assistant && (_messages.last.content == null || _messages.last.content!.isEmpty)) {
            // Let's verify this logic. If _processResponseStream did not add any content,
            // and _processLLMResponseAndExtractToolCalls did not add any tool calls,
            // then the initial empty assistant message is indeed empty.
            // However, _parentMessageId was already updated when it was added.
            // We should probably only remove it if it's truly the *absolute* last message and is empty.
            // For now, let this be. The UI might just show an empty bubble.
        }
    }

    setState(() {}); // Update UI with new messages or tool call events
  }

  Future<void> _processLLMResponse() async {
    setState(() {
      _isWating = true;
    });

    List<ChatMessage> messageList = _prepareMessageList();
    messageList = messageMerge(messageList);

    final modelSetting = ProviderManager.settingsProvider.modelSetting;
    final generalSetting = ProviderManager.settingsProvider.generalSetting;

    final maxMessages = generalSetting.maxMessages;
    if (messageList.length > maxMessages) {
      messageList = messageList.sublist(messageList.length - maxMessages);
    }

    final lastUserMessageIndex = messageList.lastIndexWhere((m) => m.role == MessageRole.user);
    final systemPrompt = await _getSystemPrompt();

    if (ProviderManager.serverStateProvider.enabledCount > 0 && lastUserMessageIndex != -1) {
      messageList[lastUserMessageIndex] = messageList[lastUserMessageIndex].copyWith(
        content: await _getLasstUserMessagePrompt(messageList[lastUserMessageIndex].content ?? ''),
      );
    }

    Logger.root.info('start process llm response (prepared messages): $messageList');

    final stream = _llmClient!.chatStreamCompletion(CompletionRequest(
      model: ProviderManager.chatModelProvider.currentModel.name,
      messages: [
        ChatMessage(content: systemPrompt, role: MessageRole.system),
        ...messageList,
      ],
      modelSetting: modelSetting,
    ));

    _initializeAssistantResponse(); // Adds an empty assistant message and sets its parent to current _parentMessageId

    // Accumulators for the stream
    _currentResponse = ''; // Reset current response text for accumulation
    List<ToolCall> accumulatedToolCalls = [];
    StringBuffer rawXmlBuffer = StringBuffer();
    bool streamNeedsXmlParsing = false;
    String? finalContentFromStream; // To capture all text content from stream

    bool isFirstChunk = true;
    await for (final chunk in stream) {
      if (isFirstChunk) {
        setState(() { _isWating = false; });
        isFirstChunk = false;
      }
      if (_isCancelled) break;

      if (chunk.content != null) {
        _currentResponse += chunk.content!;
        finalContentFromStream = _currentResponse;
      }
      if (chunk.toolCalls != null) {
        accumulatedToolCalls.addAll(chunk.toolCalls!);
      }
      if (chunk.needsXmlParsing && chunk.rawToolCallXml != null) {
        streamNeedsXmlParsing = true;
        rawXmlBuffer.write(chunk.rawToolCallXml!);
      }

      // Update the last message (the assistant message initialized by _initializeAssistantResponse)
      // with the current accumulated text. Tool calls are processed after the stream.
      setState(() {
        if (_messages.isNotEmpty && _messages.last.role == MessageRole.assistant) {
          _messages.last = _messages.last.copyWith(content: _currentResponse);
        }
      });
    }
    _isCancelled = false; // Reset cancellation flag

    // Construct the final response from accumulated parts
    final LLMResponse finalResponse = LLMResponse(
      content: finalContentFromStream, // Use the fully accumulated text content
      toolCalls: accumulatedToolCalls.isNotEmpty ? accumulatedToolCalls : null,
      rawToolCallXml: rawXmlBuffer.isNotEmpty ? rawXmlBuffer.toString() : null,
      needsXmlParsing: streamNeedsXmlParsing || (rawXmlBuffer.isNotEmpty),
    );

    // If the stream yielded no actual content for the assistant message,
    // and no tool calls will be processed from this response,
    // we might have an empty assistant message.
    // Let's remove the empty assistant message if finalResponse is also empty.
    if ((finalResponse.content == null || finalResponse.content!.trim().isEmpty) &&
        (finalResponse.toolCalls == null || finalResponse.toolCalls!.isEmpty) &&
        (finalResponse.rawToolCallXml == null || finalResponse.rawToolCallXml!.trim().isEmpty)) {
      if (_messages.isNotEmpty && _messages.last.role == MessageRole.assistant && (_messages.last.content == null || _messages.last.content!.trim().isEmpty)) {
        // Before removing, ensure _parentMessageId is reverted if this message was setting a new parent.
        // This requires knowing the parent of _messages.last.
        final lastMessageParentId = _messages.last.parentMessageId;
        _messages.removeLast();
        _parentMessageId = lastMessageParentId; // Revert _parentMessageId
      }
    }


    // Now process the final response for tool calls or final content updates
    _processLLMResponseAndExtractToolCalls(finalResponse);

    Logger.root.info('end process llm response. Final accumulated response: ${finalResponse.toJson()}');
    setState(() {}); // Ensure UI updates after processing.
  }

  List<ChatMessage> _prepareMessageList() {
    final List<ChatMessage> messageList = _messages
        .map((m) => ChatMessage(
              role: m.role,
              content: m.content,
              toolCallId: m.toolCallId,
              name: m.name,
              toolCalls: m.toolCalls,
              files: m.files,
            ))
        .toList();

    _reorderMessages(messageList);
    return messageList;
  }

  List<ChatMessage> messageMerge(List<ChatMessage> messageList) {
    final newMessages = [messageList.first];

    for (final message in messageList.sublist(1)) {
      if (newMessages.last.role == message.role) {
        String content = message.content ?? '';

        // final RegExp functionResultRegex = RegExp(
        //     '<call_function_result\\s+name=["\']([^"\']*)["\']\\s*>(.*?)</call_function_result>',
        //     dotAll: true);

        // if (!content.contains('<call_function_result') ||
        //     !functionResultRegex.hasMatch(content)) {
        //   newMessages.add(message);
        //   continue;
        // }

        // content =
        //     content.replaceAll('<call_function_result', '\nfunction_result');
        // content = content.replaceAll('</call_function_result>', '');
        // content = content.replaceAll('>', '');

        newMessages.last = newMessages.last.copyWith(
          content: '${newMessages.last.content}\n\n$content',
        );
      } else {
        newMessages.add(message);
      }
    }

    if (newMessages.last.role != MessageRole.user) {
      newMessages.add(ChatMessage(
        content: 'continue',
        role: MessageRole.user,
      ));
    }

    return newMessages;
  }

  void _reorderMessages(List<ChatMessage> messageList) {
    for (int i = 0; i < messageList.length - 1; i++) {
      if (messageList[i].role == MessageRole.user &&
          messageList[i + 1].role == MessageRole.tool) {
        final temp = messageList[i];
        messageList[i] = messageList[i + 1];
        messageList[i + 1] = temp;
        i++;
      }
    }
  }

  void _initializeAssistantResponse() {
    setState(() {
      _currentResponse = '';
      _messages.add(
        ChatMessage(
          content: _currentResponse,
          role: MessageRole.assistant,
          parentMessageId: _parentMessageId,
        ),
      );
    });
  }

  // Removed _processResponseStream as its logic is now merged into _processLLMResponse
  // Future<void> _processResponseStream(Stream<LLMResponse> stream) async { ... }

  Future<void> _updateChat() async {
    if (ProviderManager.chatProvider.activeChat == null) {
      await _createNewChat();
    } else {
      await _updateExistingChat();
    }
  }

  Future<void> _createNewChat() async {
    String title =
        await _llmClient!.genTitle([_messages.first, _messages.last]);
    await ProviderManager.chatProvider
        .createChat(Chat(title: title), _handleParentMessageId(_messages));
    Logger.root.info('create new chat: $title');
  }

  // messages parentMessageId 处理
  List<ChatMessage> _handleParentMessageId(List<ChatMessage> messages) {
    if (messages.isEmpty) return [];

    // 找到最后一条用户消息的索引
    int lastUserIndex =
        messages.lastIndexWhere((m) => m.role == MessageRole.user);
    if (lastUserIndex == -1) return messages;

    // 获取从最后一条用户消息开始的所有消息
    List<ChatMessage> relevantMessages = messages.sublist(lastUserIndex);

    // 如果消息数大于2，重置第二条之后消息的parentMessageId
    if (relevantMessages.length > 2) {
      String secondMessageId = relevantMessages[1].messageId;
      for (int i = 2; i < relevantMessages.length; i++) {
        relevantMessages[i] = relevantMessages[i].copyWith(
          parentMessageId: secondMessageId,
        );
      }
    }

    return relevantMessages;
  }

  Future<void> _updateExistingChat() async {
    final activeChat = ProviderManager.chatProvider.activeChat!;
    await ProviderManager.chatProvider.updateChat(Chat(
      id: activeChat.id!,
      title: activeChat.title,
      createdAt: activeChat.createdAt,
      updatedAt: DateTime.now(),
    ));

    await ProviderManager.chatProvider
        .addChatMessage(activeChat.id!, _handleParentMessageId(_messages));
  }

  void _handleError(dynamic error, StackTrace stackTrace) {
    Logger.root.severe('error: $error');
    Logger.root.severe('stackTrace: $stackTrace');

    // 尝试提取更多错误信息
    if (error is TypeError) {
      Logger.root.severe('类型错误: ${error.toString()}');
    }

    // 重置所有相关状态
    _resetState();

    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.getErrorIconColor()),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.error),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getUserFriendlyErrorMessage(error),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.getErrorTextColor(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'error type: ${error.runtimeType}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.getErrorTextColor().withAlpha(128),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.close),
              ),
            ],
          );
        },
      );
    }
  }

  // 处理错误信息
  String _getUserFriendlyErrorMessage(dynamic error) {
    final errorMap = {
      'connection': AppLocalizations.of(context)!.networkError,
      'timeout': AppLocalizations.of(context)!.timeoutError,
      'permission': AppLocalizations.of(context)!.permissionError,
      'cancelled': AppLocalizations.of(context)!.userCancelledToolCall,
      'No element': AppLocalizations.of(context)!.noElementError,
      'not found': AppLocalizations.of(context)!.notFoundError,
      'invalid': AppLocalizations.of(context)!.invalidError,
      'unauthorized': AppLocalizations.of(context)!.unauthorizedError,
    };

    for (final entry in errorMap.entries) {
      if (error.toString().toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return AppLocalizations.of(context)!.unknownError;
  }

  // 处理分享事件
  Future<void> _handleShare(ShareEvent event) async {
    if (_messages.isEmpty) return;
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      if (kIsMobile) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListViewToImageScreen(messages: _messages),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => ListViewToImageScreen(messages: _messages),
        );
      }
    }
  }

  bool _isMobile() {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return height > width;
  }

  void _resetState() {
    setState(() {
      _isRunningFunction = false;
      _runFunctionEvents.clear();
      _isLoading = false;
      _isCancelled = false;
      _isWating = false;
      _currentLoop = 0;
    });
  }

  void _handleCancel() {
    _resetState();
    setState(() {
      _isCancelled = true;
    });
  }

  CodePreviewEvent? _codePreviewEvent;

  void _onArtifactEvent(CodePreviewEvent event) {
    // _toggleCodePreview();
    setState(() {
      _codePreviewEvent = event;
    });
  }

  bool showModalCodePreview = false;
  void _showMobileCodePreview() {
    setState(() {
      showModalCodePreview = true;
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.getBottomSheetHandleColor(context),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: _codePreviewEvent != null
                          ? ChatCodePreview(
                              codePreviewEvent: _codePreviewEvent!,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFunctionRunning() {
    if (_isRunningFunction) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.functionRunning,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withAlpha((0.7 * 255).round()),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    if (mobile) {
      return Column(
        children: [
          _buildMessageList(),
          _buildFunctionRunning(),
          InputArea(
            disabled: _isLoading,
            isComposing: _isComposing,
            onTextChanged: _handleTextChanged,
            onSubmitted: _handleSubmitted,
            onCancel: _handleCancel,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildMessageList(),
              _buildFunctionRunning(),
              InputArea(
                disabled: _isLoading,
                isComposing: _isComposing,
                onTextChanged: _handleTextChanged,
                onSubmitted: _handleSubmitted,
                onCancel: _handleCancel,
              ),
            ],
          ),
        ),
        if (!mobile && _showCodePreview)
          Expanded(
            flex: 2,
            child: ChatCodePreview(
              codePreviewEvent: ProviderManager.chatProvider.artifactEvent!,
            ),
          ),
      ],
    );
  }
}
