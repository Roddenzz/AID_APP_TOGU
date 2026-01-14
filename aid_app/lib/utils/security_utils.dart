import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Security helpers for hashing passwords/OTP codes.
class SecurityUtils {
  /// Change this to your own secret pepper before releasing.
  static const String _pepper = 'aid_app_pepper_change_me';

  static String generateSalt([int length = 16]) {
    final rand = Random.secure();
    final bytes = List<int>.generate(length, (_) => rand.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String hashPassword(String password, {String? salt}) {
    final useSalt = salt ?? generateSalt();
    final digest = sha256.convert(utf8.encode('$useSalt::$password::$_pepper')).toString();
    return '$useSalt:$digest';
  }

  static bool verifyPassword(String password, String storedHash) {
    if (storedHash.isEmpty) return false;
    final parts = storedHash.split(':');
    if (parts.length == 2) {
      final salt = parts.first;
      final recomputed = hashPassword(password, salt: salt);
      return constantTimeEquals(recomputed, storedHash);
    }
    // Fallback to legacy plain-text comparison to keep backward compatibility.
    return storedHash == password;
  }

  static String generateOtp({int length = 6}) {
    final rand = Random.secure();
    final codeUnits = List<int>.generate(length, (_) => rand.nextInt(10));
    return codeUnits.join();
  }

  static String hashOtp(String code, String email) {
    return sha256.convert(utf8.encode('$email::$code::$_pepper')).toString();
  }

  static bool constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}
