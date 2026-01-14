/// Utility functions for the application
import 'package:intl/intl.dart';

class AppUtils {
  // Format date to readable string
  static String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }

  // Format date for display
  static String formatDateOnly(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  // Validate email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegex.hasMatch(email);
  }

  // Validate phone
  static bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\+?7\d{10}$');
    return phoneRegex.hasMatch(phone);
  }

  // Format phone number
  static String formatPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 11) {
      return '+${cleaned[0]} (${cleaned.substring(1, 4)}) ${cleaned.substring(4, 7)}-${cleaned.substring(7, 9)}-${cleaned.substring(9, 11)}';
    }
    return phone;
  }

  // Get application status color
  static String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Одобрено';
      case 'rejected':
        return 'Отклонено';
      case 'inreview':
        return 'На рассмотрении';
      case 'pending':
        return 'В ожидании';
      default:
        return status;
    }
  }

  // Get aid category label
  static String getCategoryLabel(String category) {
    switch (category.toLowerCase()) {
      case 'tuition':
        return 'Обучение';
      case 'accommodation':
        return 'Проживание';
      case 'food':
        return 'Питание';
      case 'medical':
        return 'Медицина';
      case 'emergency':
        return 'Чрезвычайная ситуация';
      case 'other':
        return 'Прочее';
      default:
        return category;
    }
  }

  // Format currency
  static String formatCurrency(double amount) {
    return '₽${amount.toStringAsFixed(0)}';
  }

  // Validate student ID
  static bool isValidStudentId(String id) {
    return id.length == 10 && int.tryParse(id) != null;
  }

  // Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Доброе утро';
    } else if (hour < 18) {
      return 'Добрый день';
    } else {
      return 'Добрый вечер';
    }
  }

  // Check if application is urgent
  static bool isUrgent(DateTime createdDate) {
    final daysDifference = DateTime.now().difference(createdDate).inDays;
    return daysDifference > 7;
  }

  // Get remaining days for application review
  static int getRemainingDays(DateTime createdDate) {
    const reviewDays = 5;
    final daysElapsed = DateTime.now().difference(createdDate).inDays;
    return reviewDays - daysElapsed;
  }

  // Validate password strength
  static int getPasswordStrength(String password) {
    int strength = 0;
    
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    
    return strength;
  }

  // Get password strength label
  static String getPasswordStrengthLabel(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Слабый';
      case 2:
      case 3:
        return 'Средний';
      case 4:
      case 5:
        return 'Сильный';
      default:
        return 'Очень сильный';
    }
  }

  // Truncate text
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Generate unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Check if user is staff
  static bool isStaffEmail(String email) {
    return email.contains('@togudv.ru');
  }
}
