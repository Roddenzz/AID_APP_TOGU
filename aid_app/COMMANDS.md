# Справочник команд Flutter для TOGU Aid App

## Настройка проекта

### Первый запуск
```bash
# Перейти в каталог
cd aid_app

# Очистить предыдущие сборки
flutter clean

# Установить зависимости
flutter pub get

# Обновить Flutter (по необходимости)
flutter upgrade
```

### Проверка окружения
```bash
flutter doctor
flutter doctor -v
flutter --version
```

## Запуск приложения

### В режиме разработки
```bash
flutter run
flutter run --debug
flutter run -v
flutter run --observatory-port=8888
```

### Выбор устройства
```bash
flutter devices
flutter run -d <device-id>
flutter run -d emulator-5554
flutter run -d iPhone
flutter run -d chrome
```

### Быстрые клавиши
- `r` — hot reload
- `R` — hot restart
- `q` — выйти

## Сборка релизов

### Android
```bash
flutter build apk --debug
flutter build apk --release
flutter build apk --release --obfuscate --split-debug-info=./symbols
flutter build appbundle --release
flutter build appbundle --release --split-per-abi
```

### Windows
```bash
flutter build windows --debug
flutter build windows --release
```

### iOS (только macOS)
```bash
flutter build ios --release
flutter install
```

### macOS
```bash
flutter build macos --release
```

## Тестирование

```bash
flutter test
flutter test --coverage
flutter test test/widgets/
flutter test test/specific_test.dart
flutter drive --target=test_driver/app.dart
flutter run --profile
```

## Качество кода

```bash
flutter analyze
flutter analyze -v
dart format .
dart format lib/main.dart
flutter pub run flutter_lints
```

## Управление зависимостями

```bash
flutter pub get
flutter pub upgrade
flutter pub add package_name:version
flutter pub remove package_name
flutter pub upgrade --major-versions
```

## Очистка кешей

```bash
rm -rf ~/.dart          # macOS/Linux
rmdir /s %APPDATA%\\.dart # Windows
flutter pub cache repair
flutter clean
```

## DevTools и отладка

```bash
flutter run --devtools
flutter pub global activate devtools
devtools
open http://localhost:9100
flutter logs
flutter logs -v
flutter logs 2>&1 | grep ERROR
```

## Подпись приложения

### Android-keystore
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10950 \
  -alias upload
```

Создайте `android/key.properties`:
```
storePassword=<пароль>
keyPassword=<пароль>
keyAlias=upload
storeFile=<путь>
```

## Полная очистка

```bash
flutter clean
rm -rf build/
flutter pub get
flutter run
```

## Управление версиями

```yaml
version: 1.0.0+1
```

## Документация

```bash
dart doc
open doc/api/index.html
```

## Чек-лист перед релизом

```bash
# 1. Обновить версию (pubspec.yaml)
# 2. Прогнать тесты (flutter test)
# 3. Проанализировать (flutter analyze)
# 4. Собрать релизную сборку
# 5. Проверить на устройстве
# 6. Создать тэг и запушить
```

## Полезные алиасы
```bash
alias frun="flutter run"
alias ftest="flutter test"
alias fbuild="flutter build"
alias fclean="flutter clean"
alias fanalyze="flutter analyze"
alias fdocs="dart doc"
alias fpub="flutter pub"
frun
ftest
fbuild apk
```

## Команды для устранения проблем

```bash
flutter doctor -v
flutter clean
rm -rf .dart_tool/
flutter pub get
flutter doctor -v --android
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
```

## Важные ссылки
- https://flutter.dev/docs
- https://dart.dev/guides
- https://pub.dev

## Советы по производительности

```bash
flutter build apk --release --analyze-size
```

## Работа с CI/CD

### GitHub Actions
```bash
cat .github/workflows/build.yml
act push
```

### Локальные сборки
```bash
flutter build apk --release
flutter build appbundle --release
flutter build windows --release
flutter build ios --release
flutter build macos --release
```

---

**Примечание:** команды могут различаться в зависимости от ОС. Проверяйте официальную документацию.
**Обновлено:** декабрь 2024
