import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';

class MessageProvider with ChangeNotifier {
  List<Conversation> _conversations = [];
  Map<String, List<Message>> _messages = {};
  bool _isLoading = false;

  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;

  int get unreadCount => _conversations.fold(0, (sum, conv) => sum + conv.unreadCount);

  List<Message> getMessages(String conversationId) {
    return _messages[conversationId] ?? [];
  }

  Future<void> loadConversations(String token, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _conversations = await ApiService.getConversations(token, userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadMessages(String token, String conversationId) async {
    try {
      final messages = await ApiService.getMessages(token, conversationId);
      _messages[conversationId] = messages;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendMessage(String token, String receiverId, String content, {String? imageUrl}) async {
    try {
      final message = await ApiService.sendMessage(token, receiverId, content, imageUrl: imageUrl);
      
      // Encontrar o crear conversación
      final conversationId = '${message.senderId}_$receiverId';
      if (_messages[conversationId] == null) {
        _messages[conversationId] = [];
      }
      _messages[conversationId]!.add(message);
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void markAsRead(String conversationId) {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      // Aquí se podría hacer una llamada al API para marcar como leído
      notifyListeners();
    }
  }
}
