// Constants for the application
class AppConstants {
  // App info
  static const String appName = 'TOGU Aid App';
  static const String appVersion = '1.0.0';
  static const String organizationName = 'ТОГУ';
  static const String bureauName = 'Профбюро ПОЛИТЕХ';

  // Database (Firestore collections)
  static const String databaseName = 'firebase_firestore';
  static const int databaseVersion = 1;

  // API
  static const String baseUrl = 'https://api.togudv.ru';
  static const int apiTimeout = 30000; // milliseconds
  static const int retryAttempts = 3;

  // Working hours
  static const String workingHoursStart = '11:00';
  static const String workingHoursEnd = '16:00';
  static const String workingDays = 'Пн-Пт';

  // Application settings
  static const int maxFileSize = 10485760; // 10 MB
  static const List<String> allowedFileTypes = ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'];

  // Aid categories (matching AidCategory enum codes)
  static const Map<String, String> aidCategories = {
    'categoryNeedy': 'Категория особо нуждающихся',
    'svoParticipant': 'Участники СВО/боевых действий',
    'parentingChildUnder14': 'Обучающиеся с детьми до 14 лет',
    'travelHome': 'Расходы на проезд к месту жительства',
    'marriageRegistration': 'Регистрация брака',
    'childBirth': 'Рождение ребенка',
    'earlyPregnancyRegistration': 'Ранний учет беременности',
    'medicalExpenses': 'Затраты на лечение/оздоровление',
    'emergencyCircumstances': 'Чрезвычайные обстоятельства',
    'relativeDeath': 'Смерть близкого родственника',
    'pensionerParents': 'Родители-пенсионеры',
    'chronicCondition': 'Хронические заболевания (диспансерный учет)',
    'singleParentFamily': 'Неполная семья',
    'otherHardship': 'Тяжелое материальное положение (иные обстоятельства)',
    'other': 'Другое',
  };

  // Aid amounts (indicative, in rubles)
  static const Map<String, double> maxAidAmount = {
    'categoryNeedy': 11135.0,
    'svoParticipant': 11135.0,
    'parentingChildUnder14': 11135.0,
    'travelHome': 11135.0,
    'marriageRegistration': 6681.0,
    'childBirth': 11135.0,
    'earlyPregnancyRegistration': 11135.0,
    'medicalExpenses': 22270.0,
    'emergencyCircumstances': 22270.0,
    'relativeDeath': 11135.0,
    'pensionerParents': 6681.0,
    'chronicCondition': 6681.0,
    'singleParentFamily': 6681.0,
    'otherHardship': 11135.0,
    'other': 2227.0,
  };

  // Contact info
  static const String contactPhone = '+7 (904) 123-45-67';
  static const String contactEmail = 'profburo@togudv.ru';
  static const String contactLocation = 'Кабинет 15л, Главное здание ТОГУ';

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
