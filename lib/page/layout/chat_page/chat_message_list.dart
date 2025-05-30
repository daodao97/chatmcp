import 'package:chatmcp/utils/stream.dart';
import 'package:flutter/material.dart';
import 'package:chatmcp/llm/model.dart';
import 'package:flutter/rendering.dart';
import 'chat_message.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'animated_chat_message_item.dart'; // Import the new animation widget

import 'scroll_down_button.dart';

class MessageList extends StatefulWidget {
  final List<ChatMessage> messages;
  final Function(ChatMessage) onRetry;
  final Function(String messageId) onSwitch;
  const MessageList({
    super.key,
    required this.messages,
    required this.onRetry,
    required this.onSwitch,
  });

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final ScrollController _scrollController = ScrollController();
  late final Stream<ScrollDirection> _scrollDirectionChangedStream =
      asStream<ScrollDirection>(_scrollController, () {
    return _scrollController.position.userScrollDirection;
  }).distinct();

  bool _stickToBottom = true;
  late final double endScroll = _scrollController.position.minScrollExtent;

  bool _isScrolledToBottom({double threshold = 1.0}) {
    if (!_scrollController.hasClients) return true;
    final currentScroll = _scrollController.offset;
    // 允许1像素的误差
    return (endScroll - currentScroll).abs() <= threshold;
  }

  Future _scrollToBottom({bool withDelay = true}) async {
    if (_isScrolledToBottom()) {
      return;
    }
    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
    setState(() {
      _stickToBottom = true;
    });
  }

  @override
  void didUpdateWidget(MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_stickToBottom) {
      _scrollToBottom(withDelay: false);
    }
    if (_userAddedMessage(oldWidget)) {
      _scrollToBottom();
    }
  }

  bool _userAddedMessage(MessageList oldWidget) {
    var currentUserMessages =
        widget.messages.where((msg) => msg.role == MessageRole.user).toList();
    var oldUserMessages = oldWidget.messages
        .where((msg) => msg.role == MessageRole.user)
        .toList();
    return currentUserMessages.length != oldUserMessages.length;
  }

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;
      if (direction != ScrollDirection.idle && _isScrolledToBottom()) {
        setState(() {
          _stickToBottom = true;
        });
      }
    });

    _scrollDirectionChangedStream.listen((direction) {
      if (direction == ScrollDirection.reverse) {
        setState(() {
          _stickToBottom = false;
        });
      }
    });

    _scrollToBottom();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        if (isKeyboardVisible) {
          _scrollToBottom();
        }

        // 将消息分组
        List<List<ChatMessage>> groupedMessages = [];
        List<ChatMessage> currentGroup = [];

        for (var msg in widget.messages.reversed) {
          if (msg.role == MessageRole.user) {
            if (currentGroup.isNotEmpty) {
              groupedMessages.add(currentGroup);
              currentGroup = [];
            }
            currentGroup.add(msg);
            groupedMessages.add(currentGroup);
            currentGroup = [];
          } else {
            currentGroup.insert(0, msg);
          }
        }

        if (currentGroup.isNotEmpty) {
          groupedMessages.add(currentGroup);
        }

        return Stack(
          children: [
            ListView.builder(
              reverse: true,
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: groupedMessages.length,
              // physics: const ClampingScrollPhysics(), // 禁用弹性效果
              itemBuilder: (context, index) {
                final group = groupedMessages[index];
                // Use the ID of the first message in the group as a key.
                // This helps ensure the AnimatedChatMessageItem is treated as a new widget
                // when a new message group appears, triggering its initState and animation.
                // Ensure group is not empty and has an ID.
                final String? keyString = group.isNotEmpty ? group.first.messageId : null; // Corrected: id to messageId

                return AnimatedChatMessageItem(
                  key: keyString != null ? ValueKey(keyString) : null,
                  child: ChatUIMessage(
                    messages: group,
                    onRetry: widget.onRetry,
                    onSwitch: widget.onSwitch,
                  ),
                );
              },
            ),
            // if (!_isScrolledToBottom())
            //   Positioned(
            //     bottom: 10,
            //     left: 0,
            //     right: 0,
            //     child: Center(
            //       child: ScrollDownButton(
            //         onPressed: () {
            //           _stickToBottom = true;
            //           _scrollToBottom(withDelay: false);
            //         },
            //       ),
            //     ),
            //   ),
          ],
        );
      },
    );
  }
}
