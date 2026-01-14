import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/message_model.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../utils/app_colors.dart';

// This is a generic conversation screen that can be used by both students and staff.
class ConversationScreen extends StatefulWidget {
  final String recipientId;
  final String recipientName;

  const ConversationScreen({
    Key? key,
    required this.recipientId,
    required this.recipientName,
  }) : super(key: key);

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _chatService = ChatService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  
  List<Message> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessageHistory();
  }

  Future<void> _loadMessageHistory() async {
    final userId = context.read<AuthService>().currentUser?.id;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }
    
    final history = await _chatService.getConversation(userId, widget.recipientId);
    setState(() {
      _messages = history;
      _isLoading = false;
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    if (content.isEmpty || user == null) {
      return;
    }

    const uuid = Uuid();
    final newMessage = Message(
      id: uuid.v4(),
      senderId: user.id,
      senderName: user.fullName,
      recipientId: widget.recipientId,
      content: content,
      sentAt: DateTime.now(),
      isRead: false,
    );

    setState(() {
      _messages.add(newMessage);
    });
    _messageController.clear();
    _scrollToBottom();

    await _chatService.sendMessage(newMessage);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthService>().currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipientName, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.darkGray.withOpacity(0.8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.darkGray,
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : _messages.isEmpty
                    ? const Center(child: Text("Начните диалог", style: TextStyle(color: Colors.white70)))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isUserMessage = message.senderId == userId;
                          return _MessageBubble(
                            message: message,
                            isUserMessage: isUserMessage,
                          );
                        },
                      ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
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
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Введите сообщение...',
                      hintStyle: TextStyle(color: AppColors.white.withOpacity(0.5)),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: AppColors.cyan),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isUserMessage;

  const _MessageBubble({
    Key? key,
    required this.message,
    required this.isUserMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final alignment = isUserMessage ? Alignment.centerRight : Alignment.centerLeft;
    final color = isUserMessage ? AppColors.lightViolet : AppColors.darkViolet.withOpacity(0.7);

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.content,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }
}
