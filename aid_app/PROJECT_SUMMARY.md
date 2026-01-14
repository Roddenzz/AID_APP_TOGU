# Курсовой проект TOGU Aid App — итоги и рекомендации

## Обзор
Flutter-приложение для студентов и сотрудников ТОГУ, реализующее подачу заявок на материальную помощь, обработку, статистику, новости и чат. Система построена на Dart 3.0+ и Flutter 3.10+, работает на Android, Windows и готова к другим платформам (iOS, macOS, Web).

## Что реализовано

### Общее
- Авторизация с учётом ролей и проверки по `staff_users`.
- Хранение данных в Firebase Cloud Firestore.
- Структура: модели → сервисы → экраны → виджеты → утилиты.
- Документированные сценарии запуска, сборки и эксплуатации.

### Сотрудники
- Панель с навигацией и фильтрацией заявок.
- Статистика (fl_chart), новостной редактор, чат со студентами.
- Контроль статуса заявки, прикреплённые документы, одобрение/отклонение.

### Студенты
- Подбор категорий помощи, загрузка документов.
- Страница «Мои заявки» с историями и статусами.
- Новости, лайки и чат с сотрудниками.
- FAQ с контактами и рабочим временем.

## Технологии
- **Flutter** 3.10+ (Material 3).
- **Dart** 3.0+ (основной язык проекта).
- **Firebase Cloud Firestore** — хранение пользователей, заявок, новостей и чата.
- **Provider** — управление состоянием.
- **fl_chart** — графики.
- **file_picker**, **image_picker**, **shared_preferences**, **uuid**, **intl** и другие утилиты.

## Структура файлов

```
lib/
  models/
  services/
  screens/
  widgets/
  utils/
android/
windows/
ios/, macos/, linux/
assets/
test/
.github/
```

## Что нужно сделать

1. Установка: Flutter SDK, Android Studio/VS Code, Git.
2. Клонировать репозиторий и выполнить `flutter pub get`.
3. Заполнить Firebase-конфигурации (`google-services.json`, `GoogleService-Info.plist`).
4. Добавить сотрудников (через `DatabaseService.upsertStaffUser` или консоль Firebase).
5. Настроить цвета, FAQ, рабочие часы, контакты (`lib/utils` и `student_faq_screen.dart`).

## Настройка

- **Firebase**: включите коллекции `users`, `applications`, `news`, `messages`, `staff_users`.
- **Рабочие часы и контакты**: `lib/utils/app_constants.dart`.
- **Цвета и тема**: `lib/utils/app_colors.dart`, `lib/utils/app_theme.dart`.
- **FAQ**: `lib/screens/student/student_faq_screen.dart`.

## Сборка и запуск

```bash
flutter pub get
flutter run
flutter build apk --release
flutter build windows --release
```

## Документация
- `README.md` — обзор и палитра.
- `ARCHITECTURE.md` — принципы архитектуры.
- `BUILD.md` — инструкции по сборке.
- `INSTALL.md` — установка и конфигурация.
- `INSTRUCTIONS.md` — пользовательские инструкции.
- `COMMANDS.md` — команды Flutter.
- `FILE_INVENTORY.md` — инвентаризация файлов.
- `COURSEWORK_DOCUMENTATION_RU.md` — пояснение курсовой работы.
- `FIREBASE_SETUP.md` — шаги настройки Firebase.
- `COMPLETION_REPORT.md` — отчёт о завершении.

## Руководство к действию

1. Прочитать `COURSEWORK_DOCUMENTATION_RU.md` и `PROJECT_SUMMARY.md`.
2. Настроить Firebase и тестовых сотрудников.
3. Протестировать вход, подачу заявки, новости, чат и статистику.
4. Собрать релизные пакеты для Android и Windows.
5. Подготовить релизные заметки и записать запуск приложения.

## Контроль качества

- Проверьте `flutter analyze`, `flutter test`.
- Убедитесь в работоспособности на Android и Windows.
- Обновите зависимости (`flutter pub upgrade`) при необходимости.
- Поддерживайте документацию.

## Заключение
Проект готов к защите: реализованы основные пользовательские сценарии, документированы архитектура и сборка, и построено приложение на Dart/Flutter с Firebase-поддержкой. Осталось провести демонстрацию, собрать тесты и оформить релиз.
