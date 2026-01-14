import '../models/message_model.dart';
import 'database_service.dart';

class ChatService {
  final DatabaseService _db = DatabaseService.instance;

  Future<void> sendMessage(Message message) async {
    await _db.createMessage(message.toMap());
  }

  Future<List<Message>> getConversation(String userId1, String userId2) async {
    final maps = await _db.getConversation(userId1, userId2);
    return maps.map((m) => Message.fromMap(m)).toList();
  }

  Future<void> markAsRead(String messageId) async {
    // This would require an update method for messages
    // For now, we'll keep messages as they are
  }
}
