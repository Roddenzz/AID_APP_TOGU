import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/email_config.dart';
import '../utils/security_utils.dart';

class OtpService {
  static const _otpKeyPrefix = 'otp_record_';
  static const _expiryMinutes = 10;

  OtpService._internal();

  static final OtpService instance = OtpService._internal();

  Future<bool> sendCode(String email) async {
    final code = SecurityUtils.generateOtp();
    final hashed = SecurityUtils.hashOtp(code, email);
    final expiresAt = DateTime.now().add(const Duration(minutes: _expiryMinutes));
    await _persistOtp(email, hashed, expiresAt);

    try {
      if (_isEmailConfigured) {
        final smtpServer = SmtpServer(
          EmailConfig.smtpHost,
          port: EmailConfig.smtpPort,
          ssl: EmailConfig.useSsl,
          username: EmailConfig.smtpUsername,
          password: EmailConfig.smtpPassword,
        );
        final message = Message()
          ..from = Address(EmailConfig.senderEmail, EmailConfig.senderName)
          ..recipients.add(email)
          ..subject = 'Aid App - код подтверждения'
          ..text = 'Ваш код подтверждения: $code (действует $_expiryMinutes минут).';

        await send(message, smtpServer);
      } else {
        // ignore: avoid_print
        print('OTP not sent: SMTP is not configured. Code: $code');
      }
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Failed to send OTP email: $e');
      return false;
    }
  }

  Future<bool> verifyCode(String email, String code) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_otpKeyPrefix$email');
    if (raw == null || raw.isEmpty) return false;
    final parts = raw.split('|');
    if (parts.length != 2) return false;
    final storedHash = parts[0];
    final expires = DateTime.tryParse(parts[1]);
    if (expires == null || DateTime.now().isAfter(expires)) return false;
    return SecurityUtils.hashOtp(code, email) == storedHash;
  }

  Future<void> clearCode(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_otpKeyPrefix$email');
  }

  Future<void> _persistOtp(String email, String hashedCode, DateTime expiresAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_otpKeyPrefix$email', '$hashedCode|${expiresAt.toIso8601String()}');
  }

  bool get _isEmailConfigured {
    return EmailConfig.smtpHost.isNotEmpty &&
        EmailConfig.smtpUsername.isNotEmpty &&
        EmailConfig.smtpPassword.isNotEmpty &&
        EmailConfig.senderEmail.isNotEmpty;
  }
}
