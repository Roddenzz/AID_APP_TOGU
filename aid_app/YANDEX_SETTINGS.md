# ACTION REQUIRED: Enable Mail Client Access in Yandex

The new error message, **"This user does not have access rights to this service"**, means that your Yandex account is blocking access from this application.

Even with the correct app password, you must manually enable access for mail clients in your Yandex account settings.

## Please follow these steps exactly:

1.  **Log in** to your Yandex Mail account in a web browser: [https://mail.yandex.com/](https://mail.yandex.com/)

2.  Click the **gear icon** (⚙️) in the top-right corner to open settings.

3.  Select **"All settings"**.

4.  From the top menu, select **"Email clients"**.

5.  You will see a list of checkboxes. You **must** check the following box:
    *   **"From the imap.yandex.com server via IMAP"**

6.  Also, ensure this box is checked:
    *   **"App passwords and OAuth tokens"**

7.  Click the **"Save changes"** button at the bottom of the page.

Here is an example of what the settings page should look like (text is in Russian, as your account likely is):

```
Портальные и мобильные клиенты
    [✓] С сервера imap.yandex.com по протоколу IMAP
    [✓] Пароли приложений и OAuth-токены
```

After you have saved these changes, the application should be able to connect and send emails successfully. Please try sending a code again after you have completed these steps.
