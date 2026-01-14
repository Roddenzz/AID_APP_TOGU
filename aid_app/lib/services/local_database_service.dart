import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Local encrypted storage working in parallel with Firestore.
class LocalDatabaseService {
  LocalDatabaseService._internal();

  static final LocalDatabaseService instance = LocalDatabaseService._internal();

  static const _usersBox = 'users_box';
  static const _applicationsBox = 'applications_box';
  static const _newsBox = 'news_box';
  static const _messagesBox = 'messages_box';
  static const _staffBox = 'staff_box';
  static const _keyName = 'aid_app_hive_key';

  bool _initialized = false;
  Box<Map>? _users;
  Box<Map>? _applications;
  Box<Map>? _news;
  Box<Map>? _messages;
  Box<Map>? _staff;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    final cipher = HiveAesCipher(await _loadOrCreateKey());
    _users = await Hive.openBox<Map>(_usersBox, encryptionCipher: cipher);
    _applications = await Hive.openBox<Map>(_applicationsBox, encryptionCipher: cipher);
    _news = await Hive.openBox<Map>(_newsBox, encryptionCipher: cipher);
    _messages = await Hive.openBox<Map>(_messagesBox, encryptionCipher: cipher);
    _staff = await Hive.openBox<Map>(_staffBox, encryptionCipher: cipher);
    _initialized = true;
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _users?.put(user['id'], user);
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    final data = _users?.get(id);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    if (_users == null) return null;
    final normalized = email.trim().toLowerCase();
    for (final entry in _users!.values) {
      final data = Map<String, dynamic>.from(entry);
      if ((data['emailLowercase'] ?? data['email']) == normalized) {
        return data;
      }
    }
    return null;
  }

  Future<void> saveStaffUser(Map<String, dynamic> user) async {
    await _staff?.put(user['id'], user);
  }

  Future<Map<String, dynamic>?> getStaffByEmail(String email) async {
    if (_staff == null) return null;
    final normalized = email.trim().toLowerCase();
    for (final entry in _staff!.values) {
      final data = Map<String, dynamic>.from(entry);
      if ((data['emailLowercase'] ?? data['email']) == normalized) {
        return data;
      }
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getStaffUsers() async {
    return _staff?.values.map((e) => Map<String, dynamic>.from(e)).toList() ?? <Map<String, dynamic>>[];
  }

  Future<void> saveApplication(Map<String, dynamic> application) async {
    await _applications?.put(application['id'], application);
  }

  Future<List<Map<String, dynamic>>> getApplications() async {
    return _applications?.values.map((e) => Map<String, dynamic>.from(e)).toList() ?? <Map<String, dynamic>>[];
  }

  Future<void> saveNews(Map<String, dynamic> news) async {
    await _news?.put(news['id'], news);
  }

  Future<List<Map<String, dynamic>>> getNews() async {
    return _news?.values.map((e) => Map<String, dynamic>.from(e)).toList() ?? <Map<String, dynamic>>[];
  }

  Future<void> saveMessage(Map<String, dynamic> message) async {
    await _messages?.put(message['id'], message);
  }

  Future<List<Map<String, dynamic>>> getAllMessages() async {
    return _messages?.values.map((e) => Map<String, dynamic>.from(e)).toList() ?? <Map<String, dynamic>>[];
  }

  Future<List<Map<String, dynamic>>> getMessagesByConversation(
    String conversationId, {
    String? userId1,
    String? userId2,
  }) async {
    if (_messages == null) return <Map<String, dynamic>>[];
    final result = <Map<String, dynamic>>[];
    for (final entry in _messages!.values) {
      final data = Map<String, dynamic>.from(entry);
      final matchesConversation = data['conversationId'] == conversationId;
      final matchesUsers = userId1 != null &&
          userId2 != null &&
          ((data['senderId'] == userId1 && data['recipientId'] == userId2) ||
              (data['senderId'] == userId2 && data['recipientId'] == userId1));
      if (matchesConversation || matchesUsers) {
        result.add(data);
      }
    }
    result.sort((a, b) => _safeDate(a['sentAt']).compareTo(_safeDate(b['sentAt'])));
    return result;
  }

  Future<void> clearAll() async {
    await Future.wait([
      _users?.clear() ?? Future.value(),
      _applications?.clear() ?? Future.value(),
      _news?.clear() ?? Future.value(),
      _messages?.clear() ?? Future.value(),
      _staff?.clear() ?? Future.value(),
    ]);
  }

  Future<String> _resolveDbPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<List<int>> _loadOrCreateKey() async {
    const storage = FlutterSecureStorage();
    final existing = await storage.read(key: _keyName);
    if (existing != null && existing.isNotEmpty) {
      return base64Url.decode(existing);
    }
    final key = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    await storage.write(key: _keyName, value: base64UrlEncode(key));
    return key;
  }

  DateTime _safeDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
