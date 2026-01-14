import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  static DatabaseService get instance => _instance;

  Future<Database> get database async {
    _database ??= await initDb();
    return _database!;
  }

  Future<Database> initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'aid_app.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            email TEXT UNIQUE NOT NULL,
            studentId TEXT UNIQUE NOT NULL,
            fullName TEXT NOT NULL,
            phone TEXT NOT NULL,
            isStaff INTEGER NOT NULL,
            createdAt TEXT NOT NULL,
            avatar TEXT,
            academicGroup TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE applications (
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            fullName TEXT NOT NULL,
            academicGroup TEXT NOT NULL,
            phone TEXT NOT NULL,
            category TEXT NOT NULL,
            description TEXT NOT NULL,
            status TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            reviewedAt TEXT,
            reviewedBy TEXT,
            rejectionReason TEXT,
            approvedAmount REAL,
            attachments TEXT,
            notes TEXT,
            FOREIGN KEY(userId) REFERENCES users(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE news (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            imageUrl TEXT,
            createdBy TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            updatedAt TEXT,
            likes INTEGER DEFAULT 0,
            likedBy TEXT,
            FOREIGN KEY(createdBy) REFERENCES users(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE messages (
            id TEXT PRIMARY KEY,
            senderId TEXT NOT NULL,
            senderName TEXT NOT NULL,
            recipientId TEXT NOT NULL,
            content TEXT NOT NULL,
            sentAt TEXT NOT NULL,
            isRead INTEGER NOT NULL,
            attachmentUrl TEXT,
            FOREIGN KEY(senderId) REFERENCES users(id),
            FOREIGN KEY(recipientId) REFERENCES users(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE staff_users (
            id TEXT PRIMARY KEY,
            email TEXT UNIQUE NOT NULL,
            studentId TEXT UNIQUE NOT NULL
          )
        ''');

        // Insert default staff users
        await _insertDefaultStaffUsers(db);
      },
    );
  }

  Future<void> _insertDefaultStaffUsers(Database db) async {
    List<Map<String, String>> staffUsers = [
      {'id': '1', 'email': '2023106527@togudv.ru', 'studentId': '2023106527'},
      // Add more staff emails here
    ];

    for (var staff in staffUsers) {
      await db.insert('staff_users', staff);
    }
  }

  // User operations
  Future<void> createUser(Map<String, dynamic> userMap) async {
    final db = await database;
    await db.insert('users', userMap);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Application operations
  Future<void> createApplication(Map<String, dynamic> appMap) async {
    final db = await database;
    await db.insert('applications', appMap);
  }

  Future<List<Map<String, dynamic>>> getAllApplications() async {
    final db = await database;
    return await db.query('applications', orderBy: 'createdAt DESC');
  }

  Future<List<Map<String, dynamic>>> getApplicationsByUserId(String userId) async {
    final db = await database;
    return await db.query(
      'applications',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getApplicationsByStatus(String status) async {
    final db = await database;
    return await db.query(
      'applications',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'createdAt DESC',
    );
  }

  Future<void> updateApplication(String id, Map<String, dynamic> updates) async {
    final db = await database;
    await db.update(
      'applications',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // News operations
  Future<void> createNews(Map<String, dynamic> newsMap) async {
    final db = await database;
    await db.insert('news', newsMap);
  }

  Future<List<Map<String, dynamic>>> getAllNews() async {
    final db = await database;
    return await db.query('news', orderBy: 'createdAt DESC');
  }

  Future<void> updateNews(String id, Map<String, dynamic> updates) async {
    final db = await database;
    await db.update(
      'news',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Message operations
  Future<void> createMessage(Map<String, dynamic> messageMap) async {
    final db = await database;
    await db.insert('messages', messageMap);
  }

  Future<List<Map<String, dynamic>>> getConversation(String userId1, String userId2) async {
    final db = await database;
    return await db.query(
      'messages',
      where: '(senderId = ? AND recipientId = ?) OR (senderId = ? AND recipientId = ?)',
      whereArgs: [userId1, userId2, userId2, userId1],
      orderBy: 'sentAt DESC',
    );
  }

  // Staff verification
  Future<bool> isStaffUser(String email, String studentId) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'staff_users',
      where: 'studentId = ?',
      whereArgs: [studentId],
    );
    return results.isNotEmpty;
  }
}
