import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/animated_particle_background.dart';
import '../widgets/app_logo.dart'; // Import the new logo
import 'auth/login_screen.dart';

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
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showContent = true;
        });
      }
    });

    // Navigate after a longer delay
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _navigateToLogin();
      }
    });
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 1000),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGray,
      body: Stack(
        children: [
          // The same particle background from the login screen
          const Positioned.fill(child: AnimatedParticleBackground()),
          
          // The animated content (icon and text)
          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 1500),
              opacity: _showContent ? 1.0 : 0.0,
              curve: Curves.easeIn,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLogo(size: 120), // Use the new AppLogo widget
                  const SizedBox(height: 24),
                  const Text(
                    'Профбюро Политех',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
