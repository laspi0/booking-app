import 'dart:async';
import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../services/conversation_service.dart';
import 'chat_screen.dart';

class ConversationsListScreen extends StatefulWidget {
  @override
  _ConversationsListScreenState createState() =>
      _ConversationsListScreenState();
}

class _ConversationsListScreenState extends State<ConversationsListScreen> {
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        _fetchConversations();
      }
    });
  }

  Future<void> _fetchConversations() async {
    try {
      final conversations = await ConversationService.getConversations();
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mes Conversations')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Erreur: $_error'))
              : ListView.builder(
                  itemCount: _conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = _conversations[index];
                    return ListTile(
                      title: Text(conversation.listingTitle),
                      subtitle: Text(
                        conversation.unreadMessages > 0
                            ? '${conversation.unreadMessages} nouveaux messages'
                            : 'Pas de nouveaux messages',
                      ),
                      trailing: Text(conversation.lastMessageAt.toString()),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ChatScreen(conversation: conversation),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}