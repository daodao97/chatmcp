import 'package:flutter/material.dart';
import 'package:ChatMcp/llm/model.dart';
import 'dart:convert';
import 'package:ChatMcp/widgets/collapsible_section.dart';
import 'package:ChatMcp/widgets/markit.dart';

class ChatUIMessage extends StatelessWidget {
  final ChatMessage msg;
  final bool showAvatar;

  const ChatUIMessage({
    super.key,
    required this.msg,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: showAvatar
          ? const EdgeInsets.symmetric(vertical: 8.0)
          : const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: msg.role == MessageRole.user
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (msg.role != MessageRole.user)
            SizedBox(
              width: 40,
              child: showAvatar ? _buildAvatar(false) : null,
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: msg.role == MessageRole.user
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (msg.role == MessageRole.loading)
                  const CircularProgressIndicator(),
                if ((msg.role == MessageRole.user ||
                        msg.role == MessageRole.assistant) &&
                    msg.content != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg.role == MessageRole.user
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: msg.role == MessageRole.user
                        ? TextSelectionTheme(
                            data: TextSelectionThemeData(
                              selectionColor: Colors.white.withOpacity(0.3),
                            ),
                            child: SelectableText(
                              msg.content ?? '',
                              style: const TextStyle(color: Colors.white),
                            ),
                          )
                        : msg.content != null
                            ? Markit(data: msg.content!)
                            : const Text('22'),
                  ),
                if (msg.toolCalls != null && msg.toolCalls!.isNotEmpty)
                  CollapsibleSection(
                    title: Text(
                      '${msg.mcpServerName} call_${msg.toolCalls![0]['function']['name']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    content: Markit(
                      data: (msg.toolCalls?.isNotEmpty ?? false)
                          ? [
                              '```json',
                              const JsonEncoder.withIndent('  ').convert({
                                "name": msg.toolCalls![0]['function']['name'],
                                "arguments": json.decode(
                                    msg.toolCalls![0]['function']['arguments']),
                              }),
                              '```',
                            ].join('\n')
                          : '',
                    ),
                  ),
                if (msg.role == MessageRole.tool && msg.toolCallId != null)
                  CollapsibleSection(
                    title: Text(
                      '${msg.mcpServerName} ${msg.toolCallId!} result',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    content: Markit(data: msg.content ?? ''),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (msg.role == MessageRole.user) _buildAvatar(true),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return CircleAvatar(
      backgroundColor: isUser ? Colors.blue : Colors.grey,
      child: Icon(
        isUser ? Icons.person : Icons.android,
        color: Colors.white,
      ),
    );
  }
}
