import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/conversations_list_screen.dart'; // Add this import

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
      home: ConversationsListScreen(), // This should now work
    );
  }
}