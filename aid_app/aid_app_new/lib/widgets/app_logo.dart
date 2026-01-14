import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({Key? key, this.size = 100}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _LogoPainter(),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(center: center, width: size.width, height: size.height);

    // Shield outline
    final shieldPath = Path();
    shieldPath.moveTo(size.width * 0.5, 0); // Top center
    shieldPath.cubicTo(
      size.width * 0.1, size.height * 0.1, // Control point 1
      0, size.height * 0.4,             // Control point 2
      0, size.height * 0.6              // Left curve end
    );
    shieldPath.lineTo(0, size.height * 0.85);
    shieldPath.quadraticBezierTo(
      size.width * 0.5, size.height * 1.1, // Control point for bottom
      size.width, size.height * 0.85
    );
    shieldPath.lineTo(size.width, size.height * 0.6);
    shieldPath.cubicTo(
      size.width, size.height * 0.4,     // Control point 1
      size.width * 0.9, size.height * 0.1, // Control point 2
      size.width * 0.5, 0                 // Top center
    );
    shieldPath.close();

    final shieldPaint = Paint()
      ..shader = AppColors.primaryGradient.createShader(rect)
      ..style = PaintingStyle.fill;
    
    final shieldBorderPaint = Paint()
      ..color = AppColors.cyan.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawPath(shieldPath, shieldPaint);
    canvas.drawPath(shieldPath, shieldBorderPaint);

    // Gear inside
    final gearRadius = size.width * 0.28;
    final gearTeeth = 6;
    final toothHeight = gearRadius * 0.3;
    final gearPath = Path();

    for (int i = 0; i < gearTeeth; i++) {
      final angle = (i / gearTeeth) * 2 * pi;
      final nextAngle = ((i + 0.5) / gearTeeth) * 2 * pi;
      final endAngle = ((i + 1) / gearTeeth) * 2 * pi;

      // Outer edge of tooth
      gearPath.arcTo(
        Rect.fromCircle(center: center, radius: gearRadius + toothHeight),
        angle,
        (nextAngle - angle),
        false
      );

      // Inner edge of tooth
      gearPath.arcTo(
        Rect.fromCircle(center: center, radius: gearRadius),
        nextAngle,
        (endAngle - nextAngle),
        false
      );
    }
    gearPath.close();
    
    final gearPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    canvas.drawPath(gearPath, gearPaint);

    // Inner circle of gear
    canvas.drawCircle(center, gearRadius * 0.6, shieldPaint);
    canvas.drawCircle(center, gearRadius * 0.6, Paint()..color = Colors.white.withOpacity(0.5)..style=PaintingStyle.stroke..strokeWidth = 2);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
