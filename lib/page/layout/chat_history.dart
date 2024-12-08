import 'package:flutter/material.dart';

class ChatHistoryPanel extends StatelessWidget {
  const ChatHistoryPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 35, left: 8, right: 8),
            child: ListView.builder(
              itemCount: 1, // 显示前30条聊天记录
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: index == 0
                        ? Colors.grey.withOpacity(0.1)
                        : null, // 当前活动的聊天记录背景色
                    boxShadow: index == 0
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
                    title: Text(
                      '聊天 ${30 - index}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      '上次聊天时间: 2024-03-${30 - index}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      // TODO: 处理点击聊天记录的逻辑
                    },
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
              icon: const Icon(Icons.settings),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
