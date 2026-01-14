import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_shell.dart';
import 'student_applications_screen.dart';
import 'student_news_screen.dart';
import 'student_chat_screen.dart';
import 'student_faq_screen.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const StudentApplicationsScreen(),
      const StudentNewsScreen(),
      const StudentChatScreen(),
      const StudentFaqScreen(),
    ];

    final List<NavItem> items = [
      NavItem(label: 'Заявления', icon: Icons.assignment_outlined),
      NavItem(label: 'Новости', icon: Icons.newspaper_outlined),
      NavItem(label: 'Чат', icon: Icons.chat_bubble_outline),
      NavItem(label: 'FAQ', icon: Icons.help_outline),
    ];

    return AppShell(
      title: 'Панель студента',
      screens: screens,
      items: items,
      isStaff: false,
      onLogout: (ctx) {
        ctx.read<AuthService>().logout();
        Navigator.of(ctx).pushNamedAndRemoveUntil('/', (_) => false);
      },
    );
  }
}
