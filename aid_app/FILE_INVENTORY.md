# Инвентаризация файлов проекта

## Исходный код (lib/)

### Точка входа
- `main.dart` — инициализация Flutter, тема и Provider.

### Модели (`lib/models/`)
- `user_model.dart` (пользователь).
- `application_model.dart` (заявка на помощь).
- `news_model.dart` (новости).
- `message_model.dart` (чат-сообщения).

### Сервисы (`lib/services/`)
- `database_service.dart` — работа с Firestore.
- `auth_service.dart` — вход, регистрация, изменение состояния.
- `application_service.dart` — отправка заявок, статистика.
- `news_service.dart` — публикация новостей, лайки.
- `chat_service.dart` — отправка и загрузка сообщений.

### Экраны (`lib/screens/`)
- `auth/login_screen.dart`, `auth/register_screen.dart`.
- `staff/` — dashboard, заявки, статистика, новости, чат.
- `student/` — dashboard, подача заявок, новости, чат, FAQ.

### Виджеты (`lib/widgets/`)
- Градиентные кнопки, карусели, карточки заявок и новостей, боковая панель.

### Утилиты (`lib/utils/`)
- `app_colors.dart`, `app_theme.dart`, `app_animations.dart`, `app_utils.dart`, `app_constants.dart`.

## Конфигурации
- `pubspec.yaml` — зависимости и метаданные.
- Android: `AndroidManifest.xml`, Gradle-файлы.
- Windows: `CMakeLists.txt`, ресурсы.
- Firebase: `firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`.
- CI/CD: `.github/workflows/build.yml`.

## Документация
- `README.md` — обзор проекта и стек.
- `BUILD.md` — пошаговая сборка.
- `INSTALL.md` — установка и настройка.
- `INSTRUCTIONS.md` — инструкции для студентов и сотрудников.
- `ARCHITECTURE.md` — архитектура и потоки данных.
- `PROJECT_SUMMARY.md` — сводный отчёт и рекомендации.
- `COMMANDS.md` — команды Flutter.
- `FILE_INVENTORY.md` — этот файл.
- `FIREBASE_SETUP.md` — настройка Firebase.
- `COURSEWORK_DOCUMENTATION_RU.md` — пояснение курсовой работы.

## Быстрые скрипты
- `quickstart.sh` (bash) — последовательность подготовки окружения.
- `quickstart.bat` (Windows) — аналогично для командной строки.

## Статистика проекта
- Dart-файлов: 30+
- UI-экранов: 10+
- Виджетов: 5+
- Документация: 10+ файлов
- Линий кода: ~5,500

## Реализованный функционал
- Авторизация и роли.
- Подача заявок и прикрепление документов.
- Новости, лайки и комментарии.
- Чат и поддержка.
- Статистика, графики, отчёты.
- Адаптивный дизайн, анимации.
- Валидация и обработка ошибок.

## Что настроить вручную
- `lib/services/database_service.dart` — сотрудники (`staff_users`).
- `lib/utils/app_constants.dart` — рабочие часы, контакты, описания.
- `lib/screens/student/student_faq_screen.dart` — FAQ-контент.
- `assets/` — логотипы, иконки.
- `android/app/google-services.json` и `ios/Runner/GoogleService-Info.plist`.
- Ключи подписи для релизной сборки (`android/key.properties`).

## Структура каталогов

```
aid_app/
├── lib/
│   ├── models/
│   ├── services/
│   ├── screens/
│   ├── widgets/
│   └── utils/
├── android/
├── ios/
├── macos/
├── linux/
├── windows/
├── web/
├── assets/
├── test/
├── .github/
├── pubspec.yaml
├── README.md
└── остальные документы
```

## Что готово для использования
- Полнофункциональный код
- Интерфейсы для всех ролей
- Документация и инструкции
- Скрипты быстрой настройки
- CI/CD и сборочные файлы

## Что требует внимания
- Персонализированные цвета и логотипы
- Контакты и рабочие часы
- FAQ и текстовые блоки
- Настройка Firebase и ключей подписи

## Рекомендации по использованию
1. Запустите `quickstart` для базовой конфигурации.
2. Прочитайте `README.md` и `PROJECT_SUMMARY.md`.
3. Узнайте детали сборки в `BUILD.md`.
4. Настройте Firebase (см. `FIREBASE_SETUP.md`).
5. Соберите релизы и проводите тесты.

---

**Создано:** декабрь 2024  
