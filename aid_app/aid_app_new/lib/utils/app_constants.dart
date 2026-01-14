// Constants for the application
class AppConstants {
  // App info
  static const String appName = 'TOGU Aid App';
  static const String appVersion = '1.0.0';
  static const String organizationName = 'ТОГУ';
  static const String bureauName = 'Профбюро ПОЛИТЕХ';

  // Database
  static const String databaseName = 'aid_app.db';
  static const int databaseVersion = 1;

  // API
  static const String baseUrl = 'https://api.togudv.ru';
  static const int apiTimeout = 30000; // milliseconds
  static const int retryAttempts = 3;

  // Working hours
  static const String workingHoursStart = '13:30';
  static const String workingHoursEnd = '16:00';
  static const String workingDays = 'Пн-Пт';

  // Application settings
  static const int maxFileSize = 10485760; // 10 MB
  static const List<String> allowedFileTypes = [
    'pdf',
    'jpg',
    'jpeg',
    'png',
    'doc',
    'docx',
  ];

  // Aid categories
  static const Map<String, String> aidCategories = {
    'tuition': 'Обучение',
    'accommodation': 'Проживание',
    'food': 'Питание',
    'medical': 'Медицина',
    'emergency': 'Чрезвычайная ситуация',
    'other': 'Прочее',
  };

  // Aid amounts (in rubles)
  static const Map<String, double> maxAidAmount = {
    'tuition': 5000.0,
    'accommodation': 3000.0,
    'food': 2000.0,
    'medical': 10000.0,
    'emergency': 10000.0,
    'other': 1000.0,
  };

  // Contact info
  static const String contactPhone = '+7 (904) 123-45-67';
  static const String contactEmail = 'profburo@togudv.ru';
  static const String contactLocation = 'Кабинет 101, Главное здание ТОГУ';

  // Validation rules
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int studentIdLength = 10;
  static const int maxApplicationDescriptionLength = 2000;

  // Cache settings
  static const int cacheExpirationHours = 24;
  static const int maxCacheSize = 52428800; // 50 MB

  // UI settings
  static const double borderRadius = 12.0;
  static const double elevation = 4.0;
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Pagination
  static const int pageSize = 20;
  static const int maxPages = 100;

  // Notification settings
  static const int notificationCheckIntervalSeconds = 60;

  // Email domain
  static const String emailDomain = '@togudv.ru';

  // Status labels
  static const Map<String, String> statusLabels = {
    'pending': 'В ожидании',
    'inreview': 'На рассмотрении',
    'approved': 'Одобрено',
    'rejected': 'Отклонено',
  };

  // Error messages
  static const Map<String, String> errorMessages = {
    'network_error': 'Ошибка сети. Проверьте подключение.',
    'server_error': 'Ошибка сервера. Попробуйте позже.',
    'auth_error': 'Ошибка аутентификации. Проверьте данные.',
    'timeout_error': 'Время ожидания истекло.',
    'validation_error': 'Пожалуйста, проверьте введенные данные.',
    'file_error': 'Ошибка при загрузке файла.',
    'permission_error': 'Недостаточно прав доступа.',
  };

  // Success messages
  static const Map<String, String> successMessages = {
    'login_success': 'Вы успешно вошли в систему.',
    'register_success': 'Регистрация успешно завершена.',
    'application_submitted': 'Заявление успешно подано.',
    'application_updated': 'Заявление обновлено.',
    'news_created': 'Новость создана.',
    'message_sent': 'Сообщение отправлено.',
  };

  // Debug mode (change in production)
  static const bool debugMode = true;
  static const bool logNetworkRequests = true;
  static const bool logDatabaseQueries = true;
}
