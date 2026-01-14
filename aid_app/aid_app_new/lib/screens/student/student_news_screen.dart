import 'package:flutter/material.dart';
import '../../services/news_service.dart';
import '../../models/news_model.dart';
import '../../widgets/news_card.dart';
import '../../widgets/staggered_fade_in.dart';

class StudentNewsScreen extends StatefulWidget {
  const StudentNewsScreen({Key? key}) : super(key: key);

  @override
  State<StudentNewsScreen> createState() => _StudentNewsScreenState();
}

class _StudentNewsScreenState extends State<StudentNewsScreen>
    with SingleTickerProviderStateMixin {
  final _newsService = NewsService();
  Set<String> _likedNews = {};
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Let AppShell gradient show through
      body: FutureBuilder<List<News>>(
        future: _newsService.getAllNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (snapshot.hasError) {
             return Center(child: Text('Ошибка: ${snapshot.error}', style: const TextStyle(color: Colors.white70)));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Нет новостей', style: TextStyle(color: Colors.white70, fontSize: 16)),
            );
          }
          
          // When data is ready, start the animation
          _listAnimationController.forward();

          return ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 90), // Padding to avoid navbar
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final news = snapshot.data![index];
              final isLiked = _likedNews.contains(news.id);

              return StaggeredFadeIn(
                controller: _listAnimationController,
                index: index,
                delay: 0.05,
                child: NewsCard(
                  title: news.title,
                  content: news.content,
                  authorName: news.createdBy,
                  createdDate: news.createdAt.toString().split('.')[0],
                  likes: news.likes,
                  isLiked: isLiked,
                  onLike: () {
                    // This is a mock implementation for the UI demo
                    setState(() {
                      if (isLiked) {
                        _likedNews.remove(news.id);
                      } else {
                        _likedNews.add(news.id);
                      }
                    });
                  },
                  onTap: () {
                    // TODO: Implement news detail screen navigation
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
