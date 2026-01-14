import 'dart:ui';
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/staggered_fade_in.dart';

class StudentFaqScreen extends StatefulWidget {
  const StudentFaqScreen({Key? key}) : super(key: key);

  @override
  State<StudentFaqScreen> createState() => _StudentFaqScreenState();
}

class _StudentFaqScreenState extends State<StudentFaqScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _expandedIndex = -1;

  final List<Map<String, String>> _faqItems = [
    {'question': 'Какие документы нужны для подачи заявления?', 'answer': 'Для подачи заявления необходимо иметь студенческий билет и документы подтверждающие причину для получения помощи.'},
    {'question': 'Когда можно подавать заявление на материальную помощь?', 'answer': 'Заявления принимаются с 13:30 до 16:00 по будним дням.'},
    {'question': 'Какой максимальный размер помощи?', 'answer': 'Размер помощи зависит от категории и варьируется от 1000 до 10000 рублей.'},
    {'question': 'Как долго рассматривается заявление?', 'answer': 'Заявления обычно рассматриваются в течение 3-5 рабочих дней.'},
    {'question': 'Как узнать статус своего заявления?', 'answer': 'Статус заявления можно узнать в приложении в разделе "Мои заявления".'},
  ];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StaggeredFadeIn(
              controller: _animationController,
              index: 0,
              child: Text(
                'Часто задаваемые вопросы',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            StaggeredFadeIn(
              controller: _animationController,
              index: 1,
              child: _buildExpansionList(),
            ),
            const SizedBox(height: 24),
            StaggeredFadeIn(
              controller: _animationController,
              index: 2,
              child: _buildWorkingHoursCard(),
            ),
            const SizedBox(height: 24),
            StaggeredFadeIn(
              controller: _animationController,
              index: 3,
              child: _buildContactsCard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.white.withOpacity(0.2)),
          ),
          padding: padding ?? const EdgeInsets.all(24),
          child: child,
        ),
      ),
    );
  }

  Widget _buildExpansionList() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
           decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.white.withOpacity(0.2)),
          ),
          child: ExpansionPanelList(
            elevation: 0,
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                _expandedIndex = isExpanded ? -1 : index;
              });
            },
            dividerColor: AppColors.white.withOpacity(0.2),
            expandedHeaderPadding: const EdgeInsets.symmetric(vertical: 8),
            materialGapSize: 0,
            children: _faqItems.asMap().entries.map<ExpansionPanel>((entry) {
              int index = entry.key;
              Map<String, String> item = entry.value;
              return ExpansionPanel(
                backgroundColor: Colors.transparent,
                canTapOnHeader: true,
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return ListTile(
                    title: Text(
                      item['question']!,
                      style: TextStyle(
                        color: _expandedIndex == index ? AppColors.cyan : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
                body: ListTile(
                  title: Text(
                    item['answer']!,
                    style: TextStyle(color: Colors.white.withOpacity(0.8), height: 1.5),
                  ),
                ),
                isExpanded: _expandedIndex == index,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkingHoursCard() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Часы работы',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          _buildWorkingHour('Пн-Пт', '13:30 - 16:00'),
          const Divider(height: 24, color: AppColors.lightGray),
          _buildWorkingHour('Сб-Вс', 'Выходной'),
        ],
      ),
    );
  }
  
  Widget _buildWorkingHour(String day, String hours) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day, style: TextStyle(fontSize: 14, color: AppColors.white.withOpacity(0.8))),
        Text(hours, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildContactsCard() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Контакты',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 24),
          _buildContactRow(Icons.location_on_outlined, 'Кабинет 101, Главное здание ТОГУ'),
          const SizedBox(height: 16),
          _buildContactRow(Icons.phone_outlined, '+7 (904) 123-45-67'),
          const SizedBox(height: 16),
          _buildContactRow(Icons.email_outlined, 'profburo@togudv.ru'),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.cyan, size: 20),
        const SizedBox(width: 16),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.white))),
      ],
    );
  }
}
