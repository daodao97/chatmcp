import 'package:flutter/material.dart';

// 各个设置页面的占位 Widget
class GeneralSettings extends StatelessWidget {
  const GeneralSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text('通用设置页面'),
    );
  }
}
