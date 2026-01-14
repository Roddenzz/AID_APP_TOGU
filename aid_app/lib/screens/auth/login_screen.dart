import 'dart:ui';
import 'package:aid_app/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_utils.dart';
import '../../widgets/animated_particle_background.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/staggered_fade_in.dart';
import 'register_screen.dart';
import '../staff/staff_dashboard.dart';
import '../student/student_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  late AnimationController _entryController;
  
  bool _isLoading = false;
  bool _isSendingCode = false;
  bool _codeSent = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    final email = _emailController.text.trim();
    if (!_isToguEmail(email)) {
      setState(() => _errorMessage = 'Используйте корпоративную почту @togudv.ru');
      return;
    }
    setState(() {
      _isSendingCode = true;
      _errorMessage = null;
    });

    final authService = context.read<AuthService>();
    final ok = await authService.sendLoginCode(email);

    if (!mounted) return;
    setState(() {
      _isSendingCode = false;
      _codeSent = ok;
      _errorMessage = ok ? null : (authService.lastError ?? '?? ??????? ????????? ???. ????????? SMTP ?????????.');
    });
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    if (!_isToguEmail(email)) {
      setState(() => _errorMessage = 'Используйте почту с доменом @togudv.ru');
      return;
    }

    setState(() => _isLoading = true);
    _errorMessage = null;

    final authService = context.read<AuthService>();
    
    final success = await authService.login(
      email,
      _passwordController.text,
      otpCode: _otpController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      final isStaff = authService.isStaff;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => isStaff ? const StaffDashboard() : const StudentDashboard(),
        ),
      );
    } else {
      setState(() => _errorMessage = 'Неверный email или пароль');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // Layer 1: Animated Background + Solid Color
          Container(
            color: AppColors.darkGray,
          ),
          const Positioned.fill(child: AnimatedParticleBackground()),

          // Layer 2: Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  children: [
                    // Header
                    StaggeredFadeIn(
                      controller: _entryController,
                      index: 0,
                      child: Column(
                        children: [
                          const AppLogo(size: 80),
                          const SizedBox(height: 20),
                          Text(
                            'Профбюро Политех',
                            style: textTheme.displayMedium?.copyWith(color: AppColors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Подача заявлений на материальную помощь',
                            style: textTheme.bodyLarge?.copyWith(color: AppColors.white.withOpacity(0.8)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Form Card
                    StaggeredFadeIn(
                      controller: _entryController,
                      index: 1,
                      delay: 0.2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.white.withOpacity(0.2)),
                            ),
                            padding: const EdgeInsets.all(28),
                            child: _buildForm(textTheme),
                          ),
                        ),
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

  Widget _buildForm(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Вход',
          style: textTheme.headlineSmall?.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: 24),
        
        // Using a custom text field style to match the new design
        _buildTextField(
          controller: _emailController,
          hintText: 'your.email@togudv.ru',
          labelText: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        
        _buildTextField(
          controller: _passwordController,
          hintText: '••••••••',
          labelText: 'Пароль',
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppColors.white.withOpacity(0.7),
            ),
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
          ),
        ),

        const SizedBox(height: 16),
        _buildTextField(
          controller: _otpController,
          hintText: '000000',
          labelText: 'Код подтверждения из email',
          icon: Icons.verified_outlined,
          keyboardType: TextInputType.number,
        ),

        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
        const SizedBox(height: 24),

        GradientButton(
          label: _codeSent ? 'Отправить код повторно' : 'Получить код',
          onPressed: _isSendingCode ? null : () => _handleSendCode(),
          isLoading: _isSendingCode,
        ),
        const SizedBox(height: 12),

        GradientButton(
          label: 'Войти',
          onPressed: () => _handleLogin(),
          isLoading: _isLoading,
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(child: Container(height: 1, color: AppColors.white.withOpacity(0.2))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'или',
                style: TextStyle(color: AppColors.white.withOpacity(0.6), fontSize: 12),
              ),
            ),
            Expanded(child: Container(height: 1, color: AppColors.white.withOpacity(0.2))),
          ],
        ),
        const SizedBox(height: 16),
        
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            );
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            side: BorderSide(color: AppColors.white.withOpacity(0.8), width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'Создать аккаунт',
            style: TextStyle(
              color: AppColors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: Icon(icon, color: AppColors.white.withOpacity(0.7)),
        suffixIcon: suffixIcon,
        hintStyle: TextStyle(color: AppColors.white.withOpacity(0.5)),
        labelStyle: TextStyle(color: AppColors.white.withOpacity(0.9)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cyan, width: 2),
        ),
      ),
    );
  }

  bool _isToguEmail(String email) => AppUtils.isToguEmail(email);
}




