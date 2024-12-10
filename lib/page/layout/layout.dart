import 'package:flutter/material.dart';

import './chat_page/chat_page.dart';
import './chat_history.dart';
import 'package:ChatMcp/provider/provider_manager.dart';

class LayoutPage extends StatefulWidget {
  const LayoutPage({super.key});

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage> {
  bool hideChatHistory = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          if (!hideChatHistory)
            Container(
              width: 250,
              color: Colors.grey[200],
              child: ChatHistoryPanel(
                onToggle: () => setState(() {
                  hideChatHistory = !hideChatHistory;
                }),
              ),
            ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 50,
                  color: Colors.grey[100],
                  padding: const EdgeInsets.fromLTRB(70, 0, 16, 0),
                  child: Row(
                    children: [
                      if (hideChatHistory)
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () => setState(() {
                            hideChatHistory = !hideChatHistory;
                          }),
                        ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          ProviderManager.chatProvider.clearActiveChat();
                        },
                      ),
                    ],
                  ),
                ),
                const Expanded(
                  child: ChatPage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
