import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_particle_background.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/staggered_fade_in.dart';
import '../staff/staff_dashboard.dart';
import '../student/student_dashboard.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _academicGroupController = TextEditingController();
  
  late AnimationController _entryController;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _studentIdController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _academicGroupController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Пароли не совпадают');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = context.read<AuthService>();
    
    final success = await authService.register(
      _emailController.text.trim(),
      _studentIdController.text.trim(),
      _fullNameController.text.trim(),
      _phoneController.text.trim(),
      _passwordController.text,
      _academicGroupController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      final isStaff = authService.isStaff;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => isStaff ? const StaffDashboard() : const StudentDashboard(),
        ),
        (route) => false,
      );
    } else {
      setState(() => _errorMessage = 'Ошибка регистрации. Пользователь уже существует');
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
                child: StaggeredFadeIn(
                  controller: _entryController,
                  child: Column(
                    children: [
                      Text(
                        'Создание аккаунта',
                        style: textTheme.displayMedium?.copyWith(color: AppColors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Заполните все поля для начала работы',
                        style: textTheme.bodyLarge?.copyWith(color: AppColors.white.withOpacity(0.8)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      ClipRRect(
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
                            child: _buildForm(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Back button
          Positioned(
            top: 40,
            left: 16,
            child: StaggeredFadeIn(
              controller: _entryController,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _emailController, labelText: 'Email', icon: Icons.email_outlined,
          hintText: 'your.email@togudv.ru', keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _studentIdController, labelText: 'Номер студента', icon: Icons.badge_outlined,
          hintText: '2023106527', keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _fullNameController, labelText: 'ФИО', icon: Icons.person_outline,
          hintText: 'Ваше полное имя',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _academicGroupController, labelText: 'Академическая группа', icon: Icons.groups_outlined,
          hintText: '101-ИТ',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController, labelText: 'Номер телефона', icon: Icons.phone_outlined,
          hintText: '+7 (999) 123-45-67', keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController, labelText: 'Пароль', icon: Icons.lock_outline,
          hintText: '••••••••', obscureText: _obscurePassword,
          suffixIcon: _buildObscureToggle(
            () => setState(() => _obscurePassword = !_obscurePassword), _obscurePassword,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _confirmPasswordController, labelText: 'Подтверждение пароля', icon: Icons.lock_outline,
          hintText: '••••••••', obscureText: _obscureConfirmPassword,
          suffixIcon: _buildObscureToggle(
            () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword), _obscureConfirmPassword,
          ),
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
          label: 'Зарегистрироваться',
          onPressed: _handleRegister,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 16),

        Center(
          child: RichText(
            text: TextSpan(
              text: 'Уже есть аккаунт? ',
              style: TextStyle(color: AppColors.white.withOpacity(0.6), fontSize: 14),
              children: [
                TextSpan(
                  text: 'Войти',
                  style: const TextStyle(
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildObscureToggle(VoidCallback onPressed, bool isObscured) {
    return IconButton(
      icon: Icon(
        isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.white.withOpacity(0.7),
      ),
      onPressed: onPressed,
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
}
