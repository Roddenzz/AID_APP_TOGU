import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String recipientId;
  final String content;
  final DateTime sentAt;
  final bool isRead;
  final String? attachmentUrl;
  final String? conversationId;
  final String? conversationName;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    required this.content,
    required this.sentAt,
    required this.isRead,
    this.attachmentUrl,
    this.conversationId,
    this.conversationName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'recipientId': recipientId,
      'content': content,
      'sentAt': sentAt.toIso8601String(),
      'isRead': isRead ? 1 : 0,
      'attachmentUrl': attachmentUrl,
      'conversationId': conversationId,
      'conversationName': conversationName,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    final sentAtValue = map['sentAt'];
    DateTime sentAtParsed;
    if (sentAtValue is Timestamp) {
      sentAtParsed = sentAtValue.toDate();
    } else if (sentAtValue is DateTime) {
      sentAtParsed = sentAtValue;
    } else if (sentAtValue is String) {
      sentAtParsed = DateTime.tryParse(sentAtValue) ?? DateTime.now();
    } else if (sentAtValue is int) {
      sentAtParsed = DateTime.fromMillisecondsSinceEpoch(sentAtValue);
    } else if (sentAtValue is Map && sentAtValue['_seconds'] != null) {
      sentAtParsed = DateTime.fromMillisecondsSinceEpoch((sentAtValue['_seconds'] as int) * 1000);
    } else {
      sentAtParsed = DateTime.now();
    }

    return Message(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      recipientId: map['recipientId'] ?? '',
      content: map['content'] ?? '',
      sentAt: sentAtParsed,
      isRead: (map['isRead'] is bool)
          ? (map['isRead'] as bool)
          : ((map['isRead'] ?? 0) == 1),
      attachmentUrl: map['attachmentUrl'],
      conversationId: map['conversationId'],
      conversationName: map['conversationName'],
    );
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? recipientId,
    String? content,
    DateTime? sentAt,
    bool? isRead,
    String? attachmentUrl,
    String? conversationId,
    String? conversationName,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      recipientId: recipientId ?? this.recipientId,
      content: content ?? this.content,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      conversationId: conversationId ?? this.conversationId,
      conversationName: conversationName ?? this.conversationName,
    );
  }
}
