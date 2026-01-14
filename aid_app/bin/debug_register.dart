import 'dart:math';

import 'package:firebase_core/firebase_core.dart';

import '../lib/database_service.dart';
import '../lib/firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final db = DatabaseService.instance;
  final rand = Random();
  final id = 'debug-${rand.nextInt(1 << 32)}';
  final email = '$id@togudv.ru';
  final now = DateTime.now();

  final userMap = {
    'id': id,
    'email': email,
    'studentId': id,
    'fullName': 'Debug User',
    'phone': '+79990000000',
    'isStaff': 0,
    'createdAt': now.toIso8601String(),
    'academicGroup': '101-AB',
    'password': 'Password123',
  };

  await db.createUser(userMap);
  print('User created with email $email');
}
