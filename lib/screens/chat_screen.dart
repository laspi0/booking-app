import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../services/conversation_service.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatScreen({Key? key, required this.conversation}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  bool _isLoading = true;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        _fetchMessages();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _timer?.cancel(); // Cancel the timer in dispose
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    try {
      final messages =
          await ConversationService.getMessages(widget.conversation.id);
      await ConversationService.markAsRead(widget.conversation.id);
      if (mounted) {
        // Check if the widget is still mounted before calling setState
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        // Check if the widget is still mounted before calling setState
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();
    try {
      final newMessage = await ConversationService.sendMessage(
          widget.conversation.id, content);
      if (mounted) {
        // Check if the widget is still mounted before calling setState
        setState(() {
          _messages.add(newMessage);
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        // Check if the widget is still mounted before calling setState
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'envoi du message: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.conversation.listingTitle),
            Text(
              'Conversation avec ${widget.conversation.senderName}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Erreur: $_error'))
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Align(
                              alignment: message.userId ==
                                      widget.conversation.recipientId
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7,
                                ),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: message.userId ==
                                          widget.conversation.senderId
                                      ? Colors.blue[100]
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(message.content),
                                    SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat('HH:mm')
                                              .format(message.createdAt),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        message.isRead
                                            ? Icon(Icons.check_circle,
                                                size: 12, color: Colors.blue)
                                            : Icon(Icons.check_circle_outline,
                                                size: 12, color: Colors.grey),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Écrire un message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}