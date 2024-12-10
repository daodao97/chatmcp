import 'package:flutter/material.dart';
import 'llm_setting.dart';
import 'mcp_server.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  int _selectedIndex = 0;

  final List<SettingTab> _tabs = [
    SettingTab(
      title: 'LLM Model',
      icon: Icons.api,
      content: const LlmSettings(),
    ),
    SettingTab(
      title: 'MCP Server',
      icon: Icons.storage,
      content: const McpServer(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 左侧选项卡列表
        Container(
          width: 200,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: ListView.builder(
            itemCount: _tabs.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(_tabs[index].icon),
                title: Text(_tabs[index].title),
                selected: _selectedIndex == index,
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              );
            },
          ),
        ),
        // 右侧配置内容
        Expanded(
          child: _tabs[_selectedIndex].content,
        ),
      ],
    );
  }
}

// 选项卡数据模型
class SettingTab {
  final String title;
  final IconData icon;
  final Widget content;

  SettingTab({
    required this.title,
    required this.icon,
    required this.content,
  });
}
