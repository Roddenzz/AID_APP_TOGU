import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../services/news_service.dart';
import '../../models/news_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/news_card.dart';
import '../../widgets/staggered_fade_in.dart';

class StaffNewsScreen extends StatefulWidget {
  const StaffNewsScreen({Key? key}) : super(key: key);

  @override
  State<StaffNewsScreen> createState() => _StaffNewsScreenState();
}

class _StaffNewsScreenState extends State<StaffNewsScreen> with TickerProviderStateMixin {
  final _newsService = NewsService();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  late AnimationController _animationController;
  bool _isCreating = false;

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
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateNews() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Заполните все поля')));
      return;
    }

    setState(() => _isCreating = true);

    const uuid = Uuid();
    final news = News(
      id: uuid.v4(),
      title: _titleController.text,
      content: _contentController.text,
      imageUrl: _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
      createdBy: 'staff-1', // Placeholder
      createdAt: DateTime.now(),
      likedBy: [],
    );

    await _newsService.createNews(news);

    setState(() {
       _isCreating = false;
       // Re-build the future to refresh the list
    });

    _titleController.clear();
    _contentController.clear();
    _imageUrlController.clear();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Новость создана')));
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
                'Управление новостями',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),

            StaggeredFadeIn(
              controller: _animationController,
              index: 1,
              child: _buildGlassCard(
                child: Column(
                  children: [
                    _buildTextField(controller: _titleController, labelText: 'Название новости'),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _contentController, labelText: 'Содержание', maxLines: 5),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _imageUrlController, labelText: 'URL изображения (опционально)'),
                    const SizedBox(height: 24),
                    GradientButton(
                      label: 'Создать новость',
                      onPressed: _handleCreateNews,
                      isLoading: _isCreating,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            StaggeredFadeIn(
              controller: _animationController,
              index: 2,
              child: Text('Предпросмотр', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
            ),
            const SizedBox(height: 16),

            StaggeredFadeIn(
              controller: _animationController,
              index: 3,
              child: FutureBuilder<List<News>>(
                future: _newsService.getAllNews(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Нет новостей для предпросмотра', style: TextStyle(color: Colors.white70)));
                  }
                  final latestNews = snapshot.data!.first;
                  return NewsCard(
                    title: latestNews.title,
                    content: latestNews.content,
                    authorName: latestNews.createdBy,
                    createdDate: latestNews.createdAt.toString().split('.')[0],
                    likes: latestNews.likes,
                    isLiked: false, // Staff view doesn't need like state
                    onLike: () {},
                    onTap: () {},
                  );
                },
              ),
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
  
  Widget _buildTextField({required TextEditingController controller, required String labelText, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        labelText: labelText,
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
