import 'package:chatmcp/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:chatmcp/llm/model.dart';
import 'chat_message.dart';
import 'chat_message_action.dart';
import 'package:file_picker/file_picker.dart';
import 'package:chatmcp/provider/provider_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:chatmcp/utils/platform.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logging/logging.dart';
import 'package:chatmcp/utils/color.dart';
import 'package:provider/provider.dart';
import 'package:chatmcp/provider/settings_provider.dart';

class ListViewToImageScreen extends StatefulWidget {
  final List<ChatMessage> messages;
  const ListViewToImageScreen({super.key, required this.messages});

  @override
  _ListViewToImageScreenState createState() => _ListViewToImageScreenState();
}

class _ListViewToImageScreenState extends State<ListViewToImageScreen> {
  final ScrollController _scrollController = ScrollController();
  final screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.shareChatImage),
        leading: IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: Icon(Icons.camera), onPressed: _captureListViewAsImage)],
      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false, // 完全禁用滚动条
        ),
        child: SingleChildScrollView(controller: _scrollController, child: _buildMessage()),
      ),
    );
  }

  Widget _buildMessage() {
    List<List<ChatMessage>> groupedMessages = [];
    List<ChatMessage> currentGroup = [];

    for (var msg in widget.messages) {
      if (msg.role == MessageRole.user) {
        if (currentGroup.isNotEmpty) {
          groupedMessages.add(currentGroup);
          currentGroup = [];
        }
        currentGroup.add(msg);
        groupedMessages.add(currentGroup);
        currentGroup = [];
      } else {
        currentGroup.add(msg);
      }
    }

    if (currentGroup.isNotEmpty) {
      groupedMessages.add(currentGroup);
    }

    // 直接使用屏幕宽度，避免LayoutBuilder约束问题
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05; // 使用5%作为padding

    return SizedBox(
      width: screenWidth,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ProviderManager.chatProvider.activeChat?.title != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(ProviderManager.chatProvider.activeChat!.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    Text(AppLocalizations.of(context)!.createdWithChatMcp, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: 16),
            ],
            ...groupedMessages.map((group) {
              return ScreenshotChatUIMessage(
                messages: group,
                availableWidth: screenWidth - (horizontalPadding * 2),
                onRetry: (ChatMessage message) {},
                onSwitch: (String messageId) {},
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _captureListViewAsImage() async {
    try {
      final screenWidth = MediaQuery.of(context).size.width;
      final theme = Theme.of(context);

      // 调试信息
      Logger.root.info('Screen width: $screenWidth');

      // 创建一个离屏widget来渲染完整内容
      final renderWidget = Screenshot(
        controller: screenshotController,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            devicePixelRatio: 2.0, // 降低pixelRatio，避免过度缩放
            // 强制设置屏幕尺寸，确保宽度不变
            size: Size(screenWidth, double.infinity),
          ),
          child: Theme(
            data: theme,
            child: Material(
              color: theme.scaffoldBackgroundColor,
              child: SizedBox(width: screenWidth, child: _buildMessage()),
            ),
          ),
        ),
      );

      // 使用Overlay将widget临时添加到屏幕外
      final overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: -screenWidth - 100, // 确保完全在屏幕外
          top: 0,
          child: SizedBox(width: screenWidth, child: renderWidget),
        ),
      );

      Overlay.of(context).insert(overlayEntry);

      // 等待widget完全渲染
      await Future.delayed(const Duration(milliseconds: 800));

      // 捕获图像
      final image = await screenshotController.capture(
        pixelRatio: 2.0, // 保持一致的pixelRatio
      );

      // 移除临时widget
      overlayEntry.remove();

      if (image == null) {
        Logger.root.severe('截图失败: 无法获取图片');
        return;
      }

      if (kIsDesktop) {
        final path = await FilePicker.platform.saveFile(
          dialogTitle: ProviderManager.chatProvider.activeChat?.title ?? AppLocalizations.of(context)!.saveChatImage,
          fileName: 'ChatMcp-${ProviderManager.chatProvider.activeChat?.title ?? DateTime.now().millisecondsSinceEpoch}.jpg',
          type: FileType.custom,
          allowedExtensions: ['jpg'],
        );
        if (path != null) {
          await io.File(path).writeAsBytes(image);
        }
      }

      if (kIsMobile) {
        final title = ProviderManager.chatProvider.activeChat?.title ?? 'Chat Image';
        final safeTitle = title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').replaceAll(RegExp(r'\s+'), '_');

        final tempDir = await getTemporaryDirectory();
        final tempFile = io.File('${tempDir.path}/ChatMcp_${safeTitle}_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(image);

        await SharePlus.instance.share(ShareParams(files: [XFile(tempFile.path)], subject: "ChatMcp $title"));
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      Logger.root.severe('截图失败: $e');
    }
  }
}

// 专门用于截图的消息组件，避免Flexible导致的宽度压缩
class ScreenshotChatUIMessage extends StatelessWidget {
  final List<ChatMessage> messages;
  final double availableWidth;
  final Function(ChatMessage) onRetry;
  final Function(String messageId) onSwitch;

  const ScreenshotChatUIMessage({super.key, required this.messages, required this.availableWidth, required this.onRetry, required this.onSwitch});

  List<ChatMessage> _filterMessages(List<ChatMessage> messages) {
    if (messages.length <= 1) return messages;
    return messages.where((m) => m.role != MessageRole.assistant || (m.role == MessageRole.assistant && m.content != '')).toList();
  }

  BubblePosition _getMessagePosition(int index, int total) {
    if (total == 1) return BubblePosition.single;
    if (index == 0) return BubblePosition.first;
    if (index == total - 1) return BubblePosition.last;
    return BubblePosition.middle;
  }

  Widget _buildMessageGroup(BuildContext context, List<ChatMessage> messages, bool isUser) {
    final filteredMessages = _filterMessages(messages);

    if (filteredMessages.isEmpty) return const SizedBox();

    if (filteredMessages.length == 1) {
      return ChatMessageContent(message: filteredMessages[0], onRetry: onRetry, position: BubblePosition.single);
    }

    return Container(
      decoration: BoxDecoration(color: AppColors.getMessageBubbleBackgroundColor(context, isUser), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: List.generate(
          filteredMessages.length,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: index == filteredMessages.length - 1 ? 0 : 1),
            child: ChatMessageContent(
              message: filteredMessages[index],
              onRetry: onRetry,
              position: _getMessagePosition(index, filteredMessages.length),
              useTransparentBackground: true,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) return const SizedBox();

    final firstMsg = messages.first;
    final isUser = firstMsg.role == MessageRole.user;

    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final showAssistantAvatar = settings.generalSetting.showAssistantAvatar;
        final showUserAvatar = settings.generalSetting.showUserAvatar;

        // 计算头像占用的宽度
        double avatarWidth = 0;
        if ((!isUser && showAssistantAvatar) || (isUser && showUserAvatar)) {
          avatarWidth = 48; // 40px avatar + 8px spacing
        }

        // 为消息内容保留固定宽度
        final messageWidth = availableWidth - avatarWidth;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser && showAssistantAvatar) ...[SizedBox(width: 40, child: ChatAvatar(isUser: false)), const SizedBox(width: 8)],
              // 使用Container代替Flexible，固定宽度
              SizedBox(
                width: messageWidth,
                child: Column(
                  crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    _buildMessageGroup(context, messages, isUser),
                    if (kIsDesktop && messages.last.role != MessageRole.loading && !isUser)
                      MessageActions(messages: messages, onRetry: onRetry, onSwitch: onSwitch),
                  ],
                ),
              ),
              if (isUser && showUserAvatar) ...[const SizedBox(width: 8), SizedBox(width: 40, child: ChatAvatar(isUser: true))],
            ],
          ),
        );
      },
    );
  }
}
