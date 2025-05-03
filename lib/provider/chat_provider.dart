import 'package:flutter/material.dart';
import 'package:chatmcp/dao/chat.dart';
import 'package:chatmcp/dao/chat_message.dart';
import 'package:logging/logging.dart';
import 'package:chatmcp/llm/model.dart' as llm_model;

class ChatProvider extends ChangeNotifier {
  static final ChatProvider _instance = ChatProvider._internal();
  factory ChatProvider() => _instance;
  ChatProvider._internal();

  Chat? _activeChat;
  List<Chat> _chats = [];
  bool isSelectMode = false;
  Set<int?> selectedChats = {};

  Chat? get activeChat => _activeChat;
  List<Chat> get chats => _chats;

  Future<void> loadChats() async {
    final chatDao = ChatDao();
    _chats = await chatDao.query(
      orderBy: 'updatedAt DESC',
    );
    notifyListeners();
  }

  Future<void> setActiveChat(Chat chat) async {
    _activeChat = chat;
    notifyListeners();
  }

  Future<void> updateChatTitle(String title) async {
    if (_activeChat == null) {
      return;
    }
    final chatDao = ChatDao();
    await chatDao.update(Chat(title: title), _activeChat!.id!.toString());
    await loadChats();
    if (_activeChat?.id == _activeChat!.id) {
      setActiveChat(_activeChat!);
    }
  }

  Future<void> createChat(
      Chat chat, List<llm_model.ChatMessage> messages) async {
    final chatDao = ChatDao();
    final id = await chatDao.insert(chat);
    await loadChats();
    final newChat = await chatDao.queryById(id.toString());
    await addChatMessage(newChat!.id!, messages);
    setActiveChat(newChat);
  }

  Future<void> updateChat(Chat chat) async {
    final chatDao = ChatDao();
    Logger.root.info('updateChat: ${chat.toJson()}');
    await chatDao.update(chat, chat.id!.toString());
    await loadChats();
    if (_activeChat?.id == chat.id) {
      setActiveChat(chat);
    }
  }

  Future<void> deleteChat(int chatId) async {
    final chatDao = ChatDao();
    await chatDao.delete(chatId.toString());
    await loadChats();
    if (_activeChat?.id == chatId) {
      _activeChat = null;
    }
    notifyListeners();
  }

  Future<void> clearActiveChat() async {
    _activeChat = null;
    notifyListeners();
  }

  Future<void> addChatMessage(
      int chatId, List<llm_model.ChatMessage> messages) async {
    final chatMessageDao = ChatMessageDao();
    for (var message in messages) {
      if (message.role == llm_model.MessageRole.error) {
        continue;
      }
      final chatMessages = await chatMessageDao
          .query(where: 'messageId = ?', whereArgs: [message.messageId]);
      if (chatMessages.isNotEmpty) {
        continue;
      }
      await chatMessageDao.insert(DbChatMessage(
        chatId: chatId,
        messageId: message.messageId,
        parentMessageId: message.parentMessageId,
        body: message.toString(),
      ));
    }
    notifyListeners();
  }

  void enterSelectMode() {
    isSelectMode = true;
    selectedChats.clear();
    notifyListeners();
  }

  void exitSelectMode() {
    isSelectMode = false;
    selectedChats.clear();
    notifyListeners();
  }

  void selectChat(int? chatId) {
    selectedChats.add(chatId);
    notifyListeners();
  }

  void unselectChat(int? chatId) {
    selectedChats.remove(chatId);
    notifyListeners();
  }

  void toggleSelectChat(int? chatId) {
    if (selectedChats.contains(chatId)) {
      selectedChats.remove(chatId);
    } else {
      selectedChats.add(chatId);
    }
    notifyListeners();
  }

  void toggleSelectAll() {
    if (selectedChats.length == chats.length) {
      selectedChats.clear();
    } else {
      selectedChats = chats.map((chat) => chat.id).toSet();
    }
    notifyListeners();
  }

  Future<void> deleteSelectedChats() async {
    final chatDao = ChatDao();

    // Delete selected chats from database
    for (var chatId in selectedChats) {
      if (chatId != null) {
        await chatDao.delete(chatId.toString());
      }
    }

    // Reload chat list
    await loadChats();

    // Update activeChat if current active chat was deleted
    if (selectedChats.contains(activeChat?.id)) {
      if (_chats.isNotEmpty) {
        await setActiveChat(_chats.first);
      } else {
        await clearActiveChat();
      }
    }

    // Exit select mode
    exitSelectMode();
  }
}
