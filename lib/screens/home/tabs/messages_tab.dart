import 'package:flutter/material.dart';
import 'package:register/controllers/messages_tab_controller.dart';
import 'package:register/screens/chat_screen.dart';
import 'package:register/widgets/messages/messages_list.dart';


class MessagesTab extends StatefulWidget {
  const MessagesTab({super.key});

  @override
  _MessagesTabState createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  late MessagesTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MessagesTabController();
  }

  @override
  void dispose() {
    _controller.disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller.error != null) {
            return Center(child: Text('Erreur: ${_controller.error}'));
          }
          return MessagesList(
            conversations: _controller.conversations,
            onConversationTap: (conversation) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(conversation: conversation),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
