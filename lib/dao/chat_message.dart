import './base_dao.dart';

class ChatMessage {
  final int? id;
  final int chatId;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatMessage({
    this.id,
    required this.chatId,
    required this.body,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'chatId': chatId,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ChatMessageDao extends BaseDao<ChatMessage> {
  ChatMessageDao() : super('chat_message');

  @override
  ChatMessage fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      chatId: json['chatId'] ?? 0,
      body: json['body'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson(ChatMessage entity) {
    return entity.toJson();
  }
}
