/// SMTP configuration used for sending OTP codes.
/// Fill with the mailbox the user mentioned before running in production.
class EmailConfig {
  // IMPORTANT: Storing credentials directly in the source code is a major security risk 
  // and should not be done in a production environment.
  // Consider using environment variables, a configuration file that is not checked into version control,
  // or a secret management service to handle these credentials securely.
  static const String smtpHost = 'smtp.yandex.ru'; // e.g. smtp.yourmail.ru
  static const int smtpPort = 465;
  static const bool useSsl = true;
  static const String smtpUsername = 'prof.materialhelp@yandex.ru'; // mailbox login
  static const String smtpPassword = 'dalclpadjeuummpm'; // mailbox password/app password
  static const String senderEmail = 'prof.materialhelp@yandex.ru';  // email shown to recipients
  static const String senderName = 'TOGU Aid App';
}
