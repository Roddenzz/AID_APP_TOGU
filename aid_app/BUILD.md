# Инструкции по сборке TOGU Aid App

## Необходимые инструменты

### Для всех платформ
- Flutter SDK 3.10.0 и выше
- Dart SDK (входит в Flutter)
- Git

### Для Android
- Android SDK 21+
- Android Studio
- JDK 11+

### Для Windows
- Visual Studio 2019 или новее (с компонентами Desktop development)
- Windows 10 SDK
- CMake 3.14+

### Для macOS / iOS
- Xcode 14+
- iOS 12+
- CocoaPods

## Быстрый старт

```bash
git clone https://github.com/yourusername/aid_app.git
cd aid_app
flutter pub get
```

## Запуск в режиме разработки

```bash
# на подключённом устройстве по умолчанию
flutter run

# указать конкретное устройство
flutter run -d <device-id>

# с подробным выводом
flutter run -v
```

## Сборка для релиза

### Android

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle для Google Play
flutter build appbundle --release
```

Файлы выходят в `build/app/outputs/flutter-apk/` и `build/app/outputs/bundle/release/`.

### Windows

```bash
flutter build windows --release
```

Результат: `build/windows/runner/Release/aid_app.exe`.

### iOS / macOS

```bash
flutter build ios --release
flutter build macos --release
```

## Настройка перед сборкой

### Firebase и сотрудники
Обновите `android/app/google-services.json` и `ios/Runner/GoogleService-Info.plist`. Убедитесь, что коллекция `staff_users` заполнена.

### Иконки и название
- Android: обновите ресурсы в `android/app/src/main/res/`.
- Windows: ресурсы и `windows/runner/resources/`.
- iOS: `ios/Runner/Assets.xcassets`.
- Название: `AndroidManifest.xml`, `windows/runner/main.cpp`, `ios/Runner/Info.plist`.

### Подписанные сборки (Android)
Создайте `android/key.properties` с `storePassword`, `keyPassword`, `keyAlias`, `storeFile`. Обновите `build.gradle` для подстановки секретов.

## Дополнительные опции

### Обфускация Android

```bash
flutter build apk --release --obfuscate --split-debug-info=./symbols
```

### Конкретная архитектура

```bash
flutter build apk --release --target-platform android-arm64
flutter build windows --release
```

### Null Safety
Включена по умолчанию (Dart 3.0+).

## Диагностика и устранение проблем

### Сборка не удалась

```bash
flutter clean
flutter pub get
flutter build <platform> --release
```
Проверка: `flutter doctor -v`.

### Проблемы с правами

```bash
# Android (Linux/macOS)
sudo chown -R $USER:$USER ~/.gradle
chmod +x gradlew

# macOS
xcode-select --install
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### Мало места в хранилище

```bash
rm -rf ~/.dart
flutter pub cache repair
```

## Оптимизации

### Уменьшение размера

```bash
flutter build apk --release --split-per-abi
```

### Профилирование

```bash
flutter build apk --profile
flutter run --profile
```

## Тестирование

```bash
flutter test
flutter test test/widgets/
flutter drive --target=test_driver/app.dart
```

## Управление версиями

Обновите `pubspec.yaml`:

```yaml
version: 1.0.0+1
```

## Публикация

### Google Play
1. Создайте аккаунт Play Console
2. Подготовьте релиз (AAB)
3. Загрузите, заполните описание и отправьте на проверку

### Microsoft Store
1. Partner Center → заявка на приложение
2. Загрузите .exe или MSI
3. Отправьте на сертификацию

## CI/CD

.github/workflows/build.yml настраивает:
- сборку Android, Windows, iOS
- запуск тестов и `flutter analyze`
- загрузку артефактов

## Отладка

```bash
flutter run -v          # подробные логи
flutter run -d <device> --observe
flutter analyze
```

## Распространение

Подготовьте release notes:

```markdown
## v1.0.0 (ГГГГ-ММ-ДД)
- список возможностей
- исправления
- улучшения
```

## Системные требования

| Платформа | Минимум | Рекомендуется |
|-----------|---------|---------------|
| Android   | 5.0     | Android 13+   |
| iOS       | 12.0    | 16.0+         |
| Windows   | 10      | 11            |
| macOS     | 10.15   | 12.0+         |

## Поддержка

1. `flutter doctor`
2. Анализ логов
3. Поиск ответов в сообществе Flutter

## Полезные ссылки

- https://flutter.dev/docs/deployment
- https://flutter.dev/docs/deployment/android
- https://flutter.dev/docs/deployment/ios
- https://flutter.dev/docs/deployment/windows

---

**Обновлено**: Декабрь 2024  
**Flutter**: 3.10.0  
