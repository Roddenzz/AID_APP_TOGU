# ACTION REQUIRED: Authentication Failed

I have re-verified and re-entered the credentials you provided:
*   **Email:** `prof.materialhelp@yandex.ru`
*   **Password:** `HvHboy228`

The `Authentication Failed (code: 535)` error persists. **This is not a typo.**

This error almost certainly means that **Two-Factor Authentication (2FA) is enabled on the Yandex account.** When 2FA is active, you **cannot** use your regular account password for external applications like this one.

**You must generate and provide a special "app password".**

Please follow these steps:
1.  Log in to your Yandex account.
2.  Go to **Account Settings** -> **Security**.
3.  Find the **App passwords** section.
4.  Create a new app password for this application.
5.  **Provide me with the generated app password.** It will be a string of random characters.

The current password `HvHboy228` will not work. I am awaiting the **app password**.

---
# SMTP Authentication Error

**Error:** The application is currently failing to send emails with the error: `Authentication Failed (code: 535) ... Invalid user or password!`.

This error means the username or password being used for the SMTP server is incorrect.

**How to Fix:**

1.  **Verify Credentials:** Please double-check the email address and password you provided.
    *   Email: `prof.materialhelp@yandex.ru`
    *   Password: `HvHboy228`

2.  **Check for Two-Factor Authentication (2FA):** If 2FA is enabled on the `prof.materialhelp@yandex.ru` Yandex account, you **cannot** use your regular password for SMTP. You must generate a special **"app password"** from within your Yandex account settings and use that app password in the configuration.

    *   Log in to your Yandex account.
    *   Go to **Account Settings** -> **Security**.
    *   Find the **App passwords** section and create a new password for this application.
    *   Use the generated app password as the `smtpPassword`.

Once you have the correct password or app password, please provide it, and I will update the configuration.

---

# Security Note: Handling of SMTP Credentials

## WARNING: Credentials in Source Code

The SMTP credentials for the email service are currently stored directly in the source code in `lib/utils/email_config.dart`.

**This is a major security vulnerability.**

Storing sensitive information like passwords in source code is extremely risky because:

1.  **Version Control History:** Anyone with access to the source code repository (including its history) can see the credentials in plain text.
2.  **Accidental Exposure:** The credentials can be easily leaked if the code is shared, published, or accessed by unauthorized individuals.
3.  **Hard to Change:** Changing the password requires a code change, a new build, and redeployment of the application.

## Recommended Alternatives

For a production environment, you should use a more secure method to handle these credentials. Here are some recommended alternatives:

### 1. Environment Variables

Store the credentials in environment variables on the server or machine where the application is running.

**Example:**

You would set environment variables on your system:

```bash
export SMTP_USERNAME="prof.materialhelp@yandex.ru"
export SMTP_PASSWORD="your_password"
```

And then in your Flutter application, you would load these variables at runtime. You can use a package like `flutter_dotenv` to help with this.

**`lib/utils/email_config.dart` (with environment variables):**

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmailConfig {
  static final String smtpHost = dotenv.env['SMTP_HOST'] ?? 'smtp.yandex.ru';
  static final int smtpPort = int.tryParse(dotenv.env['SMTP_PORT'] ?? '465') ?? 465;
  static final bool useSsl = (dotenv.env['SMTP_USE_SSL'] ?? 'true') == 'true';
  static final String smtpUsername = dotenv.env['SMTP_USERNAME'] ?? '';
  static final String smtpPassword = dotenv.env['SMTP_PASSWORD'] ?? '';
  static final String senderEmail = dotenv.env['SMTP_SENDER_EMAIL'] ?? '';
  static const String senderName = 'TOGU Aid App';
}
```

You would need to create a `.env` file (and add it to your `.gitignore` to avoid committing it) with the following content:

**.env file:**
```
SMTP_HOST=smtp.yandex.ru
SMTP_PORT=465
SMTP_USE_SSL=true
SMTP_USERNAME=prof.materialhelp@yandex.ru
SMTP_PASSWORD=HvHboy228
SMTP_SENDER_EMAIL=prof.materialhelp@yandex.ru
```

### 2. Secure Secret Management Service

For a higher level of security, use a dedicated secret management service like:

*   **Google Secret Manager**
*   **AWS Secrets Manager**
*   **Azure Key Vault**
*   **HashiCorp Vault**

These services are designed to store and manage secrets securely. Your application would then fetch the credentials from the service at runtime using a secure authentication mechanism.

## Immediate Action

The hardcoded credentials should be removed from the source code and replaced with one of the secure methods described above as soon as possible, especially before deploying this application in a production environment.
