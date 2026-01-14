# Архитектура и структура проекта TOGU Aid App

## Схема каталогов

```
aid_app/
├── lib/
│   ├── models/           # модели данных: user, application, news, message
│   ├── services/         # бизнес-логика и работа с Firebase
│   ├── screens/          # экраны: auth, staff, student
│   ├── widgets/          # переиспользуемые компоненты UI
│   └── utils/            # темы, цвета, константы, анимации
├── android/              # Android-конфигурация (Gradle, манифест)
├── ios/, macos/, linux/   # нативные настройки для соответствующих платформ
├── windows/              # CMake, ресурсы Windows-версии
├── web/                  # если используется Flutter Web
├── assets/               # изображения, иконки, шрифты
├── .github/              # CI/CD workflow
├── pubspec.yaml          # зависимости
├── README.md             # обзор
├── BUILD.md              # инструкции по сборке
├── INSTALL.md            # установка
├── INSTRUCTIONS.md       # пользовательские инструкции
├── PROJECT_SUMMARY.md    # сводка проекта
└── другие вспомогательные файлы (COMMANDS.md, FILE_INVENTORY.md, и т. д.)
```

## Принципы архитектуры

1. **Provider** — централизованное управление состоянием (`AuthService`, `ApplicationService`, `NewsService`, `ChatService`). Компоненты подписываются на изменения, что упрощает обновление UI.
2. **Сервисный слой** — всю работу с Firestore выполняет `DatabaseService`, а остальные сервисы обрабатывают бизнес-логику и валидацию.
3. **Модели** (`user_model`, `application_model`, `news_model`, `message_model`) реализуют `toMap()`, `fromMap()` и `copyWith()` для безопасной сериализации.
4. **Разделение по ролям**: экраны сотрудников и студентов находятся в отдельных каталогах, поставляют только нужный функционал.

## Поток данных

```
Пользователь → UI (Screen/Widget) → Service (ApplicationService/AuthService) → DatabaseService → Firebase
                               ↑                                                 ↓
                        Provider уведомляет UI ← результаты операций ← Firebase
```

## Аутентификация

1. Ввод email, ID и пароля → `LoginScreen`.
2. `AuthService.login()` проверяет email, ищет пользователя через `DatabaseService`.
3. Определяется роль (студент/сотрудник) по `staff_users`.
4. После успешного входа происходит переход на соответствующий экран.

## Компоненты

### Модели
- `UserModel` — профиль пользователя, флаг `isStaff`.
- `ApplicationModel` — заявка на помощь с категориями, статусами и вложениями.
- `NewsModel` — новостной пост с изображением и лайками.
- `MessageModel` — структура чат-сообщения.

### Сервисы
- `DatabaseService` — singleton для CRUD-операций, работа со всеми коллекциями.
- `AuthService` — `ChangeNotifier`, хранит `currentUser`, управляет входом/регистрацией.
- `ApplicationService` — отправляет заявления, фильтрует, считает статистику и суммы.
- `NewsService` — создает/обновляет новости, поддерживает лайки.
- `ChatService` — отправляет сообщения, загружает диалоги, хранит состояние переписки.

### Экраны
- `auth/login` и `auth/register` — формы, валидация, обработка ошибок.
- `staff/dashboard`, `staff/statistics`, `staff/news`, `staff/applications`, `staff/chat` — интерфейсы сотрудника.
- `student/dashboard`, `student/applications`, `student/news`, `student/chat`, `student/faq` — интерфейсы студента.

### Виджеты
- `gradient_button`, `custom_app_bar`, `application_card`, `navigation_sidebar`, `news_card` — переиспользуемые визуальные блоки, оформленные в рамках темы.

### Утилиты
- `app_colors`, `app_theme`, `app_animations`, `app_utils`, `app_constants` — статические значения, анимации, универсальные функции и константы (рабочие часы, контакты, категории).

## Схема базы данных (Firestore)

- `users`: `id`, `email`, `studentId`, `fullName`, `phone`, `isStaff`, `createdAt`, `avatar`, `academicGroup`.
- `applications`: `id`, `userId`, `category`, `description`, `status`, `attachments`, `approvedAmount`, `notes`, `createdAt`, `reviewedAt`, `rejectionReason`, `reviewedBy`.
- `news`: `id`, `title`, `content`, `imageUrl`, `createdBy`, `createdAt`, `likes`, `likedBy`, `updatedAt`.
- `messages`: `id`, `senderId`, `senderName`, `recipientId`, `content`, `sentAt`, `isRead`, `attachmentUrl`.
- `staff_users`: `id`, `email`, `studentId`.

## DI и состояние

- `MultiProvider` в `main.dart` предоставляет экземпляры сервисов и предоставляет доступ по всему приложению.
- **Глобальное состояние**: `Provider` → `ChangeNotifier` `AuthService`.
- **Локальное состояние**: `StatefulWidget`, `setState`, контролирует формы, анимации и раскрытие секций.
- **Async-данные**: `FutureBuilder`, `StreamBuilder`, `AsyncValue` внутри сервисов.

## Обработка ошибок и безопасность

- Сервисы используют `try-catch` и выводят пользовательские уведомления (диалоги, snack bar).
- Проверки: email-валидатор, телефон, пустые поля, ограничения по документам.
- В `app_constants` хранятся сообщения об ошибках, чтобы выносить тексты из UI.

## Производительность

1. `const`-конструкторы для статичных элементов.
2. `ListView.builder` и lazy-рендеринг.
3. Минимизация перерисовок через `Provider` и `Consumer`.
4. Анимации с `TickerProvider` и `AnimatedBuilder`.
5. Placeholder-изображения (shimmer) при загрузке данных.

## Тестирование

- Утилиты `flutter test`, `flutter analyze`, `dart format`.
- Модульные тесты для валидаторов и утилит.
- Виджетные тесты для форм и навигации.
- Интеграционные сценарии: вход → подача заявки → чат.

## Масштабирование и развитие

1. Сервисы легко перенести на REST/GraphQL с менее затратными изменениями UI.
2. Реализация WebSocket/Socket.io для чата.
3. Добавление push-уведомлений, оффлайн-режима и экспорта заявок.
4. Возможность мультиязычности (пока основной русский).

## Безопасность для продакшна

- Применить хеширование паролей, токен-авторизацию.
- Шифрование чувствительных полей (документы, телефоны).
- HTTPS на серверных API, firewall/ограничение частоты.
- Внедрить политики доступа в Firebase Security Rules.

## Процесс разработки

- Соблюдать нейминг: файлы `snake_case`, классы `PascalCase`, переменные `camelCase`, константы `UPPER_SNAKE_CASE`.
- Комментарии только там, где логика не очевидна, doc comments для публичных методов.
- По возможности по одному экрану на файл. Максимум 500 строк на файл.
- Git-flow: `main` → `develop` → `feature/bugfix`.

## Чеклист перед релизом

- Обновить номер версии в `pubspec.yaml`.
- Пересмотреть список сотрудников.
- Отредактировать рабочие часы и контакты (`app_constants`).
- Прогнать `flutter analyze`, `flutter test`.
- Собрать релизы (`flutter build`).
- Подписать APK/EXE, собрать записи о тестах и релиз-ноты.
