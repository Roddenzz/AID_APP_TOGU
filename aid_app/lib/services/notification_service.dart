import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import '../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.instance.init();
  await NotificationService.instance.showRemoteNotification(message);
}

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _userNotificationSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _directMessageSub;

  bool _initialized = false;
  String? _listeningUserId;
  static const String _fcmLegacyServerKey = 'AIzaSyD3aNNVchEEumyNr1CGTXEIfXVZbyFmkpY';

  bool get _isSupportedPlatform => Platform.isAndroid || Platform.isIOS || Platform.isWindows;
  bool get _isFcmSupported => Platform.isAndroid || Platform.isIOS;

  Future<void> init() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _localNotifications.initialize(initSettings);

    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'aid_app_default',
        'Aid App Updates',
        description: 'Общие уведомления Aid App',
        importance: Importance.high,
        playSound: true,
      );

      final androidPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(channel);
    }

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen(showRemoteNotification);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    _initialized = true;
  }

  Future<void> listenForUser(String userId) async {
    if (userId.isEmpty) return;
    await init();

    if (_listeningUserId == userId && _userNotificationSub != null && _directMessageSub != null) {
      return;
    }

    await _userNotificationSub?.cancel();
    await _directMessageSub?.cancel();
    _listeningUserId = userId;
    _userNotificationSub = _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .snapshots()
        .listen(_handleNotificationSnapshot);

    // Дополнительный канал на случай отсутствия записей в notifications: прямые сообщения, где получатель текущий пользователь.
    _directMessageSub = _firestore
        .collection('messages')
        .where('recipientId', isEqualTo: userId)
        .snapshots()
        .listen(_handleDirectMessageSnapshot);
  }

  Future<void> stopListening() async {
    await _userNotificationSub?.cancel();
    await _directMessageSub?.cancel();
    _userNotificationSub = null;
    _directMessageSub = null;
    _listeningUserId = null;
  }

  Future<void> enqueueNotification({
    required String recipientId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? payload,
    String? senderId,
  }) async {
    await _firestore.collection('notifications').add({
      'recipientId': recipientId,
      'title': title,
      'body': body,
      'type': type,
      'payload': payload ?? <String, dynamic>{},
      'senderId': senderId,
      'createdAt': FieldValue.serverTimestamp(),
      'delivered': false,
    });
  }

  Future<void> showRemoteNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? 'Aid App';
    final body = message.notification?.body ?? 'Новое событие в системе';
    await showLocalNotification(title: title, body: body);
  }

  Future<String?> getFcmToken() => FirebaseMessaging.instance.getToken();
  bool get isFcmAvailable => _isFcmSupported;

  Future<void> sendPushToTokens({
    required List<String> tokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (tokens.isEmpty) return;
    if (_fcmLegacyServerKey.isEmpty) {
      // ignore: avoid_print
      print('FCM server key not configured; push skipped');
      return;
    }
    final payload = {
      'registration_ids': tokens,
      'notification': {
        'title': title,
        'body': body,
        'sound': 'default',
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'android_channel_id': 'aid_app_default',
      },
      'data': data ?? <String, dynamic>{},
      'priority': 'high',
      'content_available': true,
      'android': {
        'priority': 'high',
        'notification': {
          'channel_id': 'aid_app_default',
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'sound': 'default',
        },
      },
    };
    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$_fcmLegacyServerKey',
      },
      body: jsonEncode(payload),
    );
    if (response.statusCode >= 400) {
      // ignore: avoid_print
      print('FCM push error: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> showLocalNotification({required String title, required String body}) async {
    if (!_isSupportedPlatform) {
      return;
    }
    if (!_initialized) {
      await init();
    }
    if (!_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      'aid_app_default',
      'Aid App Updates',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _localNotifications.show(DateTime.now().millisecondsSinceEpoch ~/ 1000, title, body, details);
  }

  void showInAppBanner(BuildContext context, String title, String body) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(body, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    for (final change in snapshot.docChanges) {
      if (change.type != DocumentChangeType.added) continue;
      final data = change.doc.data();
      if (data == null || data.isEmpty) continue;

      final title = (data['title'] as String?)?.trim();
      final body = (data['body'] as String?)?.trim();
      if (title != null && body != null) {
        showLocalNotification(title: title, body: body);
      }

      change.doc.reference.update({
        'delivered': true,
        'deliveredAt': FieldValue.serverTimestamp(),
      });
    }
  }

  void _handleDirectMessageSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    for (final change in snapshot.docChanges) {
      if (change.type != DocumentChangeType.added) continue;
      final data = change.doc.data();
      if (data == null || data.isEmpty) continue;

      final senderName = (data['senderName'] as String?)?.trim() ?? 'Новое сообщение';
      final body = (data['content'] as String?)?.trim() ?? '';
      if (body.isNotEmpty) {
        showLocalNotification(title: senderName, body: body);
      }
    }
  }
}
