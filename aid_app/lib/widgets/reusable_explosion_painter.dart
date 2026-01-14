import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ExplosionPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Paint _paint = Paint();
  final Random _random = Random(123); // Seeded for consistency
  final int numParticles = 25;

  ExplosionPainter({required this.progress, this.color = AppColors.error});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0.0 || progress == 1.0) return;
    
    double easedProgress = Curves.easeOut.transform(progress);

    for (int i = 0; i < numParticles; i++) {
      final double angle = _random.nextDouble() * 2 * pi;
      final double speed = _random.nextDouble() * 50 + 20;
      final double distance = speed * easedProgress;
      final double opacity = 1.0 - easedProgress;

      final double dx = cos(angle) * distance;
      final double dy = sin(angle) * distance;
      
      _paint.color = color.withOpacity(opacity);
      canvas.drawCircle(Offset(dx, dy), _random.nextDouble() * 2.5 + 1, _paint);
    }
  }

  @override
  bool shouldRepaint(covariant ExplosionPainter oldDelegate) => 
      progress != oldDelegate.progress || color != oldDelegate.color;
}
