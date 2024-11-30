import 'dart:async';
import '../../../models/conversation.dart';
import '../../../services/conversation_service.dart';
import 'package:flutter/material.dart';

class MessagesTabController extends ChangeNotifier {
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  String? _error;
  Timer? _timer;

  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  MessagesTabController() {
    _fetchConversations();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _fetchConversations();
    });
  }

  Future<void> _fetchConversations() async {
    try {
      final conversations = await ConversationService.getConversations();
      _conversations = conversations;
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  void disposeController() {
    _timer?.cancel();
  }
}
