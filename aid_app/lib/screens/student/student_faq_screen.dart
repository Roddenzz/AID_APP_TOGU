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

  final List<Map<String, String>> _faqItems = [
    {
      'question': 'Когда и где принимают заявления на материальную поддержку?',
      'answer':
          'Понедельник–пятница: 11:00–13:30 в центральном кабинете ППОС ТОГУ и 13:30–16:00 в кабинетах профбюро. Рабочий кабинет: 15л в главном здании ТОГУ.'
    },
    {
      'question': 'Какие сроки подачи заявлений по месяцам?',
      'answer':
          'Август–5 сентября (на сентябрь); 6–25 сентября (на октябрь); 26 сентября–25 октября (на ноябрь); 26 октября–25 ноября (на декабрь); 26 ноября–25 января (на февраль); 26 января–25 февраля (на март); 26 февраля–25 марта (на апрель); 26 марта–25 апреля (на май); 26 апреля–25 мая (на июнь). В январе, июле и августе выплаты не производятся.'
    },
    {
      'question': 'Сколько оснований для получения материальной поддержки?',
      'answer':
          '14 оснований: 1) особо нуждающиеся; 2) участники СВО; 3) воспитание детей до 14 лет; 4) проезд домой; 5) регистрация брака; 6) рождение ребенка; 7) ранний учет беременности; 8) лечение/медикаменты/оздоровление; 9) чрезвычайные обстоятельства; 10) смерть близкого родственника; 11) родители-пенсионеры; 12) хронические заболевания на диспансерном учете; 13) неполная семья; 14) тяжелое материальное положение (иные обстоятельства).'
    },
    {
      'question': 'Можно ли подать несколько заявлений?',
      'answer': 'По протоколу можно получить поддержку только по одному основанию в месяц.'
    },
    {
      'question': 'Какие документы нужны?',
      'answer':
          'Обязательно приложите документы по своему основанию (справки, свидетельства, билеты, чеки, меддокументы и т.п.). Для сложных оснований (лечение, чрезвычайные обстоятельства) подготовьте подтверждение расходов.'
    },
    {
      'question': 'Правила поведения в кабинетах ППОС ТОГУ',
      'answer':
          'Запрещено: никотин и алкоголь, еда с резким запахом, нецензурная лексика, оскорбления, азартные игры. Поддерживайте тишину, общайтесь вежливо, выбирайте комфортный формат «ты/вы» по обращению студента.'
    },
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
    return _buildGlassCard(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _faqItems.length,
        separatorBuilder: (_, __) => Divider(color: AppColors.white.withOpacity(0.15), height: 1),
        itemBuilder: (context, index) {
          final item = _faqItems[index];
          return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              title: Text(
                item['question']!,
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
              ),
              iconColor: AppColors.cyan,
              collapsedIconColor: Colors.white,
              collapsedTextColor: Colors.white,
              textColor: AppColors.cyan,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item['answer']!,
                    style: TextStyle(color: Colors.white.withOpacity(0.85), height: 1.5),
                  ),
                ),
              ],
            ),
          );
        },
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
          _buildWorkingHour('Пн–Пт', '11:00–13:30 (центр ППОС), 13:30–16:00 (кабинеты профбюро)'),
          const Divider(height: 24, color: AppColors.lightGray),
          _buildWorkingHour('Сб–Вс', 'Выходной'),
        ],
      ),
    );
  }

  Widget _buildWorkingHour(String day, String hours) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(day, style: TextStyle(fontSize: 14, color: AppColors.white.withOpacity(0.8)))),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Text(hours, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
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
          _buildContactRow(Icons.location_on_outlined, 'Кабинет 15л, Главное здание ТОГУ'),
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
        Icon(icon, color: AppColors.cyan),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14))),
      ],
    );
  }
}
