# Инструкция по установке и настройке TOGU Aid App

## Системные требования

### Минимально
- ОЗУ: 2 ГБ
- Свободное место: 500 МБ
- Процессор: двухъядерный 1.5 ГГц

### ПО для разработки
- Flutter 3.10+
- Dart 3.0+
- Android Studio или VS Code
- Git

### ПО для пользователей
- Android 5.0+ (API 21)
- Windows 10+
- iOS 12+ (при необходимости)

## Этапы установки

### 1. Установка Flutter

#### Windows
```bash
# Скачайте https://flutter.dev/docs/get-started/install/windows
setx PATH "%PATH%;C:\dev\flutter\bin"
flutter --version
flutter doctor
```

#### macOS
```bash
brew install flutter
flutter --version
flutter doctor
```

#### Linux
```bash
git clone https://github.com/flutter/flutter.git -b stable ~/flutter
export PATH="$PATH:$HOME/flutter/bin"
flutter --version
flutter doctor
```

### 2. Подготовка проекта
```bash
git clone <repository-url>
cd aid_app
flutter pub get
flutter pub run build_runner build  # если нужны генерации
```

### 3. Настройка среды

#### Android Studio
1. Откройте проект.
2. Установите рекомендуемые плагины.
3. Примите лицензии: `flutter doctor --android-licenses`.
4. Настройте виртуальное устройство (при необходимости).

#### VS Code
1. Установите расширение Flutter от Dart Code.
2. Запускайте команды из встроенного терминала.

### 4. Прогон на нужной платформе

#### Разработка
```bash
flutter devices
flutter run -d <device-id>
```

#### Сборка Android
```bash
flutter build apk --debug
flutter build apk --release
flutter build appbundle --release
```

#### Сборка Windows
```bash
flutter build windows --debug
flutter build windows --release
```

## Конфигурация

### Firebase
1. Убедитесь, что `firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist` корректны.
2. Создайте коллекции (`users`, `applications`, `news`, `messages`, `staff_users`).
3. При необходимости добавьте сотрудников:
```dart
await DatabaseService.instance.upsertStaffUser(
  'staff-id',
  'staff@togudv.ru',
  '2023999999',
);
```

### Кастомизация
- Переименуйте приложение в `AndroidManifest.xml`, `windows/runner/main.cpp`.
- Цвета: `lib/utils/app_colors.dart`.
- Рабочие часы и контакты: `lib/utils/app_constants.dart`.
- FAQ: `lib/screens/student/student_faq_screen.dart`.

## Запуск приложения

```bash
flutter clean
flutter pub get
flutter run
flutter run -v
```

### Горячая перезагрузка
- запустите `flutter run`, нажимайте `r`, `R`, `q`.

### Релизные сборки

```bash
flutter build apk --release
flutter build windows --release
```

Файлы: `build/app/outputs/flutter-apk/app-release.apk`, `build/windows/runner/Release/aid_app.exe`.

## Тесты

```bash
flutter test
flutter test test/widgets/
flutter test test/specific_test.dart
```

## Устранение неполадок

### Flutter не найден
```bash
flutter doctor -v
```
Добавьте в PATH (`setx` или `export`).

### Сборка Android падает
```bash
flutter clean
flutter pub get
flutter build apk --release -v
```

### База данных не инициализируется
1. Удалите приложение.
2. Очистите кэш.
3. Проверьте `database_service.dart`.

### Горячий перезапуск не работает
```bash
flutter run -R
flutter clean
flutter run
```

### Отсутствуют зависимости
```bash
flutter pub get
flutter pub cache repair
flutter pub global activate <package>
```

## Работа с устройствами

### Android эмулятор
```bash
emulator -list-avds
emulator -avd emulator-name
flutter run -d emulator-5554
```

### iOS симулятор
```bash
open -a Simulator
flutter run -d iPhone
```

### Физическое устройство
1. Включите режим разработчика.
2. Разрешите USB-debug.
3. Подключите и подтвердите.

## Оптимизация

```bash
flutter build apk --release --split-per-abi
flutter run --profile
```

## Мониторинг

```bash
flutter run --observatory-port=8888
flutter pub global activate devtools
devtools
```

## Распространение

### Google Play
1. Создайте аккаунт.
2. Соберите AAB.
3. Загрузите, заполните описание и отправьте на проверку (3-7 дн).

### Microsoft Store
1. Partner Center.
2. Создайте заявку.
3. Загрузите .exe.
4. Отправьте на сертификацию.

### Прямая установка
- Расшаривайте `.apk` или `.exe`.
- Пользователь устанавливает вручную.

## Поддержка

- Официальная документация Flutter и Dart.
- Комьюнити (Discord, Reddit).
- Stack Overflow и GitHub Issues.

## Безопасность

- Пароли хранятся в Firebase (в будущем — хеширование).
- Используйте HTTPS и валидацию.
- Никогда не сохраняйте секреты в git.

## Резервное копирование

- Экспорт коллекций Firebase.
- Храните снимки в защищённых хранилищах.

## Рекомендованные действия

1. Выполните всю подготовку (установка, зависимости).
2. Настройте сотрудников и параметры.
3. Запустите и протестируйте.
4. Соберите и распространите релиз.

---

**Версия**: 1.0.0  
**Обновлено**: декабрь 2024  
