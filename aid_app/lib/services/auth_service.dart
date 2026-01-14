import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'database_service.dart';
import '../utils/app_utils.dart';
import '../utils/security_utils.dart';
import 'notification_service.dart';
import 'otp_service.dart';

class AuthService extends ChangeNotifier {
  static const _sessionKey = 'aid_app_user_id';
  final DatabaseService _db = DatabaseService.instance;
  final OtpService _otpService = OtpService.instance;
  User? _currentUser;
  late final Future<void> _restorationFuture;
  String? _lastErrorMessage;
  StreamSubscription<String>? _tokenRefreshSub;
  Map<String, dynamic>? _registrationData;

  AuthService() {
    _restorationFuture = _restoreSession();
  }

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isStaff => _currentUser?.isStaff ?? false;
  Future<void> get restorationDone => _restorationFuture;
  String? get lastError => _lastErrorMessage;

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString(_sessionKey);
    if (savedUserId == null) return;

    try {
      final userMap = await _db.getUserById(savedUserId);
      if (userMap != null) {
        _currentUser = User.fromMap(userMap);
        await NotificationService.instance.listenForUser(_currentUser!.id);
        await _registerFcmToken();
        notifyListeners();
      }
    } catch (e) {
      print('Session restore error: $e');
    }
  }

  Future<void> _persistSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, userId);
  }

  Future<bool> login(String email, String password, {required String otpCode}) async {
    if (otpCode.isEmpty) {
      _lastErrorMessage = 'Введите код подтверждения, отправленный на почту.';
      return false;
    }
    try {
      _lastErrorMessage = null;
      final normalizedEmail = email.trim().toLowerCase();
      final userMap = await _db.getUserByEmail(normalizedEmail);
      
      if (userMap == null) {
        _lastErrorMessage = 'Пользователь с таким email не найден.';
        return false;
      }

      // Basic password check if stored
      final storedPassword = (userMap['passwordHash'] ?? userMap['password'] ?? '') as String;
      if (storedPassword.isNotEmpty && !SecurityUtils.verifyPassword(password, storedPassword)) {
        _lastErrorMessage = 'Неверный пароль';
        return false;
      }

      final otpValid = await _otpService.verifyCode(normalizedEmail, otpCode);
      if (!otpValid) {
        _lastErrorMessage = 'Неверный или просроченный код подтверждения.';
        return false;
      }

      _currentUser = User.fromMap(userMap);
      await _persistSession(_currentUser!.id);
      await NotificationService.instance.listenForUser(_currentUser!.id);
      await _registerFcmToken();
      _listenTokenRefresh();
      await _otpService.clearCode(normalizedEmail);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      _lastErrorMessage = e.message;
      print('Login error: ${e.code} ${e.message}');
      return false;
    } catch (e) {
      _lastErrorMessage = e.toString();
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> sendRegistrationCode({
    required String email,
    required String fullName,
    required String phone,
    required String password,
    required String? academicGroup,
    required bool isStaff,
  }) async {
    try {
      _lastErrorMessage = null;
      final normalizedEmail = email.trim().toLowerCase();
      if (!AppUtils.isToguEmail(normalizedEmail)) {
        _lastErrorMessage = 'Используйте корпоративную почту @togudv.ru';
        return false;
      }
      if (!AppUtils.isValidFullName(fullName) || !AppUtils.isValidPhone(phone) || (!isStaff && !AppUtils.isValidAcademicGroup(academicGroup ?? ''))) {
        _lastErrorMessage = 'Проверьте корректность введённых данных';
        return false;
      }
      final existingUser = await _db.getUserByEmail(normalizedEmail);
      if (existingUser != null) {
        _lastErrorMessage = 'Пользователь уже существует';
        return false;
      }

      final salt = SecurityUtils.generateSalt();
      final hashedPassword = SecurityUtils.hashPassword(password, salt: salt);
      
      _registrationData = {
        'email': normalizedEmail,
        'fullName': fullName,
        'phone': phone,
        'academicGroup': academicGroup,
        'isStaff': isStaff,
        'passwordHash': hashedPassword,
        'passwordSalt': salt,
      };

      final ok = await _otpService.sendCode(normalizedEmail);
      if (!ok) {
        _lastErrorMessage = 'Не удалось отправить код подтверждения. Проверьте конфигурацию SMTP.';
        return false;
      }
      return true;
    } catch (e) {
      _lastErrorMessage = 'Произошла ошибка: $e';
      return false;
    }
  }

  Future<bool> completeRegistration({required String otpCode}) async {
    if (_registrationData == null) {
      _lastErrorMessage = 'Процесс регистрации не был начат. Пожалуйста, запросите код снова.';
      return false;
    }
    if (otpCode.isEmpty) {
      _lastErrorMessage = 'Введите код подтверждения.';
      return false;
    }

    try {
      _lastErrorMessage = null;
      final email = _registrationData!['email'] as String;

      final otpValid = await _otpService.verifyCode(email, otpCode);
      if (!otpValid) {
        _lastErrorMessage = 'Неверный или просроченный код подтверждения.';
        return false;
      }

      final derivedStudentId = email.split('@').first;
      const uuid = Uuid();
      final userId = uuid.v4();

      final user = User(
        id: userId,
        email: email,
        studentId: derivedStudentId,
        fullName: _registrationData!['fullName'] as String,
        phone: _registrationData!['phone'] as String,
        isStaff: _registrationData!['isStaff'] as bool,
        academicGroup: _registrationData!['academicGroup'] as String?,
        passwordHash: _registrationData!['passwordHash'] as String,
        passwordSalt: _registrationData!['passwordSalt'] as String,
        createdAt: DateTime.now(),
      );

      await _db.createUser(user.toMap());
      if (user.isStaff) {
        await _db.upsertStaffUser(user.id, user.email, user.studentId);
      }

      _currentUser = user;
      await _persistSession(user.id);
      await NotificationService.instance.listenForUser(user.id);
      await _registerFcmToken();
      _listenTokenRefresh();
      await _otpService.clearCode(email);
      
      _registrationData = null; // Clear temporary data
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      _lastErrorMessage = e.message ?? 'Firebase error: ${e.code}';
      print('Registration error: ${e.code} ${e.message}');
      return false;
    } catch (e) {
      _lastErrorMessage = e.toString();
      print('Registration error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await NotificationService.instance.stopListening();
    await _tokenRefreshSub?.cancel();
    notifyListeners();
  }

  Future<bool> sendLoginCode(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    final userMap = await _db.getUserByEmail(normalizedEmail);
    if (userMap == null) {
      _lastErrorMessage = 'Пользователь не найден';
      return false;
    }
    final ok = await _otpService.sendCode(normalizedEmail);
    if (!ok) {
      _lastErrorMessage = 'Не удалось отправить код подтверждения. Проверьте конфигурацию SMTP.';
    }
    return ok;
  }

  Future<void> _registerFcmToken() async {
    if (!NotificationService.instance.isFcmAvailable) return;
    final token = await NotificationService.instance.getFcmToken();
    if (token != null && _currentUser != null) {
      await _db.upsertUserToken(_currentUser!.id, token);
    }
  }

  void _listenTokenRefresh() {
    if (!NotificationService.instance.isFcmAvailable || _currentUser == null) return;
    _tokenRefreshSub ??= FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      if (_currentUser == null) return;
      await _db.upsertUserToken(_currentUser!.id, token);
    });
  }

  Future<void> updateUser(User updatedUser) async {
    _currentUser = updatedUser;
    notifyListeners();
  }
}
