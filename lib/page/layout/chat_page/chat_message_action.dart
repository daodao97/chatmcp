import 'package:flutter/material.dart';
import 'package:chatmcp/llm/model.dart';
import 'package:flutter/services.dart';
import 'package:chatmcp/utils/color.dart';
import 'package:chatmcp/generated/app_localizations.dart';

class MessageActions extends StatelessWidget {
  final List<ChatMessage> messages;
  final Function(ChatMessage) onRetry;
  final Function(String messageId) onSwitch;
  final bool isUser;

  const MessageActions({
    super.key,
    required this.messages,
    required this.onRetry,
    required this.onSwitch,
    this.isUser = false,
  });

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Copy button - available for both user and assistant messages
          IconButton(
            iconSize: 14,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            constraints: const BoxConstraints(
              minWidth: 20,
              minHeight: 20,
            ),
            icon: const Icon(Icons.copy_outlined),
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text: messages.map((m) => m.content ?? '').join('\n'),
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(t.copiedToClipboard),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          // Retry button - only for assistant messages
          if (!isUser)
            IconButton(
              iconSize: 14,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              icon: const Icon(Icons.refresh),
              onPressed: () {
                onRetry(messages.last);
              },
              tooltip: t.retry,
            ),
          // Branch switch - only for assistant messages
          if (!isUser &&
              messages.first.brotherMessageIds != null &&
              messages.first.brotherMessageIds!.isNotEmpty)
            _buildBranchSwitchWidget(messages),
        ],
      ),
    );
  }

  Widget _buildBranchSwitchWidget(List<ChatMessage> messages) {
    int index =
        messages.first.brotherMessageIds!.indexOf(messages.first.messageId) + 1;
    int length = messages.first.brotherMessageIds!.length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          iconSize: 14,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          constraints: const BoxConstraints(
            minWidth: 20,
            minHeight: 20,
          ),
          icon: Icon(
            Icons.arrow_back_ios,
            size: 12,
            color:
                index == 1 ? AppColors.getMessageBranchDisabledColor() : null,
          ),
          onPressed: index == 1
              ? null
              : () {
                  onSwitch(messages.first.brotherMessageIds![index - 2]);
                },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            '$index/$length',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getMessageBranchIndicatorTextColor(),
            ),
          ),
        ),
        IconButton(
          iconSize: 14,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          constraints: const BoxConstraints(
            minWidth: 20,
            minHeight: 20,
          ),
          icon: Icon(
            Icons.arrow_forward_ios,
            size: 12,
            color: index == length
                ? AppColors.getMessageBranchDisabledColor()
                : null,
          ),
          onPressed: index == length
              ? null
              : () {
                  onSwitch(messages.first.brotherMessageIds![index]);
                },
        ),
      ],
    );
  }
}
