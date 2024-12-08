import 'package:flutter/material.dart';
import 'package:ChatMcp/llm/model.dart';
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';

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
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: msg.role == MessageRole.user
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: msg.role == MessageRole.user
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: msg.role == MessageRole.user
                      ? Text(
                          msg.content ?? '',
                          style: const TextStyle(color: Colors.white),
                        )
                      : MarkdownBody(
                          data: msg.content ??
                              (msg.toolCalls?.isNotEmpty ?? false
                                  ? [
                                      '```json',
                                      const JsonEncoder.withIndent('  ')
                                          .convert(
                                              msg.toolCalls![0]['function']),
                                      '```',
                                    ].join('\n')
                                  : ''),
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(
                              color: Colors.black,
                            ),
                            code: TextStyle(
                              backgroundColor: Colors.grey[200],
                              color: Colors.black87,
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                ),
                if (msg.toolCalls != null && msg.toolCalls!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '${msg.McpServerName} call_${msg.toolCalls![0]['function']['name']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                if (msg.role == MessageRole.tool && msg.toolCallId != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '${msg.McpServerName} ${msg.toolCallId!} result',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
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
