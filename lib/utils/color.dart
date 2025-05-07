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

  // File attachment related colors
  static Color getFileAttachmentBackgroundColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[200], darkColor: AppColors.grey[800]);
  }

  // Image error icon color
  static Color getImageErrorIconColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[600], darkColor: AppColors.grey[400]);
  }

  // Message bubble background color
  static Color getMessageBubbleBackgroundColor(
      BuildContext context, bool isUserMessage) {
    return getThemeColor(context,
        lightColor: AppColors.grey[100], darkColor: Colors.white12);
  }

  // Tool call and tool result text color
  static Color getToolCallTextColor() {
    return AppColors.grey[600]!;
  }

  // Chat avatar background color
  static Color getChatAvatarBackgroundColor() {
    return AppColors.grey;
  }

  // Chat avatar icon color
  static Color getChatAvatarIconColor() {
    return AppColors.white;
  }

  // Welcome message text color
  static Color getWelcomeMessageColor() {
    return AppColors.grey;
  }

  // Error prompt icon color
  static Color getErrorIconColor() {
    return AppColors.red;
  }

  // Error prompt text color
  static Color getErrorTextColor() {
    return AppColors.red;
  }

  // Bottom menu slider color
  static Color getBottomSheetHandleColor(BuildContext context) {
    return AppColors.grey.withOpacity(0.3);
  }

  // Toolbar bottom border color
  static Color getToolbarBottomBorderColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[200], darkColor: AppColors.grey[800]);
  }

  // Sidebar toggle button icon color
  static Color getSidebarToggleIconColor() {
    return AppColors.grey[700]!;
  }

  // Markdown related color definitions

  // artifact component background color
  static Color getArtifactBackgroundColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: Colors.grey[50], darkColor: Colors.grey[800]);
  }

  // artifact component border color
  static Color getArtifactBorderColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: Colors.grey[300], darkColor: Colors.grey[700]);
  }

  // Progress indicator color
  static Color getProgressIndicatorColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: Colors.orange, darkColor: Colors.orange);
  }

  // Think component background color
  static Color getThinkBackgroundColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[300], darkColor: AppColors.grey[700]);
  }

  // Think component border color
  static Color getThinkBorderColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[200], darkColor: AppColors.grey[700]);
  }

  // Think component icon color
  static Color getThinkIconColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: Colors.orange, darkColor: Colors.orange);
  }

  // Think component text color
  static Color getThinkTextColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[500], darkColor: AppColors.grey[300]);
  }

  // Expand/collapse icon color
  static Color getExpandIconColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[600], darkColor: AppColors.grey[300]);
  }

  // Function component background color
  static Color getFunctionBackgroundColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[100], darkColor: AppColors.grey[900]);
  }

  // Function component border color
  static Color getFunctionBorderColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[300], darkColor: AppColors.grey[700]);
  }

  // Function component icon color
  static Color getFunctionIconColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: Colors.orange[200], darkColor: Colors.orange[300]);
  }

  // Function component text color
  static Color getFunctionTextColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[500], darkColor: AppColors.grey[300]);
  }

  // Run button color
  static Color getPlayButtonColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: Colors.green, darkColor: Colors.green[300]);
  }

  // Code block toolbar background color
  static Color getCodeBlockToolbarBackgroundColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[300], darkColor: AppColors.grey[900]);
  }

  // Code block language text color
  static Color getCodeBlockLanguageTextColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[700], darkColor: AppColors.grey[300]);
  }

  // Code preview button background color
  static Color getCodePreviewButtonBackgroundColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: AppColors.grey[100], darkColor: AppColors.grey[900]);
  }

  // Link color
  static Color getLinkColor() {
    return Colors.blue;
  }

  // Input area related colors
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

  // InkIcon related colors
  static Color getInkIconHoverColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: Colors.grey.shade200, darkColor: Colors.grey.shade700);
  }

  // Chat loading related colors
  static Color getChatLoadingColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: Theme.of(context).primaryColor,
        darkColor: Colors.white.withAlpha(50));
  }

  // Input area cursor color
  static Color getInputAreaCursorColor(BuildContext context) {
    return getThemeColor(context,
        lightColor: Colors.grey.shade400, darkColor: Colors.grey.shade400);
  }
}
