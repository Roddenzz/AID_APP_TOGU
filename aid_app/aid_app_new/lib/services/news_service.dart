import '../models/news_model.dart';
import 'database_service.dart';

class NewsService {
  final DatabaseService _db = DatabaseService.instance;

  Future<void> createNews(News news) async {
    await _db.createNews(news.toMap());
  }

  Future<List<News>> getAllNews() async {
    final maps = await _db.getAllNews();
    return maps.map((m) => News.fromMap(m)).toList();
  }

  Future<void> likeNews(String newsId, String userId) async {
    final maps = await _db.getAllNews();
    final news = maps.firstWhere((m) => m['id'] == newsId);
    final newsObj = News.fromMap(news);
    
    if (!newsObj.likedBy.contains(userId)) {
      final updatedLikedBy = [...newsObj.likedBy, userId];
      await _db.updateNews(newsId, {
        'likes': newsObj.likes + 1,
        'likedBy': updatedLikedBy.join(','),
      });
    }
  }

  Future<void> unlikeNews(String newsId, String userId) async {
    final maps = await _db.getAllNews();
    final news = maps.firstWhere((m) => m['id'] == newsId);
    final newsObj = News.fromMap(news);
    
    if (newsObj.likedBy.contains(userId)) {
      final updatedLikedBy = newsObj.likedBy.where((id) => id != userId).toList();
      await _db.updateNews(newsId, {
        'likes': newsObj.likes - 1,
        'likedBy': updatedLikedBy.join(','),
      });
    }
  }
}
