import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/message_model.dart';
import 'database_service.dart';
import 'notification_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseService _db = DatabaseService.instance;
  final _uuid = const Uuid();
  final Map<String, List<Message>> _conversationCache = {};

  /// conversationId is always the student's userId
  Stream<List<Message>> conversationStream(String conversationId) {
    final baseStream = _firestore
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .snapshots()
        .map((snapshot) {
      try {
        final messages = snapshot.docs
            .map((doc) => Message.fromMap({...doc.data(), 'id': doc.id}))
            .toList();
        messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
        _conversationCache[conversationId] = messages;
        return messages;
      } catch (e) {
        // ignore: avoid_print
        print('Conversation stream error: $e');
        return _conversationCache[conversationId] ?? <Message>[];
      }
    });

    return baseStream.transform(
      StreamTransformer.fromHandlers(
        handleError: (error, stack, sink) {
          // ignore: avoid_print
          print('Conversation stream firebase error: $error');
          sink.add(_conversationCache[conversationId] ?? <Message>[]);
        },
      ),
    );
  }

  Future<void> sendMessage({
    required Message message,
    required String conversationId,
    required String conversationName,
    required bool isSenderStaff,
  }) async {
    final data = {
      ...message.toMap(),
      'conversationId': conversationId,
      'conversationName': conversationName,
      'sentAt': Timestamp.fromDate(message.sentAt),
      'isRead': message.isRead,
    };

    await _firestore.collection('messages').doc(message.id.isEmpty ? _uuid.v4() : message.id).set(data);

    await _dispatchTargetedNotifications(message: message, isSenderStaff: isSenderStaff);
  }

  /// Conversation summaries for staff: one per student, ordered by last message date.
  Stream<List<Map<String, dynamic>>> staffConversationSummaries() {
    return _firestore.collection('messages').orderBy('sentAt', descending: true).snapshots().map((snapshot) {
      final Map<String, Map<String, dynamic>> summaries = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final convId = data['conversationId'] as String? ?? '';
        if (convId.isEmpty) continue;

        final parsedDate = _safeDate(data['sentAt']);
        final existing = summaries[convId];
        if (existing == null || parsedDate.isAfter(_safeDate(existing['lastSentAt']))) {
          summaries[convId] = {
            'partnerId': convId,
            'partnerName': data['conversationName'] ?? 'Студент',
            'lastMessage': data['content'] ?? '',
            'lastSentAt': parsedDate,
          };
        }
      }
      final list = summaries.values.toList();
      list.sort((a, b) {
        final aDate = _safeDate(a['lastSentAt']);
        final bDate = _safeDate(b['lastSentAt']);
        return bDate.compareTo(aDate);
      });
      return list;
    });
  }

  Future<void> _dispatchTargetedNotifications({
    required Message message,
    required bool isSenderStaff,
  }) async {
    final payload = {
      'conversationId': message.conversationId,
      'senderId': message.senderId,
      'recipientId': message.recipientId,
    };

    if (isSenderStaff) {
      final tokensMap = await _db.getTokensForUsers([message.recipientId]);
      final tokens = tokensMap[message.recipientId] ?? const <String>[];
      await NotificationService.instance.enqueueNotification(
        recipientId: message.recipientId,
        title: 'Новое сообщение',
        body: message.content,
        type: 'chat',
        payload: payload,
        senderId: message.senderId,
      );
      await NotificationService.instance.sendPushToTokens(
        tokens: tokens,
        title: message.senderName.isEmpty ? 'Новое сообщение' : message.senderName,
        body: message.content,
        data: payload,
      );
      return;
    }

    final staffUsers = await _db.getStaffUsers();
    final staffIds = staffUsers.map((s) => (s['id'] as String?) ?? '').where((id) => id.isNotEmpty).toList();
    final tokensMap = await _db.getTokensForUsers(staffIds);
    for (final staff in staffUsers) {
      final staffId = (staff['id'] as String?) ?? '';
      if (staffId.isEmpty) continue;
      await NotificationService.instance.enqueueNotification(
        recipientId: staffId,
        title: 'Новое сообщение от студента',
        body: message.content,
        type: 'chat',
        payload: payload,
        senderId: message.senderId,
      );
      final tokens = tokensMap[staffId] ?? const <String>[];
      await NotificationService.instance.sendPushToTokens(
        tokens: tokens,
        title: message.senderName.isEmpty ? 'Новое сообщение от студента' : message.senderName,
        body: message.content,
        data: payload,
      );
    }
  }

  DateTime _safeDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
