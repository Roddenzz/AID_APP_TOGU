import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../widgets/animated_particle_background.dart';
import '../widgets/app_logo.dart';
import 'auth/login_screen.dart';
import 'staff/staff_dashboard.dart';
import 'student/student_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    // Start animation trigger
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _showContent = true;
        });
      }
    });

    // Navigate after a longer delay
    Future.delayed(const Duration(milliseconds: 2500), () async {
      if (!mounted) return;
      await context.read<AuthService>().restorationDone;
      _navigateToNext();
    });
  }

  void _navigateToNext() {
    final authService = context.read<AuthService>();
    final destination = authService.isAuthenticated
        ? (authService.isStaff ? const StaffDashboard() : const StudentDashboard())
        : const LoginScreen();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionDuration: const Duration(milliseconds: 450),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient backdrop with soft blobs
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D61FF),
                  Color(0xFF7A1FFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -size.height * 0.15,
            left: -size.width * 0.2,
            child: _GlowBlob(
              diameter: size.width * 0.7,
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.1,
            right: -size.width * 0.15,
            child: _GlowBlob(
              diameter: size.width * 0.55,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          const Positioned.fill(child: AnimatedParticleBackground()),

          // Logo + title
          Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            opacity: _showContent ? 1 : 0,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              scale: _showContent ? 1 : 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: const AppLogo(size: 112),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Профбюро Политех',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Матпомощь студентам и сотрудникам Тогу',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 0.2,
                        ),
                  ),
                ],
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final double diameter;
  final Color color;

  const _GlowBlob({
    required this.diameter,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0.01),
          ],
        ),
      ),
    );
  }
}
