import 'package:flutter/material.dart';

class AppColors {
  static const Color white = Colors.white;
  static const MaterialColor grey = Colors.grey;
  static const Color black = Colors.black;
  static const MaterialColor green = Colors.green;
  static const MaterialColor red = Colors.red;
  static const MaterialColor blue = Colors.blue;
  static const Color transparent = Colors.transparent;

  /// Returns the corresponding color based on the theme
  static Color getThemeColor(BuildContext context,
      {Color? lightColor, Color? darkColor}) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.light
        ? (lightColor ?? black)
        : (darkColor ?? white);
  }

  /// Gets the background color related to the theme
  static Color getThemeBackgroundColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: grey[200],
      darkColor: grey[800],
    );
  }

  static Color getThemeTextColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: Colors.black87,
      darkColor: Colors.white,
    );
  }

  static Color getLayoutBackgroundColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: Colors.white,
      darkColor: Colors.black26,
    );
  }

  static Color getSidebarBackgroundColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: Colors.grey[200],
      darkColor: Colors.grey[900],
    );
  }

  static Color getSidebarActiveConversationColor(BuildContext context) {
    return getThemeColor(
      context,
      lightColor: AppColors.grey[300],
      darkColor: AppColors.grey[700],
    );
  }

  static Color getToolbarBackgroundColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[100], darkColor: AppColors.grey[900]);
  }

  static Color getTextButtonColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.blue[300], darkColor: AppColors.blue[100]);
  }

  static Color getCodeTabActiveColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.blue[300], darkColor: AppColors.blue[300]);
  }

  static Color getCodeTabInactiveColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.blue[100], darkColor: AppColors.blue[100]);
  }

  static Color getCodePreviewBorderColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[200], darkColor: AppColors.grey[800]);
  }

  static Color getCodeLanguageTextColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[600], darkColor: AppColors.grey[300]);
  }

  static Color getInactiveTextColor(BuildContext context) {
    return AppColors.grey[600]!;
  }

  static Color getMessageBranchDisabledColor() {
    return AppColors.grey[400]!;
  }

  static Color getMessageBranchIndicatorTextColor() {
    return AppColors.grey[600]!;
  }

  // 文件附件相关颜色
  static Color getFileAttachmentBackgroundColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[200], darkColor: AppColors.grey[800]);
  }

  // 图片错误图标颜色
  static Color getImageErrorIconColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[600], darkColor: AppColors.grey[400]);
  }

  // 消息气泡背景色
  static Color getMessageBubbleBackgroundColor(
      BuildContext context, bool isUserMessage) {
    return getThemeColor(context,
        lightColor: AppColors.grey[100], darkColor: Colors.white12);
  }

  // 工具调用和工具结果文本颜色
  static Color getToolCallTextColor() {
    return AppColors.grey[600]!;
  }

  // 聊天头像背景色
  static Color getChatAvatarBackgroundColor() {
    return AppColors.grey;
  }

  // 聊天头像图标颜色
  static Color getChatAvatarIconColor() {
    return AppColors.white;
  }

  // 欢迎信息文本颜色
  static Color getWelcomeMessageColor() {
    return AppColors.grey;
  }

  // 错误提示图标颜色
  static Color getErrorIconColor() {
    return AppColors.red;
  }

  // 错误提示文本颜色
  static Color getErrorTextColor() {
    return AppColors.red;
  }

  // 底部菜单滑块颜色
  static Color getBottomSheetHandleColor(BuildContext context) {
    return AppColors.grey.withOpacity(0.3);
  }

  // 工具栏底部边框颜色
  static Color getToolbarBottomBorderColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[200], darkColor: AppColors.grey[800]);
  }

  // 侧边栏切换按钮图标颜色
  static Color getSidebarToggleIconColor() {
    return AppColors.grey[700]!;
  }

  // Markdown相关颜色定义

  // artifact组件背景色
  static Color getArtifactBackgroundColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: Colors.grey[50], darkColor: Colors.grey[800]);
  }

  // artifact组件边框颜色
  static Color getArtifactBorderColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: Colors.grey[300], darkColor: Colors.grey[700]);
  }

  // 进度指示器颜色
  static Color getProgressIndicatorColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: Colors.orange, darkColor: Colors.orange);
  }

  // 思考组件背景色
  static Color getThinkBackgroundColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[300], darkColor: AppColors.grey[700]);
  }

  // 思考组件边框颜色
  static Color getThinkBorderColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[200], darkColor: AppColors.grey[700]);
  }

  // 思考图标颜色
  static Color getThinkIconColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: Colors.orange, darkColor: Colors.orange);
  }

  // 思考文本颜色
  static Color getThinkTextColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[500], darkColor: AppColors.grey[300]);
  }

  // 展开/收起图标颜色
  static Color getExpandIconColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[600], darkColor: AppColors.grey[300]);
  }

  // 函数组件背景色
  static Color getFunctionBackgroundColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[100], darkColor: AppColors.grey[900]);
  }

  // 函数组件边框颜色
  static Color getFunctionBorderColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[300], darkColor: AppColors.grey[700]);
  }

  // 函数图标颜色
  static Color getFunctionIconColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: Colors.orange[200], darkColor: Colors.orange[300]);
  }

  // 函数文本颜色
  static Color getFunctionTextColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[500], darkColor: AppColors.grey[300]);
  }

  // 运行按钮颜色
  static Color getPlayButtonColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: Colors.green, darkColor: Colors.green[300]);
  }

  // 代码块工具栏背景色
  static Color getCodeBlockToolbarBackgroundColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[300], darkColor: AppColors.grey[900]);
  }

  // 代码块语言文本颜色
  static Color getCodeBlockLanguageTextColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[700], darkColor: AppColors.grey[300]);
  }

  // 代码预览按钮背景色
  static Color getCodePreviewButtonBackgroundColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[100], darkColor: AppColors.grey[900]);
  }

  // 链接颜色
  static Color getLinkColor() {
    return Colors.blue;
  }

  // 输入区域相关颜色
  static Color getInputAreaBackgroundColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: Colors.white, darkColor: Colors.grey.shade900);
  }

  static Color getInputAreaBorderColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: Colors.grey.shade300, darkColor: Colors.grey.shade700);
  }

  static Color getInputAreaFileItemBackgroundColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: Colors.grey.shade200,
        darkColor: Colors.grey.shade800.withAlpha(100));
  }

  static Color getInputAreaHintTextColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: Colors.grey.shade600, darkColor: Colors.grey.shade400);
  }

  static Color getInputAreaTextColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: Colors.black87, darkColor: Colors.white);
  }

  static Color getInputAreaIconColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: Colors.grey.shade600, darkColor: Colors.grey.shade400);
  }

  static Color getInputAreaFileIconColor(BuildContext context) {
    return Theme.of(context).primaryColor.withOpacity(0.8);
  }

  // InkIcon相关颜色
  static Color getInkIconHoverColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: Colors.grey.shade200, darkColor: Colors.grey.shade700);
  }

  // 聊天加载相关颜色
  static Color getChatLoadingColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: Theme.of(context).primaryColor,
        darkColor: Colors.white.withAlpha(50));
  }

  // 输入区域光标颜色
  static Color getInputAreaCursorColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: Colors.grey.shade400, darkColor: Colors.grey.shade400);
  }
}
