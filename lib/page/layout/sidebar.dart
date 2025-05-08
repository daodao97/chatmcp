import 'package:chatmcp/widgets/ink_icon.dart';
import 'package:flutter/material.dart';
import '../setting/setting.dart';
import 'package:provider/provider.dart';
import 'package:chatmcp/provider/chat_provider.dart';
import 'package:chatmcp/utils/platform.dart';
import 'package:chatmcp/utils/color.dart';
import 'package:chatmcp/generated/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:chatmcp/components/widgets/base.dart';

class SidebarPanel extends StatelessWidget {
  final VoidCallback? onToggle;
  const SidebarPanel({super.key, this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) => SizedBox(
        height: double.infinity,
        child: Stack(
          children: [
            ChatHistoryList(chatProvider: chatProvider),
            if (kIsDesktop) ...[
              Positioned(
                top: 8,
                right: 8,
                child: InkIcon(
                  icon: CupertinoIcons.sidebar_left,
                  onTap: onToggle,
                ),
              ),
            ],
            SidebarToolbar(chatProvider: chatProvider),
          ],
        ),
      ),
    );
  }
}

class ChatHistoryList extends StatelessWidget {
  final ChatProvider chatProvider;

  const ChatHistoryList({
    super.key,
    required this.chatProvider,
  });

  Map<String, List<dynamic>> _groupChats(
      BuildContext context, List<dynamic> chats) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final previous7Days = today.subtract(const Duration(days: 7));
    final previous30Days = today.subtract(const Duration(days: 30));

    return {
      l10n.today: chats.where((chat) {
        final chatDate = DateTime(
            chat.updatedAt.year, chat.updatedAt.month, chat.updatedAt.day);
        return chatDate.isAtSameMomentAs(today);
      }).toList(),
      l10n.yesterday: chats.where((chat) {
        final chatDate = DateTime(
            chat.updatedAt.year, chat.updatedAt.month, chat.updatedAt.day);
        return chatDate.isAtSameMomentAs(yesterday);
      }).toList(),
      l10n.last7Days: chats.where((chat) {
        final chatDate = DateTime(
            chat.updatedAt.year, chat.updatedAt.month, chat.updatedAt.day);
        return chatDate.isBefore(yesterday) && chatDate.isAfter(previous7Days);
      }).toList(),
      l10n.last30Days: chats.where((chat) {
        final chatDate = DateTime(
            chat.updatedAt.year, chat.updatedAt.month, chat.updatedAt.day);
        return chatDate.isBefore(previous7Days) &&
            chatDate.isAfter(previous30Days);
      }).toList(),
      l10n.earlier: chats.where((chat) {
        final chatDate = DateTime(
            chat.updatedAt.year, chat.updatedAt.month, chat.updatedAt.day);
        return chatDate.isBefore(previous30Days);
      }).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final groupedChats = _groupChats(context, chatProvider.chats);

    return Container(
      padding: const EdgeInsets.only(top: 30, left: 12, right: 12, bottom: 40),
      child: ListView.builder(
        itemCount: groupedChats.entries.length,
        itemBuilder: (context, index) {
          final entry = groupedChats.entries.elementAt(index);
          if (entry.value.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: CText(
                  text: entry.key,
                  size: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              ...entry.value.map(
                (chat) => ChatHistoryItem(
                  chat: chat,
                  chatProvider: chatProvider,
                ),
              ),
              const Gap(size: 12),
            ],
          );
        },
      ),
    );
  }
}

class ChatHistoryItem extends StatelessWidget {
  final dynamic chat;
  final ChatProvider chatProvider;

  const ChatHistoryItem({
    super.key,
    required this.chat,
    required this.chatProvider,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = chat.id == chatProvider.activeChat?.id;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.getSidebarActiveConversationColor(context)
            : null,
        borderRadius: BorderRadius.circular(7),
      ),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity(vertical: -4),
        leading: chatProvider.isSelectMode
            ? Checkbox(
                value: chatProvider.selectedChats.contains(chat.id),
                onChanged: (bool? value) {
                  if (value == true) {
                    chatProvider.selectChat(chat.id);
                  } else {
                    chatProvider.unselectChat(chat.id);
                  }
                },
              )
            : null,
        title: Row(
          children: [
            Expanded(
              child: CText(
                text: chat.title.replaceAll('\n', ' '),
                size: 12,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        onTap: () {
          chatProvider.isSelectMode
              ? chatProvider.toggleSelectChat(chat.id)
              : chatProvider.setActiveChat(chat);

          if (kIsMobile) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

class SidebarToolbar extends StatelessWidget {
  final ChatProvider chatProvider;

  const SidebarToolbar({
    super.key,
    required this.chatProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 6,
      left: 0,
      right: 0,
      child: Container(
        // height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            _buildSettingsButton(context),
            const Gap(size: 4),
            _buildSelectModeButton(),
            if (chatProvider.isSelectMode) ...[
              const Gap(size: 4),
              _buildSelectAllButton(),
              const Gap(size: 4),
              _buildDeleteButton(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return InkIcon(
      icon: CupertinoIcons.settings,
      onTap: () => _showSettingsDialog(context),
    );
  }

  Widget _buildSelectModeButton() {
    return InkIcon(
      icon: chatProvider.isSelectMode
          ? CupertinoIcons.clear
          : CupertinoIcons.trash,
      onTap: () {
        if (chatProvider.isSelectMode) {
          chatProvider.exitSelectMode();
        } else {
          chatProvider.enterSelectMode();
        }
      },
    );
  }

  Widget _buildSelectAllButton() {
    return InkIcon(
      icon: CupertinoIcons.checkmark_square,
      onTap: () => chatProvider.toggleSelectAll(),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    return InkWell(
      onTap: chatProvider.selectedChats.isNotEmpty
          ? () => _showDeleteConfirmDialog(context)
          : null,
      child: CText(
        text: t.delete,
        size: 12,
        color: chatProvider.selectedChats.isNotEmpty ? Colors.red : null,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    if (kIsMobile) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SettingPage(),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              child: const SettingPage(),
            ),
          ),
        ),
      );
    }
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteSelected),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              chatProvider.deleteSelectedChats();
              Navigator.pop(context);
            },
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}
