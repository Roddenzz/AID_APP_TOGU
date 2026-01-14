# Настройка Firebase для TOGU Aid App

## Шаг 1. Создайте проект
1. Перейдите в [Firebase Console](https://console.firebase.google.com/).
2. Нажмите «Добавить проект» и следуйте подсказкам.

## Шаг 2. Добавьте Android-приложение

1. В проекте выберите иконку Android.
2. **Package name** — найдите `applicationId` в `android/app/build.gradle`.
3. Укажите название приложения (NickName).
4. **SHA-1** (рекомендуется): выполните `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`.
5. Скачайте `google-services.json` и поместите в `android/app/`.

## Шаг 3. Добавьте iOS-приложение

1. Выберите иконку iOS в Firebase.
2. **Bundle ID** — `PRODUCT_BUNDLE_IDENTIFIER` в Xcode (`ios/Runner.xcworkspace` → Runner → General).
3. Укажите название (NickName) и, при наличии, App Store ID.
4. Скачайте `GoogleService-Info.plist` и положите в `ios/Runner/`.

## Шаг 4. Интеграция в проект

1. После загрузки конфигурационных файлов выполните `flutter pub get`.
2. Убедитесь, что `firebase_options.dart` содержит актуальные данные.
3. Проверьте, что `lib/services/database_service.dart` обращается к нужным коллекциям (`users`, `applications`, `news`, `messages`, `staff_users`).

## Шаг 5. Рабочие коллекции
- `users` — хранит профили студентов и сотрудников.
- `applications` — заявки, статусы, прикрепления.
- `news` — новости, лайки.
- `messages` — чат-сообщения.
- `staff_users` — список сотрудников (поля `id`, `emailLowercase`, `studentId`).

## Что сделать после
1. Запустить `flutter run` и убедиться, что Firebase инициализируется.
2. При необходимости обновить `google-services.json` и `GoogleService-Info.plist`.
3. Проверить, что `AuthService` распознаёт роли.

## Комментарий
После выполнения шагов можно продолжить сборку, загрузку новостей и тестирование чата. Если потребуется, обратитесь к `BUILD.md` для платформенных инструкций.
