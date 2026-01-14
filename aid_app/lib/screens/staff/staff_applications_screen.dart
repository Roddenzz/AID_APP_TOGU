import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/application_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/application_card.dart';
import '../../models/application_model.dart';
import '../../widgets/staggered_fade_in.dart';

class StaffApplicationsScreen extends StatefulWidget {
  const StaffApplicationsScreen({Key? key}) : super(key: key);

  @override
  State<StaffApplicationsScreen> createState() => _StaffApplicationsScreenState();
}

class _StaffApplicationsScreenState extends State<StaffApplicationsScreen> with TickerProviderStateMixin {
  final _applicationService = ApplicationService();
  late Future<List<Application>> _applicationsFuture;
  late AnimationController _listAnimationController;

  String _filterStatus = 'all';
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _applicationsFuture = _applicationService.getAllApplications();
    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }
  
  void _refreshApplications() {
    setState(() {
      _applicationsFuture = _applicationService.getAllApplications();
      _listAnimationController.forward(from: 0.0);
    });
  }

  Future<void> _onApprove(String applicationId) async {
    // Placeholder for staff ID
    await _applicationService.approveApplication(applicationId, 5000, 'staff-user-id');
    _refreshApplications();
  }

  Future<void> _onReject(String applicationId) async {
    // Placeholder for staff ID
    await _applicationService.rejectApplication(applicationId, 'Отклонено', 'staff-user-id');
     _refreshApplications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: FutureBuilder<List<Application>>(
              future: _applicationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Нет заявлений', style: TextStyle(color: Colors.white70)));
                }

                _listAnimationController.forward();
                final applications = snapshot.data!.where((app) {
                  if (_filterStatus == 'all') return true;
                  return app.status.toString().split('.').last.toLowerCase() == _filterStatus;
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 90),
                  itemCount: applications.length,
                  itemBuilder: (context, index) {
                    final app = applications[index];
                    return StaggeredFadeIn(
                      controller: _listAnimationController,
                      index: index,
                      delay: 0.05,
                      child: ApplicationCard(
                        title: app.fullName,
                        subtitle: app.description,
                        status: app.status.toString().split('.').last,
                        createdDate: app.createdAt.toString().split('.')[0],
                        onExpand: () => setState(() => _expandedIndex = _expandedIndex == index ? null : index),
                        isExpanded: _expandedIndex == index,
                        amount: app.approvedAmount != null ? '₽${app.approvedAmount?.toStringAsFixed(0)}' : null,
                        category: aidCategoryTitles[app.category] ?? app.category.toString().split('.').last,
                        onApprove: () => _onApprove(app.id),
                        onReject: () => _onReject(app.id),
                        attachments: app.attachments,
                        signatureData: app.signatureData,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.black.withOpacity(0.2),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterButton('Все', 'all'),
                _buildFilterButton('В ожидании', 'pending'),
                _buildFilterButton('На рассмотрении', 'inreview'),
                _buildFilterButton('Одобрено', 'approved'),
                _buildFilterButton('Отклонено', 'rejected'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, String value) {
    final isSelected = _filterStatus == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) setState(() => _filterStatus = value);
        },
        backgroundColor: Colors.transparent,
        shape: StadiumBorder(side: BorderSide(color: AppColors.white.withOpacity(0.3))),
        selectedColor: AppColors.cyan.withOpacity(0.3),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }
}

