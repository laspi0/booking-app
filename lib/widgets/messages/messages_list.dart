import 'package:flutter/material.dart';
import '../../../models/conversation.dart';
import 'conversation_item.dart';

class MessagesList extends StatelessWidget {
  final List<Conversation> conversations;
  final void Function(Conversation) onConversationTap;

  const MessagesList({
    Key? key,
    required this.conversations,
    required this.onConversationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        return ConversationItem(
          conversation: conversations[index],
          onTap: () => onConversationTap(conversations[index]),
        );
      },
    );
  }
}
