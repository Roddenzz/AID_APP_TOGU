import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/chat_service.dart';
import '../../utils/app_colors.dart';
import '../shared/conversation_screen.dart';

class StaffChatScreen extends StatefulWidget {
  const StaffChatScreen({Key? key}) : super(key: key);

  @override
  State<StaffChatScreen> createState() => _StaffChatScreenState();
}

class _StaffChatScreenState extends State<StaffChatScreen> {
  final _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _chatService.staffConversationSummaries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}', style: const TextStyle(color: Colors.white70)));
          }
          final conversations = snapshot.data ?? [];
          if (conversations.isEmpty) {
            return const Center(
              child: Text(
                'Пока нет диалогов со студентами',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final item = conversations[index];
              return _buildChatItem(
                context,
                item['partnerName'] as String? ?? 'Студент',
                item['partnerId'] as String? ?? '',
                item['lastMessage'] as String? ?? '',
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, String name, String studentId, String lastMessage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.white.withOpacity(0.2)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient.colors,
                    begin: AppColors.primaryGradient.begin,
                    end: AppColors.primaryGradient.end,
                    stops: const [0.3, 1.0],
                  ),
                ),
                child: const Icon(Icons.person_outline, color: AppColors.white),
              ),
              title: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              subtitle: Text(
                lastMessage.isEmpty ? 'Новое обращение' : lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70),
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ConversationScreen(
                    recipientId: studentId,
                    recipientName: name,
                  ),
                ));
              },
            ),
          ),
        ),
      ),
    );
  }
}
