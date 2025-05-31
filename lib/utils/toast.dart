import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';

class ToastUtils {
  /// 显示错误级别的 toast 通知
  /// [message] 错误信息
  /// [duration] 显示持续时间，默认 5 秒
  static void error(String message, {Duration? duration}) {
    BotToast.showText(
      text: message,
      duration: duration ?? Duration(seconds: 5),
      align: Alignment(0.0, -0.7),
      contentColor: Colors.red.shade600,
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// 显示警告级别的 toast 通知
  /// [message] 警告信息
  /// [duration] 显示持续时间，默认 4 秒
  static void warn(String message, {Duration? duration}) {
    BotToast.showText(
      text: message,
      duration: duration ?? Duration(seconds: 4),
      align: Alignment(0.0, -0.7),
      contentColor: Colors.orange.shade600,
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// 显示信息级别的 toast 通知
  /// [message] 信息内容
  /// [duration] 显示持续时间，默认 3 秒
  static void info(String message, {Duration? duration}) {
    BotToast.showText(
      text: message,
      duration: duration ?? Duration(seconds: 3),
      align: Alignment(0.0, -0.7),
      contentColor: Colors.blue.shade600,
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// 显示成功级别的 toast 通知
  /// [message] 成功信息
  /// [duration] 显示持续时间，默认 3 秒
  static void success(String message, {Duration? duration}) {
    BotToast.showText(
      text: message,
      duration: duration ?? Duration(seconds: 3),
      align: Alignment(0.0, -0.7),
      contentColor: Colors.green.shade600,
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// 显示自定义样式的 toast 通知
  /// [message] 消息内容
  /// [color] 背景颜色
  /// [duration] 显示持续时间
  /// [align] 对齐方式
  static void custom({
    required String message,
    required Color color,
    Duration? duration,
    Alignment? align,
    TextStyle? textStyle,
  }) {
    BotToast.showText(
      text: message,
      duration: duration ?? Duration(seconds: 3),
      align: align ?? Alignment(0.0, -0.7),
      contentColor: color,
      textStyle: textStyle ??
          TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
    );
  }
}
