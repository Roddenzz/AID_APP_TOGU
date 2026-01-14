import 'package:flutter/material.dart';

class AppColors {
  // Primary palette
  static const Color cyan = Color(0xFF00BFFF);
  static const Color darkViolet = Color(0xFF5E00FF);
  static const Color violet = Color(0xFF7703FE);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightViolet = Color(0xFF5360FE);
  static const Color black = Color(0xFF000000);

  // Neutral colors
  static const Color darkGray = Color(0xFF1A1A1A);
  static const Color mediumGray = Color(0xFF808080);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color border = Color(0xFFE8E8E8);

  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [cyan, lightViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient violetGradient = LinearGradient(
    colors: [darkViolet, violet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [lightViolet, darkViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
