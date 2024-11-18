import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'models/conversation.dart';
import 'screens/chat_screen.dart';
import 'screens/conversations_list_screen.dart';
// import 'screens/auth/signup_screen.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: ConversationsListScreen(),
    );
  }
}