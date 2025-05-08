import 'package:chatmcp/components/widgets/base.dart';
import 'package:chatmcp/widgets/ink_icon.dart';
import 'package:flutter/material.dart';
import 'package:chatmcp/provider/provider_manager.dart';
import './model_selector.dart';
import 'package:window_manager/window_manager.dart' as wm;
import 'package:chatmcp/utils/platform.dart';
import 'package:chatmcp/utils/color.dart';
import 'package:provider/provider.dart';
import 'package:chatmcp/provider/chat_provider.dart';
import 'package:chatmcp/generated/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:chatmcp/page/layout/widgets/mcp_tools.dart';
import 'package:chatmcp/provider/mcp_server_provider.dart';
// test page
import 'package:chatmcp/widgets/markdown/markit_widget.dart';
import 'package:chatmcp/widgets/browser/browser.dart';
import 'package:chatmcp/utils/event_bus.dart';
import 'package:chatmcp/page/layout/widgets/chat_setting.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:chatmcp/widgets/upgradge.dart';

class TopToolbar extends StatelessWidget {
  final bool hideSidebar;
  final VoidCallback onToggleSidebar;

  const TopToolbar({
    super.key,
    required this.hideSidebar,
    required this.onToggleSidebar,
  });

  void _onShowChatSetting(BuildContext context) {
    if (kIsMobile) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            body: SafeArea(
              child: const ChatSetting(),
            ),
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: const ChatSetting(),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildMoreMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return CustomPopup(
      showArrow: true,
      arrowColor: AppColors.getLayoutBackgroundColor(context),
      backgroundColor: AppColors.getLayoutBackgroundColor(context),
      content: Container(
        constraints: const BoxConstraints(
          maxWidth: 200,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UpgradeNotice(
              showCheckUpdate: true,
              autoCheck: false,
            ),
            if (ProviderManager.chatProvider.activeChat != null)
              InkWell(
                onTap: () {
                  emit(ShareEvent(false));
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.share, size: 18),
                      const SizedBox(width: 12),
                      Text(
                        l10n.share,
                        style: TextStyle(
                          color: AppColors.getThemeTextColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            InkWell(
              onTap: () {
                _onShowChatSetting(context);
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.slider_horizontal_3, size: 18),
                    const SizedBox(width: 12),
                    Text(
                      l10n.modelConfig,
                      style: TextStyle(
                        color: AppColors.getThemeTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (kIsDebug)
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(
                          title: Text(l10n.webSearchTest),
                        ),
                        body: const MarkitTestPage(),
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.ant, size: 18),
                      const SizedBox(width: 12),
                      Text(
                        l10n.debug,
                        style: TextStyle(
                          color: AppColors.getThemeTextColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: const Icon(CupertinoIcons.ellipsis_vertical, size: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, child) {
        return Consumer<McpServerProvider>(
          builder: (context, mcpProvider, child) {
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onDoubleTap: () async {
                  debugPrint('double tap');
                  if (kIsDesktop) {
                    try {
                      bool isMaximized = await wm.windowManager.isMaximized();
                      if (isMaximized) {
                        await wm.windowManager.unmaximize();
                      } else {
                        await wm.windowManager.maximize();
                      }
                    } catch (e) {
                      debugPrint('窗口操作失败: $e');
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.getToolbarBottomBorderColor(context),
                      ),
                    ),
                  ),
                  padding: kIsDesktop
                      ? EdgeInsets.only(left: hideSidebar ? 70 : 0, top: 2)
                      : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hideSidebar && kIsDesktop)
                              InkIcon(
                                icon: CupertinoIcons.sidebar_right,
                                onTap: onToggleSidebar,
                              ),
                            Flexible(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(minWidth: 50),
                                child: Row(
                                  children: [
                                    if (kIsAndroid) ...[
                                      Gap(size: 12),
                                      InkIcon(
                                        icon: CupertinoIcons.sidebar_left,
                                        onTap: () {
                                          Scaffold.of(context).openDrawer();
                                        },
                                      ),
                                    ],
                                    const ModelSelector(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width < 400
                                  ? 30
                                  : 120,
                            ),
                            child: UpgradeNotice(),
                          ),
                          if (ProviderManager.chatProvider.activeChat !=
                              null) ...[
                            Gap(size: 8),
                            InkIcon(
                              icon: CupertinoIcons.add,
                              onTap: () {
                                ProviderManager.chatProvider.clearActiveChat();
                              },
                            ),
                          ],
                          _buildMoreMenu(context),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
