# Security & Offline Layer

- Added encrypted local storage (Hive + flutter_secure_storage) opened in `LocalDatabaseService`. It mirrors Firestore writes/reads for users, applications, news, and messages so the app can keep working offline.
- Passwords are stored as salted SHA-256 hashes (`SecurityUtils.hashPassword`) instead of plain text. OTP codes are hashed before saving to disk.
- Email OTP authentication is enabled through `OtpService`; login requires a one-time code sent to the user mailbox.

## Configure SMTP for OTP
1. Open `lib/utils/email_config.dart`.
2. Fill `smtpHost`, `smtpPort`, `smtpUsername`, `smtpPassword`, and `senderEmail` with the mailbox the user provided.
3. If the SMTP server needs TLS/SSL tweaks, adjust `useSsl`.
4. The OTP email text lives in `OtpService.sendCode`.

## Security secrets to update
- Replace the placeholder pepper in `SecurityUtils._pepper` with an application-specific secret.
- Hive encryption keys are generated at first launch and stored via `flutter_secure_storage` under `aid_app_hive_key`.

## Offline/Sync notes
- Firestore writes now also persist to the encrypted local store; reads fall back to cached data when the network is unavailable.
- Session restoration and notifications continue to work offline with cached user data; FCM registration resumes once connectivity returns.
