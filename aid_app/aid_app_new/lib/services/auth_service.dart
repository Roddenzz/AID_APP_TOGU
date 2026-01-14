import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isStaff => _currentUser?.isStaff ?? false;

  Future<bool> login(String email, String studentId, String password) async {
    try {
      final userMap = await _db.getUserByEmail(email);
      
      if (userMap == null) {
        return false;
      }

      final user = User.fromMap(userMap);
      
      if (user.studentId != studentId) {
        return false;
      }

      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> register(
    String email,
    String studentId,
    String fullName,
    String phone,
    String password,
    String? academicGroup,
  ) async {
    try {
      // Check if user already exists
      final existingUser = await _db.getUserByEmail(email);
      if (existingUser != null) {
        return false;
      }

      const uuid = Uuid();
      final userId = uuid.v4();

      // Check if this is a staff user
      final isStaff = await _db.isStaffUser(email, studentId);

      final user = User(
        id: userId,
        email: email,
        studentId: studentId,
        fullName: fullName,
        phone: phone,
        isStaff: isStaff,
        createdAt: DateTime.now(),
        academicGroup: academicGroup,
      );

      await _db.createUser(user.toMap());

      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateUser(User updatedUser) async {
    _currentUser = updatedUser;
    notifyListeners();
  }
}
