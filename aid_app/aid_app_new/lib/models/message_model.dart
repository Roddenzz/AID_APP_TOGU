class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String recipientId;
  final String content;
  final DateTime sentAt;
  final bool isRead;
  final String? attachmentUrl;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    required this.content,
    required this.sentAt,
    required this.isRead,
    this.attachmentUrl,
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
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      recipientId: map['recipientId'] ?? '',
      content: map['content'] ?? '',
      sentAt: DateTime.parse(map['sentAt'] ?? DateTime.now().toIso8601String()),
      isRead: (map['isRead'] ?? 0) == 1,
      attachmentUrl: map['attachmentUrl'],
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
    );
  }
}
