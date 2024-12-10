import 'package:flutter/material.dart';
import '../setting/setting.dart';
import 'package:provider/provider.dart';
import 'package:ChatMcp/provider/chat_provider.dart';

class ChatHistoryPanel extends StatelessWidget {
  final VoidCallback? onToggle;
  const ChatHistoryPanel({super.key, this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) => SizedBox(
        height: double.infinity,
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 35, left: 8, right: 8),
              child: ListView.builder(
                itemCount: chatProvider.chats.length,
                itemBuilder: (context, index) {
                  final chat = chatProvider.chats[index];
                  final isActive = chat.id == chatProvider.activeChat?.id;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.grey.withOpacity(0.1) : null,
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              )
                            ]
                          : null,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(vertical: -4),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.title,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${chat.updatedAt.month}/${chat.updatedAt.day}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      subtitle: null,
                      onTap: () => chatProvider.setActiveChat(chat),
                    ),
                  );
                },
              ),
            ),
            // 右上角的开关按钮
            Positioned(
              top: 0,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.menu_open),
                onPressed: onToggle,
              ),
            ),
            // 左下角的设置按钮
            Positioned(
              bottom: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: const SettingPage(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
