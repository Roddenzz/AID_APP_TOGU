import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/application_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/staggered_fade_in.dart';

class StaffStatisticsScreen extends StatefulWidget {
  const StaffStatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StaffStatisticsScreen> createState() => _StaffStatisticsScreenState();
}

class _StaffStatisticsScreenState extends State<StaffStatisticsScreen> with SingleTickerProviderStateMixin {
  final _applicationService = ApplicationService();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
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
                'Статистика',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),

            // Stats cards
            StaggeredFadeIn(
              controller: _animationController,
              index: 1,
              child: FutureBuilder<Map<String, int>>(
                future: _applicationService.getApplicationStats(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }
                  final stats = snapshot.data!;
                  return GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStatCard('В ожидании', stats['pending'] ?? 0, AppColors.warning, Icons.pending_actions_outlined),
                      _buildStatCard('Одобрено', stats['approved'] ?? 0, AppColors.success, Icons.check_circle_outline),
                      _buildStatCard('Отклонено', stats['rejected'] ?? 0, AppColors.error, Icons.cancel_outlined),
                      _buildStatCard('На рассмотрении', stats['inReview'] ?? 0, AppColors.cyan, Icons.visibility_outlined),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Chart section
            StaggeredFadeIn(
              controller: _animationController,
              index: 2,
              child: _buildGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('График заявлений', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 300,
                      child: FutureBuilder<Map<String, int>>(
                        future: _applicationService.getApplicationStats(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.white));
                          final stats = snapshot.data!;
                          return BarChart(_buildChartData(stats));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

             const SizedBox(height: 24),

            // Total approved amount
            StaggeredFadeIn(
              controller: _animationController,
              index: 3,
              child: FutureBuilder<double>(
                future: _applicationService.getTotalApprovedAmount(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  return _buildGlassCard(
                    gradient: AppColors.primaryGradient,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Всего одобрено', style: TextStyle(color: Colors.white, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                          '₽${snapshot.data?.toStringAsFixed(0) ?? '0'}',
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, Gradient? gradient}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: gradient == null ? AppColors.white.withOpacity(0.1) : Colors.transparent,
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.white.withOpacity(0.2)),
          ),
          padding: const EdgeInsets.all(24),
          child: child,
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color, IconData icon) {
    return _buildGlassCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 16),
          Text(
            '$count',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  BarChartData _buildChartData(Map<String, int> stats) {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      barTouchData: BarTouchData(enabled: false),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              const titles = ['Ожидание', 'Одобрено', 'Отклонено'];
              if(value.toInt() >= titles.length) return const SizedBox.shrink();
              return SideTitleWidget(axisSide: meta.axisSide, space: 4, child: Text(titles[value.toInt()], style: const TextStyle(color: Colors.white70, fontSize: 12)));
            },
            reservedSize: 30,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              if (value % 2 != 0 && value != 0) return const SizedBox.shrink();
              return Text(value.toInt().toString(), style: const TextStyle(color: Colors.white70, fontSize: 10));
            }
          ),
        ),
      ),
      gridData: FlGridData(
        show: true,
        checkToShowHorizontalLine: (value) => value % 2 == 0,
        getDrawingHorizontalLine: (value) => FlLine(color: AppColors.white.withOpacity(0.1), strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      barGroups: [
        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: (stats['pending'] ?? 0).toDouble(), color: AppColors.warning, width: 20, borderRadius: BorderRadius.circular(4))]),
        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: (stats['approved'] ?? 0).toDouble(), color: AppColors.success, width: 20, borderRadius: BorderRadius.circular(4))]),
        BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: (stats['rejected'] ?? 0).toDouble(), color: AppColors.error, width: 20, borderRadius: BorderRadius.circular(4))]),
      ],
    );
  }
}
