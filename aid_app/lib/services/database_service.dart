import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import 'local_database_service.dart';

class DatabaseService {
  DatabaseService._internal();

  static final DatabaseService _instance = DatabaseService._internal();
  static DatabaseService get instance => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalDatabaseService _localDb = LocalDatabaseService.instance;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> get _users => _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _applications => _firestore.collection('applications');
  CollectionReference<Map<String, dynamic>> get _news => _firestore.collection('news');
  CollectionReference<Map<String, dynamic>> get _messages => _firestore.collection('messages');
  CollectionReference<Map<String, dynamic>> get _staffUsers => _firestore.collection('staff_users');
  CollectionReference<Map<String, dynamic>> get _usersTokens => _firestore.collection('users');

  // User operations
  Future<void> createUser(Map<String, dynamic> userMap) async {
    final normalizedEmail = (userMap['email'] as String).trim().toLowerCase();
    final data = Map<String, dynamic>.from(userMap)
      ..['id'] = userMap['id'] ?? _uuid.v4()
      ..['email'] = normalizedEmail
      ..['emailLowercase'] = normalizedEmail
      ..['isStaff'] = _flagValue(userMap['isStaff'])
      ..['createdAt'] = _ensureIsoString(userMap['createdAt']) ?? DateTime.now().toIso8601String();

    await Future.wait([
      _users.doc(data['id'] as String).set(data),
      _localDb.saveUser(data),
    ]);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    final local = await _localDb.getUserByEmail(normalizedEmail);
    try {
      final snapshot = await _users.where('emailLowercase', isEqualTo: normalizedEmail).limit(1).get();
      if (snapshot.docs.isEmpty) return local;
      final remote = _normalizeUserDoc(snapshot.docs.first);
      await _localDb.saveUser(remote);
      return remote;
    } catch (_) {
      return local;
    }
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    final local = await _localDb.getUserById(id);
    try {
      final doc = await _users.doc(id).get();
      if (!doc.exists) return local;
      final remote = _normalizeUserDoc(doc);
      await _localDb.saveUser(remote);
      return remote;
    } catch (_) {
      return local;
    }
  }

  Future<void> upsertUserToken(String userId, String token) async {
    if (token.isEmpty) return;
    await _users.doc(userId).set({'fcmTokens': FieldValue.arrayUnion([token])}, SetOptions(merge: true));
    final localUser = await _localDb.getUserById(userId);
    if (localUser != null) {
      final tokens = (localUser['fcmTokens'] as List?)?.whereType<String>().toSet() ?? <String>{};
      tokens.add(token);
      localUser['fcmTokens'] = tokens.toList();
      await _localDb.saveUser(localUser);
    }
  }

  Future<List<String>> getUserTokens(String userId) async {
    final local = await _localDb.getUserById(userId);
    final localTokens = (local?['fcmTokens'] as Iterable?)?.whereType<String>().toSet().toList();
    try {
      final doc = await _users.doc(userId).get();
      if (!doc.exists) return localTokens ?? [];
      final data = doc.data();
      if (data == null) return localTokens ?? [];
      final tokens = data['fcmTokens'];
      if (tokens is Iterable) {
        final cleaned = tokens.whereType<String>().toSet().toList();
        if (local != null) {
          local['fcmTokens'] = cleaned;
          await _localDb.saveUser(local);
        }
        return cleaned;
      }
    } catch (_) {
      return localTokens ?? [];
    }
    return localTokens ?? [];
  }

  Future<Map<String, List<String>>> getTokensForUsers(List<String> userIds) async {
    if (userIds.isEmpty) return {};
    try {
      final snapshots = await _users.where(FieldPath.documentId, whereIn: userIds).get();
      final Map<String, List<String>> result = {};
      for (final doc in snapshots.docs) {
        final tokens = doc.data()['fcmTokens'];
        if (tokens is Iterable) {
          final cleaned = tokens.whereType<String>().toSet().toList();
          result[doc.id] = cleaned;
          final localUser = await _localDb.getUserById(doc.id) ?? {'id': doc.id};
          localUser['fcmTokens'] = cleaned;
          await _localDb.saveUser(localUser);
        }
      }
      return result;
    } catch (_) {
      final Map<String, List<String>> result = {};
      for (final id in userIds) {
        final localTokens = (await _localDb.getUserById(id))?['fcmTokens'];
        if (localTokens is Iterable) {
          result[id] = localTokens.whereType<String>().toSet().toList();
        }
      }
      return result;
    }
  }

  Future<List<Map<String, dynamic>>> getStaffUsers() async {
    try {
      final snapshot = await _users.where('isStaff', isEqualTo: 1).get();
      final docs = snapshot.docs.map(_normalizeUserDoc).toList();
      for (final staff in docs) {
        await _localDb.saveUser(staff);
      }
      return docs;
    } catch (_) {
      return _localDb.getStaffUsers();
    }
  }

  Future<Map<String, dynamic>?> getStaffRecordByEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    final local = await _localDb.getStaffByEmail(normalizedEmail);
    try {
      final snapshot = await _staffUsers.where('emailLowercase', isEqualTo: normalizedEmail).limit(1).get();
      if (snapshot.docs.isEmpty) return local;
      final remote = _normalizeStaffDoc(snapshot.docs.first);
      await _localDb.saveStaffUser(remote);
      return remote;
    } catch (_) {
      return local;
    }
  }

  // Application operations
  Future<void> createApplication(Map<String, dynamic> appMap) async {
    final data = Map<String, dynamic>.from(appMap)
      ..['id'] = appMap['id'] ?? _uuid.v4()
      ..['createdAt'] = _ensureIsoString(appMap['createdAt']) ?? DateTime.now().toIso8601String()
      ..['attachments'] = _ensureAttachmentList(appMap['attachments']);

    await Future.wait([
      _applications.doc(data['id'] as String).set(data),
      _localDb.saveApplication(data),
    ]);
  }

  Future<List<Map<String, dynamic>>> getAllApplications() async {
    try {
      final snapshot = await _applications.orderBy('createdAt', descending: true).get();
      final apps = snapshot.docs.map(_normalizeApplicationDoc).toList();
      for (final app in apps) {
        await _localDb.saveApplication(app);
      }
      return apps;
    } catch (_) {
      final local = await _localDb.getApplications();
      local.sort((a, b) => (b['createdAt'] as String? ?? '').compareTo(a['createdAt'] as String? ?? ''));
      return local;
    }
  }

  Future<List<Map<String, dynamic>>> getApplicationsByUserId(String userId) async {
    try {
      final snapshot = await _applications.where('userId', isEqualTo: userId).orderBy('createdAt', descending: true).get();
      final apps = snapshot.docs.map(_normalizeApplicationDoc).toList();
      for (final app in apps) {
        await _localDb.saveApplication(app);
      }
      return apps;
    } catch (_) {
      final local = await _localDb.getApplications();
      return local.where((a) => a['userId'] == userId).toList()
        ..sort((a, b) => (b['createdAt'] as String? ?? '').compareTo(a['createdAt'] as String? ?? ''));
    }
  }

  Future<List<Map<String, dynamic>>> getApplicationsByStatus(String status) async {
    try {
      final snapshot = await _applications.where('status', isEqualTo: status).orderBy('createdAt', descending: true).get();
      final apps = snapshot.docs.map(_normalizeApplicationDoc).toList();
      for (final app in apps) {
        await _localDb.saveApplication(app);
      }
      return apps;
    } catch (_) {
      final local = await _localDb.getApplications();
      return local.where((a) => a['status'] == status).toList()
        ..sort((a, b) => (b['createdAt'] as String? ?? '').compareTo(a['createdAt'] as String? ?? ''));
    }
  }

  Future<void> updateApplication(String id, Map<String, dynamic> updates) async {
    final data = Map<String, dynamic>.from(updates);
    if (data.containsKey('attachments')) {
      data['attachments'] = _ensureAttachmentList(data['attachments']);
    }
    if (data.containsKey('reviewedAt')) {
      data['reviewedAt'] = _ensureIsoString(data['reviewedAt']);
    }
    await _applications.doc(id).update(data);
    final local = await _localDb.getApplications();
    for (final app in local) {
      if (app['id'] == id) {
        app.addAll(data);
        await _localDb.saveApplication(app);
        break;
      }
    }
  }

  Future<Map<String, dynamic>?> getApplicationById(String id) async {
    final local = (await _localDb.getApplications()).firstWhere(
      (a) => a['id'] == id,
      orElse: () => {},
    );
    try {
      final doc = await _applications.doc(id).get();
      if (!doc.exists) return local.isEmpty ? null : local;
      final remote = _normalizeApplicationDoc(doc);
      await _localDb.saveApplication(remote);
      return remote;
    } catch (_) {
      return local.isEmpty ? null : local;
    }
  }

  // News operations
  Future<void> createNews(Map<String, dynamic> newsMap) async {
    final data = Map<String, dynamic>.from(newsMap)
      ..['id'] = newsMap['id'] ?? _uuid.v4()
      ..['createdAt'] = _ensureIsoString(newsMap['createdAt']) ?? DateTime.now().toIso8601String()
      ..['updatedAt'] = _ensureIsoString(newsMap['updatedAt'])
      ..['likedBy'] = _ensureCommaSeparated(newsMap['likedBy']);

    await Future.wait([
      _news.doc(data['id'] as String).set(data),
      _localDb.saveNews(data),
    ]);
  }

  Future<List<Map<String, dynamic>>> getAllNews() async {
    try {
      final snapshot = await _news.orderBy('createdAt', descending: true).get();
      final items = snapshot.docs.map(_normalizeNewsDoc).toList();
      for (final n in items) {
        await _localDb.saveNews(n);
      }
      return items;
    } catch (_) {
      final local = await _localDb.getNews();
      local.sort((a, b) => (b['createdAt'] as String? ?? '').compareTo(a['createdAt'] as String? ?? ''));
      return local;
    }
  }

  Future<Map<String, dynamic>?> getNewsById(String id) async {
    final local = (await _localDb.getNews()).firstWhere((n) => n['id'] == id, orElse: () => {});
    try {
      final doc = await _news.doc(id).get();
      if (!doc.exists) return local.isEmpty ? null : local;
      final remote = _normalizeNewsDoc(doc);
      await _localDb.saveNews(remote);
      return remote;
    } catch (_) {
      return local.isEmpty ? null : local;
    }
  }

  Future<void> updateNews(String id, Map<String, dynamic> updates) async {
    final data = Map<String, dynamic>.from(updates);
    if (data.containsKey('updatedAt')) {
      data['updatedAt'] = _ensureIsoString(data['updatedAt']);
    }
    if (data.containsKey('likedBy')) {
      data['likedBy'] = _ensureCommaSeparated(data['likedBy']);
    }
    await _news.doc(id).update(data);
    final local = (await _localDb.getNews()).firstWhere((n) => n['id'] == id, orElse: () => {});
    if (local.isNotEmpty) {
      local.addAll(data);
      await _localDb.saveNews(local);
    }
  }

  // Message operations
  Future<void> createMessage(Map<String, dynamic> messageMap) async {
    final data = Map<String, dynamic>.from(messageMap)
      ..['id'] = messageMap['id'] ?? _uuid.v4()
      ..['sentAt'] = _toTimestamp(messageMap['sentAt'])
      ..['isRead'] = _flagValue(messageMap['isRead']) == 1;

    await Future.wait([
      _messages.doc(data['id'] as String).set(data),
      _localDb.saveMessage(data),
    ]);
  }

  Future<List<Map<String, dynamic>>> getConversation(String userId1, String userId2) async {
    try {
      final results = await Future.wait([
        _messages
            .where('senderId', isEqualTo: userId1)
            .where('recipientId', isEqualTo: userId2)
            .orderBy('sentAt')
            .get(),
        _messages
            .where('senderId', isEqualTo: userId2)
            .where('recipientId', isEqualTo: userId1)
            .orderBy('sentAt')
            .get(),
      ]);

      final docs = [...results[0].docs, ...results[1].docs];
      docs.sort((a, b) => _timestampToDate(a['sentAt']).compareTo(_timestampToDate(b['sentAt'])));
      final messages = docs.map(_normalizeMessageDoc).toList();
      for (final msg in messages) {
        await _localDb.saveMessage(msg);
      }
      return messages;
    } catch (_) {
      final cached = await _localDb.getMessagesByConversation(
        userId1,
        userId1: userId1,
        userId2: userId2,
      );
      return cached;
    }
  }

  // Staff verification
  Future<bool> isStaffUser(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    try {
      final snapshot = await _staffUsers.where('emailLowercase', isEqualTo: normalizedEmail).limit(1).get();
      final exists = snapshot.docs.isNotEmpty;
      if (exists) {
        await _localDb.saveStaffUser(_normalizeStaffDoc(snapshot.docs.first));
      }
      return exists;
    } catch (_) {
      return (await _localDb.getStaffByEmail(normalizedEmail)) != null;
    }
  }

  Future<void> upsertStaffUser(String id, String email, String studentId) async {
    final normalizedEmail = email.trim().toLowerCase();
    final data = {
      'id': id,
      'email': normalizedEmail,
      'emailLowercase': normalizedEmail,
      'studentId': studentId,
    };
    await Future.wait([
      _staffUsers.doc(id).set(data),
      _localDb.saveStaffUser(data),
    ]);
  }

  Future<Map<String, dynamic>?> getFirstStaffUser() async {
    try {
      final snapshot = await _users.where('isStaff', isEqualTo: 1).orderBy('createdAt', descending: true).limit(1).get();
      if (snapshot.docs.isEmpty) return null;
      final staff = _normalizeUserDoc(snapshot.docs.first);
      await _localDb.saveUser(staff);
      return staff;
    } catch (_) {
      final staff = await _localDb.getStaffUsers();
      staff.sort((a, b) => (b['createdAt'] as String? ?? '').compareTo(a['createdAt'] as String? ?? ''));
      return staff.isEmpty ? null : staff.first;
    }
  }

  Future<List<Map<String, dynamic>>> getConversationSummaries(String userId) async {
    try {
      final results = await Future.wait([
        _messages.where('senderId', isEqualTo: userId).orderBy('sentAt', descending: true).get(),
        _messages.where('recipientId', isEqualTo: userId).orderBy('sentAt', descending: true).get(),
      ]);

      final docs = [...results[0].docs, ...results[1].docs];
      docs.sort((a, b) => _timestampToDate(b['sentAt']).compareTo(_timestampToDate(a['sentAt'])));

      final Map<String, Map<String, dynamic>> summaries = {};
      for (final doc in docs) {
        final data = _normalizeMessageDoc(doc);
        final senderId = data['senderId'] as String;
        final recipientId = data['recipientId'] as String;
        final partnerId = senderId == userId ? recipientId : senderId;
        if (summaries.containsKey(partnerId)) continue;

        final user = await getUserById(partnerId);
        summaries[partnerId] = {
          'partnerId': partnerId,
          'partnerName': user?['fullName'] ?? user?['email'] ?? 'Unknown',
          'lastMessage': data['content'] ?? '',
          'lastSentAt': data['sentAt'] ?? '',
        };
      }

      return summaries.values.toList();
    } catch (_) {
      final cached = await _localDb.getAllMessages();
      final Map<String, Map<String, dynamic>> summaries = {};
      for (final msg in cached) {
        final senderId = msg['senderId'] as String? ?? '';
        final recipientId = msg['recipientId'] as String? ?? '';
        final partnerId = senderId == userId ? recipientId : senderId;
        if (partnerId.isEmpty || summaries.containsKey(partnerId)) continue;
        summaries[partnerId] = {
          'partnerId': partnerId,
          'partnerName': '',
          'lastMessage': msg['content'] ?? '',
          'lastSentAt': msg['sentAt'] ?? '',
        };
      }
      return summaries.values.toList();
    }
  }

  Map<String, dynamic> _normalizeUserDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data() ?? {});
    data['id'] ??= doc.id;
    data['email'] = (data['email'] as String?)?.toLowerCase() ?? '';
    data['isStaff'] = _flagValue(data['isStaff']);
    data['createdAt'] = _ensureIsoString(data['createdAt']) ?? DateTime.now().toIso8601String();
    if (data['fcmTokens'] is Iterable) {
      data['fcmTokens'] = (data['fcmTokens'] as Iterable).whereType<String>().toSet().toList();
    } else {
      data['fcmTokens'] = <String>[];
    }
    if (data['passwordHash'] != null && data['passwordHash'] is! String) {
      data['passwordHash'] = data['passwordHash'].toString();
    }
    if (data['passwordSalt'] != null && data['passwordSalt'] is! String) {
      data['passwordSalt'] = data['passwordSalt'].toString();
    }
    return data;
  }

  Map<String, dynamic> _normalizeApplicationDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data() ?? {});
    data['id'] ??= doc.id;
    data['createdAt'] = _ensureIsoString(data['createdAt']) ?? DateTime.now().toIso8601String();
    data['reviewedAt'] = _ensureIsoString(data['reviewedAt']);
    data['attachments'] = _ensureAttachmentList(data['attachments']);
    return data;
  }

  Map<String, dynamic> _normalizeNewsDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data() ?? {});
    data['id'] ??= doc.id;
    data['createdAt'] = _ensureIsoString(data['createdAt']) ?? DateTime.now().toIso8601String();
    data['updatedAt'] = _ensureIsoString(data['updatedAt']);
    data['likedBy'] = _ensureCommaSeparated(data['likedBy']);
    data['likes'] = (data['likes'] as num?)?.toInt() ?? 0;
    return data;
  }

  Map<String, dynamic> _normalizeStaffDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data() ?? {});
    data['id'] ??= doc.id;
    data['email'] = (data['email'] as String?)?.toLowerCase();
    return data;
  }

  Map<String, dynamic> _normalizeMessageDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data() ?? {});
    data['id'] ??= doc.id;
    data['sentAt'] = _ensureIsoString(data['sentAt']) ?? DateTime.now().toIso8601String();
    data['isRead'] = _flagValue(data['isRead']);
    return data;
  }

  int _flagValue(dynamic value) {
    if (value is bool) return value ? 1 : 0;
    if (value is num) return value.toInt() != 0 ? 1 : 0;
    if (value is String) return value == '1' ? 1 : 0;
    return 0;
  }

  String _ensureCommaSeparated(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Iterable) return value.map((e) => e.toString()).join(',');
    return value.toString();
  }

  List<Map<String, dynamic>> _ensureAttachmentList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  String? _ensureIsoString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is DateTime) return value.toIso8601String();
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt()).toIso8601String();
    }
    return value.toString();
  }

  Timestamp _toTimestamp(dynamic value) {
    if (value is Timestamp) return value;
    if (value is DateTime) return Timestamp.fromDate(value);
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return Timestamp.fromDate(parsed);
    }
    if (value is num) {
      return Timestamp.fromMillisecondsSinceEpoch(value.toInt());
    }
    return Timestamp.fromDate(DateTime.now());
  }

  DateTime _timestampToDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return DateTime.now();
  }
}
