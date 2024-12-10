import './base_dao.dart';
import './chat_message.dart';
import 'package:ChatMcp/llm/model.dart' as llmModel;
import 'dart:convert';

class Chat {
  final int? id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  Chat({
    this.id,
    required this.title,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // get chat_messages
  Future<List<llmModel.ChatMessage>> getChatMessages() async {
    final chatMessages =
        await ChatMessageDao().query(where: 'chatId = ?', whereArgs: [id!]);

    return chatMessages
        .map((e) => llmModel.ChatMessage.fromJson(jsonDecode(e.body)))
        .toList();
  }
}

class ChatDao extends BaseDao<Chat> {
  ChatDao() : super('chat');

  @override
  Chat fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson(Chat entity) {
    return entity.toJson();
  }
}
