import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/message_model.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/chat_bubble.dart';

class StudentChatScreen extends StatefulWidget {
  const StudentChatScreen({Key? key}) : super(key: key);

  @override
  State<StudentChatScreen> createState() => _StudentChatScreenState();
}

class _StudentChatScreenState extends State<StudentChatScreen> {
  final _chatService = ChatService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _uuid = const Uuid();
  late Stream<List<Message>> _messagesStream;
  bool _streamInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_streamInitialized) return;
    _streamInitialized = true;
    final userId = context.read<AuthService>().currentUser?.id;
    _messagesStream = userId != null ? _chatService.conversationStream(userId) : Stream.value([]);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    if (content.isEmpty || user == null) {
      return;
    }

    final newMessage = Message(
      id: _uuid.v4(),
      senderId: user.id,
      senderName: user.fullName,
      recipientId: 'staff_shared',
      content: content,
      sentAt: DateTime.now(),
      isRead: false,
      conversationId: user.id,
      conversationName: user.fullName,
    );

    _messageController.clear();
    _scrollToBottom();

    await _chatService.sendMessage(
      message: newMessage,
      conversationId: user.id,
      conversationName: user.fullName,
      isSenderStaff: false,
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserFullName = context.watch<AuthService>().currentUser?.fullName ?? 'Аноним';
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                if (snapshot.hasError) {
                  // ignore: avoid_print
                  print('Student chat stream error: ${snapshot.error}');
                }

                final currentUserId = context.read<AuthService>().currentUser?.id;
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const Center(child: Text('Сообщений пока нет', style: TextStyle(color: Colors.white70)));
                }
                return ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isUserMessage = message.senderId == currentUserId;
                    return ChatBubble(
                      message: message,
                      isUserMessage: isUserMessage,
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(currentUserFullName),
        ],
      ),
    );
  }

  Widget _buildMessageInput(String senderName) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.25),
            border: Border(top: BorderSide(color: AppColors.white.withOpacity(0.2))),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Напишите сообщение...',
                        hintStyle: TextStyle(color: AppColors.white.withOpacity(0.6)),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _sendMessage,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.cyan,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
