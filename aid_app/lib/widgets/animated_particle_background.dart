import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedParticleBackground extends StatefulWidget {
  final int particleCount;
  final Color particleBaseColor;

  const AnimatedParticleBackground({
    Key? key,
    this.particleCount = 70,
    this.particleBaseColor = Colors.white,
  }) : super(key: key);

  @override
  State<AnimatedParticleBackground> createState() =>
      _AnimatedParticleBackgroundState();
}

class _AnimatedParticleBackgroundState extends State<AnimatedParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initParticles(MediaQuery.of(context).size);
      _controller.repeat();
    });
  }

  void _initParticles(Size size) {
    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(
        _Particle(
          areaSize: size,
          random: _random,
          baseColor: widget.particleBaseColor,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ParticlePainter(particles: _particles, controller: _controller),
    );
  }
}

class _Particle {
  final Size areaSize;
  final Random random;
  final Color baseColor;
  late double x, y;
  late double vx, vy;
  late double radius;
  late Color color;

  _Particle({required this.areaSize, required this.random, required this.baseColor}) {
    radius = random.nextDouble() * 1.5 + 0.5;
    x = random.nextDouble() * areaSize.width;
    y = random.nextDouble() * areaSize.height;
    vx = random.nextDouble() * 0.2 - 0.1;
    vy = random.nextDouble() * 0.2 - 0.1;
    color = baseColor.withOpacity(random.nextDouble() * 0.3 + 0.1);
  }

  void update() {
    x += vx;
    y += vy;

    if (x < 0) x = areaSize.width;
    if (x > areaSize.width) x = 0;
    if (y < 0) y = areaSize.height;
    if (y > areaSize.height) y = 0;
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Animation<double> controller;
  final Paint _paint = Paint();

  _ParticlePainter({required this.particles, required this.controller})
      : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.update();
      _paint.color = particle.color;
      canvas.drawCircle(Offset(particle.x, particle.y), particle.radius, _paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => false;
}
