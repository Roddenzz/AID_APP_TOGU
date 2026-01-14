import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_utils.dart';
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
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _academicGroupController = TextEditingController();
  final _staffPasswordController = TextEditingController();
  final _otpController = TextEditingController();
  
  late AnimationController _entryController;

  bool _isLoading = false;
  bool _isSendingCode = false;
  bool _codeSent = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _obscureStaffPassword = true;
  bool _isStaff = false;
  String? _errorMessage;
  static const _staffSecret = 'ZIGAZAGA';

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
    _fullNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _academicGroupController.dispose();
    _staffPasswordController.dispose();
    _otpController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    final email = _emailController.text.trim();
    final fullName = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();
    final group = _academicGroupController.text.trim();

    if (!AppUtils.isToguEmail(email)) {
      setState(() => _errorMessage = "Используйте почту в домене @togudv.ru");
      return;
    }
    if (!AppUtils.isValidFullName(fullName)) {
      setState(() => _errorMessage = "Введите полное имя (ФИО полностью)");
      return;
    }
    if (!AppUtils.isValidPhone(phone)) {
      setState(() => _errorMessage = "Введите номер в формате +7...");
      return;
    }
    if (!_isStaff && !AppUtils.isValidAcademicGroup(group)) {
      setState(() => _errorMessage = "Введите корректную академическую группу");
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = "Пароли не совпадают");
      return;
    }
    if (_isStaff && _staffPasswordController.text.trim() != _staffSecret) {
      setState(() => _errorMessage = "Неверный специальный пароль для сотрудников");
      return;
    }

    setState(() {
      _isSendingCode = true;
      _errorMessage = null;
    });

    final authService = context.read<AuthService>();
    final success = await authService.sendRegistrationCode(
      email: email,
      fullName: fullName,
      phone: phone,
      password: _passwordController.text,
      academicGroup: group,
      isStaff: _isStaff,
    );

    if (!mounted) return;

    setState(() {
      _isSendingCode = false;
      if (success) {
        _codeSent = true;
        _errorMessage = null;
      } else {
        _errorMessage = authService.lastError ?? 'Не удалось отправить код.';
      }
    });
  }

  Future<void> _handleRegister() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = context.read<AuthService>();

    try {
      final success = await authService.completeRegistration(
        otpCode: _otpController.text.trim(),
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
        setState(() => _errorMessage = authService.lastError ?? "Ошибка регистрации. Попробуйте позже");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = "Не удалось завершить регистрацию. ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                        'Регистрация',
                        style: textTheme.displayMedium?.copyWith(color: AppColors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _codeSent ? 'Введите код из письма' : 'Заполните данные, чтобы продолжить',
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
                onPressed: () {
                  if (_codeSent) {
                    setState(() => _codeSent = false);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

    Widget _buildForm() {
    final textTheme = Theme.of(context).textTheme;
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      crossFadeState: _codeSent ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: _buildRegistrationFields(textTheme),
      secondChild: _buildOtpFields(textTheme),
    );
  }

  Widget _buildRegistrationFields(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _emailController,
          labelText: 'Email',
          icon: Icons.email_outlined,
          hintText: 'your.email@togudv.ru',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildRoleSelector(textTheme),
        const SizedBox(height: 12),
        if (_isStaff) ...[
          _buildTextField(
            controller: _staffPasswordController,
            labelText: 'Пароль для сотрудников',
            icon: Icons.shield_outlined,
            hintText: 'Введите служебный код',
            obscureText: _obscureStaffPassword,
            suffixIcon: _buildObscureToggle(
              () => setState(() => _obscureStaffPassword = !_obscureStaffPassword),
              _obscureStaffPassword,
            ),
          ),
          const SizedBox(height: 16),
        ],
        _buildTextField(
          controller: _fullNameController,
          labelText: 'ФИО',
          icon: Icons.person_outline,
          hintText: 'Иванов Иван Иванович',
        ),
        const SizedBox(height: 16),
        if (!_isStaff) ... [
          _buildTextField(
            controller: _academicGroupController,
            labelText: 'Академическая группа',
            icon: Icons.groups_outlined,
            hintText: '101-АБ',
          ),
          const SizedBox(height: 16),
        ],
        _buildTextField(
          controller: _phoneController,
          labelText: 'Номер телефона',
          icon: Icons.phone_outlined,
          hintText: '+7 (999) 123-45-67',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          labelText: 'Пароль',
          icon: Icons.lock_outline,
          hintText: '********',
          obscureText: _obscurePassword,
          suffixIcon: _buildObscureToggle(
            () => setState(() => _obscurePassword = !_obscurePassword),
            _obscurePassword,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _confirmPasswordController,
          labelText: 'Повторите пароль',
          icon: Icons.lock_outline,
          hintText: '********',
          obscureText: _obscureConfirmPassword,
          suffixIcon: _buildObscureToggle(
            () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            _obscureConfirmPassword,
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
          label: 'Получить код',
          onPressed: _handleSendCode,
          isLoading: _isSendingCode,
        ),
        const SizedBox(height: 16),

        _buildLoginLink(),
      ],
    );
  }

  Widget _buildOtpFields(TextTheme textTheme) {
    return Column(
      children: [
        Text(
          'Код отправлен на ${_emailController.text}',
          style: TextStyle(color: AppColors.white.withOpacity(0.8)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _otpController,
          labelText: 'Код подтверждения',
          hintText: '123456',
          icon: Icons.password,
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
          label: 'Зарегистрироваться',
          onPressed: _handleRegister,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => _codeSent = false),
          child: const Text(
            'Изменить данные',
            style: TextStyle(color: AppColors.cyan),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Center(
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
    );
  }

  Widget _buildRoleSelector(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Кто вы?',
          style: textTheme.titleMedium?.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildRoleChip(label: 'Студент', selected: !_isStaff, onTap: () => setState(() => _isStaff = false)),
            _buildRoleChip(label: 'Сотрудник', selected: _isStaff, onTap: () => setState(() => _isStaff = true)),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleChip({required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.cyan.withOpacity(0.2) : AppColors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.cyan : AppColors.white.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? AppColors.cyan : Colors.white70,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.white,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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



