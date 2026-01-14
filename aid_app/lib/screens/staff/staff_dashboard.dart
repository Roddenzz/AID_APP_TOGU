import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_shell.dart';
import 'staff_applications_screen.dart';
import 'staff_statistics_screen.dart';
import 'staff_news_screen.dart';
import 'staff_chat_screen.dart';

class StaffDashboard extends StatelessWidget {
  const StaffDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const StaffApplicationsScreen(),
      const StaffStatisticsScreen(),
      const StaffNewsScreen(),
      const StaffChatScreen(),
    ];

    final List<NavItem> items = [
      NavItem(label: 'Заявления', icon: Icons.assignment_ind_outlined),
      NavItem(label: 'Статистика', icon: Icons.bar_chart_outlined),
      NavItem(label: 'Новости', icon: Icons.newspaper_outlined),
      NavItem(label: 'Чаты', icon: Icons.chat_bubble_outline),
    ];

    return AppShell(
      title: 'Панель сотрудника',
      screens: screens,
      items: items,
      isStaff: true,
      onLogout: (ctx) {
        ctx.read<AuthService>().logout();
        Navigator.of(ctx).pushNamedAndRemoveUntil('/', (_) => false);
      },
    );
  }
}
