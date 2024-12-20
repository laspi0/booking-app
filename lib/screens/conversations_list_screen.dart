import 'dart:async';
import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../services/conversation_service.dart';
import 'chat_screen.dart';

class ConversationsListScreen extends StatefulWidget {
  const ConversationsListScreen({super.key});

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
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
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
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 1,
              ),
            ],
          ),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: const Text(
              'Mes Conversations',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.black),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Erreur: $_error'))
              : ListView.builder(
                  itemCount: _conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = _conversations[index];
                    final bool isNewMessage = conversation.unreadMessages > 0;

                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage: NetworkImage(
                                'https://picsum.photos/seed/${index + 50}/200',
                              ),
                            ),
                          ],
                        ),
                        title: Text(
                          conversation.senderName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          conversation.listingTitle,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              conversation.lastMessageAt.toString(),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                            if (isNewMessage)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${conversation.unreadMessages}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChatScreen(conversation: conversation),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
