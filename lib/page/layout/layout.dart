import 'package:flutter/material.dart';

import './chat_page/chat_page.dart';
import './chat_history.dart';
import '../setting/setting.dart';

class LayoutPage extends StatefulWidget {
  const LayoutPage({super.key});

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage> {
  bool hideChatHistory = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 顶部菜单栏
          Container(
            padding: const EdgeInsets.only(left: 60, right: 8),
            height: 50,
            color: Colors.grey[100],
            child: Row(
              children: [
                const Spacer(),
                IconButton(
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
              ],
            ),
          ),
          // 主体内容
          Expanded(
            child: Row(
              children: [
                if (!hideChatHistory)
                  Container(
                    width: 250,
                    color: Colors.grey[200],
                    child: const ChatHistoryPanel(),
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
