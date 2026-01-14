import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../services/application_service.dart';
import '../../services/auth_service.dart';
import '../../models/application_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/staggered_fade_in.dart';

class StudentApplicationsScreen extends StatefulWidget {
  const StudentApplicationsScreen({Key? key}) : super(key: key);

  @override
  State<StudentApplicationsScreen> createState() =>
      _StudentApplicationsScreenState();
}

class _StudentApplicationsScreenState extends State<StudentApplicationsScreen> with TickerProviderStateMixin {
  final _applicationService = ApplicationService();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  
  late AnimationController _listAnimationController;

  List<String> _attachmentPaths = [];
  AidCategory _selectedCategory = AidCategory.other;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().currentUser;
    if (user?.phone != null) {
      _phoneController.text = user!.phone!;
    }
     _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _phoneController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        _attachmentPaths.addAll(result.paths.where((path) => path != null).map((path) => path!));
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachmentPaths.removeAt(index);
    });
  }

  Future<void> _handleSubmitApplication() async {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    if (user == null || _descriptionController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    const uuid = Uuid();
    final application = Application(
      id: uuid.v4(),
      userId: user.id,
      fullName: user.fullName,
      academicGroup: user.academicGroup ?? '',
      phone: _phoneController.text,
      category: _selectedCategory,
      description: _descriptionController.text,
      status: ApplicationStatus.pending,
      createdAt: DateTime.now(),
      attachments: _attachmentPaths,
    );

    await _applicationService.submitApplication(application);

    setState(() {
      _isSubmitting = false;
      _descriptionController.clear();
      _attachmentPaths.clear();
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Заявление подано успешно')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Подать заявление',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 24),
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Категория помощи'),
                  const SizedBox(height: 12),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 24),

                  _buildReadOnlyInfo('ФИО', user?.fullName ?? 'Неизвестно'),
                  const SizedBox(height: 16),
                  _buildReadOnlyInfo('Академическая группа', user?.academicGroup ?? 'Неизвестно'),
                  const SizedBox(height: 16),

                  _buildSectionTitle('Номер телефона'),
                  const SizedBox(height: 8),
                  _buildTextField(controller: _phoneController, hintText: '+7 (999) 123-45-67', keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),

                  _buildSectionTitle('Описание заявления'),
                  const SizedBox(height: 8),
                  _buildTextField(controller: _descriptionController, hintText: 'Опишите причину для получения помощи', maxLines: 5),
                  const SizedBox(height: 16),

                  _buildAttachmentSection(),
                  const SizedBox(height: 24),

                  GradientButton(
                    label: 'Подать заявление',
                    onPressed: _handleSubmitApplication,
                    isLoading: _isSubmitting,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            Text('Мои заявления', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
            const SizedBox(height: 16),

            FutureBuilder<List<Application>>(
              future: user != null ? _applicationService.getApplicationsByUserId(user.id) : Future.value([]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Нет заявлений', style: TextStyle(color: Colors.white70)));
                }
                _listAnimationController.forward();
                return Column(
                  children: snapshot.data!.asMap().entries.map((entry) {
                     return StaggeredFadeIn(
                      controller: _listAnimationController,
                      index: entry.key,
                      delay: 0.1,
                      child: _buildApplicationItem(entry.value),
                     );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
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
          padding: const EdgeInsets.all(24),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.lightGray),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white.withOpacity(0.3))
      ),
      child: DropdownButton<AidCategory>(
        value: _selectedCategory,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        dropdownColor: AppColors.darkGray,
        onChanged: (value) {
          if (value != null) setState(() => _selectedCategory = value);
        },
        items: AidCategory.values.map((cat) => DropdownMenuItem(
          value: cat,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(cat.toString().split('.').last, style: const TextStyle(color: Colors.white)),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildReadOnlyInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Text(value, style: const TextStyle(color: AppColors.lightGray, fontSize: 14)),
        ),
      ],
    );
  }

   Widget _buildTextField({required TextEditingController controller, required String hintText, int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.white.withOpacity(0.5)),
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

  Widget _buildAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _pickFiles,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                const Icon(Icons.attach_file, color: AppColors.cyan),
                const SizedBox(width: 8),
                Text(
                  'Прикрепить документы',
                  style: TextStyle(color: AppColors.cyan, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        ..._attachmentPaths.asMap().entries.map((entry) {
          final index = entry.key;
          final path = entry.value;
          return Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_outlined, color: AppColors.cyan, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(path.split('/').last, style: const TextStyle(color: AppColors.lightGray, fontSize: 13), overflow: TextOverflow.ellipsis)),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.mediumGray, size: 18),
                  onPressed: () => _removeAttachment(index),
                )
              ],
            ),
          );
        })
      ],
    );
  }

  Widget _buildApplicationItem(Application app) {
    // ... (This part can be redesigned later if needed, focusing on the form first)
    // For now, just putting it in a glass card.
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: _buildGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(app.description, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white), overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(app.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      app.status.toString().split('.').last,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _getStatusColor(app.status)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                app.createdAt.toString().split('.')[0],
                style: const TextStyle(fontSize: 12, color: AppColors.mediumGray),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.approved: return AppColors.success;
      case ApplicationStatus.rejected: return AppColors.error;
      case ApplicationStatus.inReview: return AppColors.warning;
      default: return AppColors.lightViolet;
    }
  }
}
