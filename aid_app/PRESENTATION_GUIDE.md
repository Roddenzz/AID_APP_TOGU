# Руководство по презентации проекта "Aid App"

Этот документ поможет вам последовательно продемонстрировать и объяснить структуру и ключевые компоненты вашего Flutter-приложения.

---

### Шаг 1: Обзор и конфигурация проекта (`pubspec.yaml`)

Начните с этого файла. Он как "паспорт" проекта.

**Что объяснить:**
- **Название и описание**: `name` и `description`.
- **Зависимости (`dependencies`)**: Расскажите о 3-4 ключевых пакетах, которые вы использовали.
- **Ресурсы (`assets` и `fonts`)**: Покажите, как вы добавили в проект изображения и шрифты.

**Ключевой фрагмент кода из `pubspec.yaml`:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  #--- Ключевые зависимости ---
  # Управление состоянием
  provider: ^6.0.8
  # Работа с Firebase (облачная база данных, аутентификация)
  firebase_core: ^4.2.1
  firebase_auth: ^6.1.2
  cloud_firestore: ^6.1.0
  # Локальная база данных для оффлайн-режима
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  # Для отправки почты (коды подтверждения)
  mailer: ^6.1.0
  # Безопасное хранение данных
  flutter_secure_storage: ^9.2.2

# ...другие зависимости

flutter:
  uses-material-design: true

  #--- Подключение ресурсов ---
  assets:
    - assets/images/
    - assets/icons/
    - assets/videos/

  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
```
**Объяснение:** "Проект использует `provider` для управления состоянием, `Firebase` как основную серверную часть, `Hive` для локального кэширования данных, что обеспечивает работу в оффлайн-режиме, и `mailer` для отправки email с кодами верификации."

---

### Шаг 2: Точка входа и инициализация (`lib/main.dart`)

Это самый первый файл, который исполняется при запуске приложения.

**Что объяснить:**
- **Функция `main()`**: Расскажите, какие сервисы инициализируются *до* запуска приложения (`WidgetsFlutterBinding.ensureInitialized()`).
- **Инициализация сервисов**: Покажите, что вы инициализируете локальную базу данных (`LocalDatabaseService`), Firebase и сервис уведомлений (`NotificationService`).
- **`MyApp` и `MultiProvider`**: Объясните, что `MultiProvider` делает сервис аутентификации (`AuthService`) доступным во всем дереве виджетов.

**Ключевой фрагмент кода из `lib/main.dart`:**
```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ... импорты

void main() async {
  // Гарантирует, что все биндинги Flutter инициализированы
  WidgetsFlutterBinding.ensureInitialized();

  // Асинхронная инициализация сервисов перед запуском UI
  await LocalDatabaseService.instance.init(); // Локальная БД
  await Firebase.initializeApp( // Firebase
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.instance.init(); // Уведомления

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Делает AuthService доступным всем дочерним виджетам
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'Aid App',
        theme: AppTheme.lightTheme,
        // ...
        home: SplashScreen(), // Начальный экран
      ),
    );
  }
}
```
**Объяснение:** "В `main` мы последовательно инициализируем локальную базу, Firebase и уведомления. Затем, с помощью `MultiProvider`, мы внедряем `AuthService` в приложение, чтобы любой экран мог получить доступ к состоянию аутентификации пользователя."

---

### Шаг 3: Модель данных (`lib/models/user_model.dart`)

Покажите, как вы структурируете данные в приложении на примере модели пользователя.

**Что объяснить:**
- **Класс `User`**: Опишите поля, которые характеризуют пользователя.
- **Методы `toMap()` и `fromMap()`**: Объясните, что эти методы нужны для сериализации/десериализации объекта при его сохранении в базу данных (как в Firebase, так и в Hive).

**Ключевой фрагмент кода из `lib/models/user_model.dart`:**
```dart
class User {
  final String id;
  final String email;
  final String fullName;
  final bool isStaff; // Является ли сотрудником
  // ... другие поля

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.isStaff,
    // ...
  });

  // Превращает объект User в Map для записи в базу данных
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'isStaff': isStaff ? 1 : 0, // Храним как 0 или 1 для совместимости
      // ...
    };
  }

  // Создает объект User из Map, полученного из базы данных
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      isStaff: (map['isStaff'] ?? 0) == 1,
      // ...
    );
  }
}
```
**Объяснение:** "Класс `User` — это наша основная модель данных. Методы `toMap` и `fromMap` являются стандартной практикой для конвертации объектов в формат, который понимают базы данных вроде Firestore и Hive, и обратно."

---

### Шаг 4: Сервис аутентификации (`lib/services/auth_service.dart`)

Это мозг, отвечающий за вход, регистрацию и управление сессией пользователя.

**Что объяснить:**
- **`ChangeNotifier`**: `AuthService` наследуется от `ChangeNotifier`, что позволяет ему уведомлять UI об изменениях (например, когда пользователь вошел в систему).
- **Метод `login()`**: Разберите логику входа. Проверка почты, пароля, верификация OTP-кода, и в случае успеха — сохранение сессии и обновление состояния.
- **Взаимодействие с другими сервисами**: Покажите, как `AuthService` использует `DatabaseService` для получения данных о пользователе и `OtpService` для верификации кода.

**Ключевой фрагмент кода из `lib/services/auth_service.dart`:**
```dart
class AuthService extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  final OtpService _otpService = OtpService.instance;
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String email, String password, {required String otpCode}) async {
    try {
      // 1. Получаем пользователя по email из базы данных
      final userMap = await _db.getUserByEmail(email.trim().toLowerCase());
      if (userMap == null) {
        _lastErrorMessage = 'Пользователь не найден.';
        return false;
      }

      // 2. Проверяем хеш пароля
      final storedPassword = (userMap['passwordHash'] ?? '') as String;
      if (!SecurityUtils.verifyPassword(password, storedPassword)) {
        _lastErrorMessage = 'Неверный пароль';
        return false;
      }

      // 3. Проверяем одноразовый код из email
      final otpValid = await _otpService.verifyCode(email, otpCode);
      if (!otpValid) {
        _lastErrorMessage = 'Неверный код подтверждения.';
        return false;
      }

      // 4. Успех! Обновляем текущего пользователя и сохраняем сессию
      _currentUser = User.fromMap(userMap);
      await _persistSession(_currentUser!.id);
      
      // 5. Уведомляем UI, что состояние изменилось
      notifyListeners();
      return true;
    } catch (e) {
      _lastErrorMessage = 'Произошла ошибка';
      return false;
    }
  }
  // ... другие методы (register, logout)
}
```
**Объяснение:** "Сервис аутентификации инкапсулирует всю логику входа. Метод `login` выполняет проверку данных пользователя, включая пароль и одноразовый код. Если все верно, он обновляет `currentUser` и вызывает `notifyListeners()`, что заставляет UI перерисоваться и показать экран для авторизованного пользователя."

---

### Шаг 5: Сервис базы данных (`lib/services/database_service.dart`)

Этот сервис — единая точка доступа к данным, как удаленным (Firestore), так и локальным (Hive). Это пример паттерна "Репозиторий".

**Что объяснить:**
- **Online/Offline стратегия**: Объясните, что при запросе данных метод сначала пытается получить их из локальной быстрой базы данных (`_localDb`), а затем (или параллельно) запрашивает актуальные данные из облачной базы `_firestore` и обновляет кэш. Это обеспечивает быструю загрузку и работу без интернета.
- **Singleton**: `DatabaseService` реализован как Singleton (`_instance`), чтобы гарантировать один-единственный экземпляр сервиса на все приложение.

**Ключевой фрагмент кода из `lib/services/database_service.dart`:**
```dart
class DatabaseService {
  // --- Реализация Singleton ---
  DatabaseService._internal();
  static final DatabaseService _instance = DatabaseService._internal();
  static DatabaseService get instance => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalDatabaseService _localDb = LocalDatabaseService.instance;

  // --- Пример метода с логикой Online/Offline ---
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    
    // 1. Сначала пытаемся быстро получить из локального кэша
    final local = await _localDb.getUserByEmail(normalizedEmail);
    
    try {
      // 2. Затем идем в облачную базу за свежими данными
      final snapshot = await _firestore.collection('users')
          .where('emailLowercase', isEqualTo: normalizedEmail).limit(1).get();
          
      if (snapshot.docs.isEmpty) return local; // Если в облаке нет, возвращаем что есть локально
      
      // 3. Если данные из облака получены, обновляем локальный кэш
      final remote = _normalizeUserDoc(snapshot.docs.first);
      await _localDb.saveUser(remote);
      return remote; // Возвращаем самые свежие данные
    } catch (_) {
      // Если произошла ошибка сети, возвращаем данные из кэша
      return local;
    }
  }
}
```
**Объяснение:** "Этот сервис абстрагирует работу с данными. Например, `getUserByEmail` реализует стратегию 'cache-first, then network'. Он сначала отдает данные из локальной базы Hive для мгновенного отклика UI, а потом запрашивает свежие данные из Firestore и обновляет кэш. Это делает приложение отзывчивым и позволяет ему работать оффлайн."

---

### Шаг 6: Экран входа (`lib/screens/auth/login_screen.dart`)

Покажите, как UI (View) связывается с бизнес-логикой (ViewModel/Service).

**Что объяснить:**
- **`StatefulWidget`**: Экран является `StatefulWidget`, так как его состояние меняется (поля ввода, состояние загрузки, сообщения об ошибках).
- **`TextEditingController`**: Как получаются данные из полей ввода.
- **Вызов `AuthService`**: Покажите, как по нажатию кнопки вызывается метод `authService.login()` через `context.read<AuthService>()`.
- **Обработка результата**: Как UI реагирует на успешный или неуспешный вход (переход на другой экран или отображение ошибки).

**Ключевой фрагмент кода из `lib/screens/auth/login_screen.dart`:**
```dart
class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // ...
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true; // Показываем индикатор загрузки
      _errorMessage = null;
    });

    // Получаем доступ к AuthService через Provider
    final authService = context.read<AuthService>();
    
    // Вызываем метод логина из сервиса
    final success = await authService.login(
      _emailController.text,
      _passwordController.text,
      otpCode: _otpController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      // При успехе переходим на главный экран
      Navigator.of(context).pushReplacement(...);
    } else {
      // При ошибке показываем сообщение
      setState(() => _errorMessage = authService.lastError ?? 'Ошибка входа');
    }
    setState(() => _isLoading = false); // Скрываем индикатор загрузки
  }

  @override
  Widget build(BuildContext context) {
    // ... верстка ...
    
    // Пример кнопки, которая запускает логику
    GradientButton(
      label: 'Войти',
      onPressed: () => _handleLogin(),
      isLoading: _isLoading,
    ),
    
    // ... верстка ...
  }
}
```
**Объяснение:** "На экране входа мы используем `TextEditingController` для сбора данных. По нажатию на кнопку 'Войти' вызывается метод `_handleLogin`, который, в свою очередь, обращается к `AuthService` для выполнения всей бизнес-логики. UI не занимается логикой, он только отправляет команду и реагирует на результат, показывая загрузку, ошибку или переходя на следующий экран."

---

### Шаг 7: Переиспользуемый виджет (`lib/widgets/gradient_button.dart`)

Это пример того, как вы создаете собственные UI-компоненты для всего приложения.

**Что объяснить:**
- **Инкапсуляция**: Виджет инкапсулирует в себе всю логику отображения, анимации и состояний (обычное, нажатое, загрузка, неактивное).
- **Анимации**: Расскажите про использование `AnimationController` для создания эффекта "взрыва частиц" при нажатии. Это показывает ваше внимание к деталям и UX.
- **Параметры**: Покажите, что виджет можно кастомизировать через параметры конструктора (`label`, `onPressed`, `isLoading`).

**Ключевой фрагмент кода из `lib/widgets/gradient_button.dart`:**
```dart
class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  // ...

  const GradientButton({ ... });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> with TickerProviderStateMixin {
  late AnimationController _explosionController; // Контроллер для анимации частиц

  @override
  void initState() {
    super.initState();
    _explosionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }
  
  void _onTapUp(_) {
    // ...
    if (!widget.isLoading && widget.onPressed != null) {
       widget.onPressed!();
      _explosionController.forward(from: 0.0); // Запускаем анимацию!
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: _onTapUp,
      // ...
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Основной вид кнопки
          AnimatedContainer( ... ),
          
          // Слой с анимацией частиц
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _explosionController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ExplosionPainter(
                    progress: _explosionController.value, // Прогресс анимации
                    color: AppColors.lightGray,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```
**Объяснение:** "Я создал кастомную кнопку `GradientButton`, которую можно переиспользовать по всему приложению. Она не только отображает текст и состояние загрузки, но и содержит сложную анимацию частиц на `CustomPaint` для улучшения пользовательского опыта. Вся эта логика инкапсулирована внутри виджета."

---

### Заключение

**Кратко подведите итог:**
- **Архитектура**: "Проект построен на основе сервис-ориентированной архитектуры с разделением логики (сервисы) и представления (виджеты)."
- **Управление состоянием**: "Использовался `Provider` для внедрения зависимостей и уведомления UI об изменениях."
- **Offline-First**: "Благодаря связке `Firestore` и локальной базы `Hive`, приложение остается отзывчивым и частично функциональным даже без подключения к сети."
- **Безопасность**: "Реализована безопасная аутентификация с хешированием паролей и двухфакторной проверкой через одноразовые коды по email."
