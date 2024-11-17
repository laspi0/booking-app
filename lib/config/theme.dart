import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFF0C4767);

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor),
      ),
      contentPadding: const EdgeInsets.all(16),
    ),
  );
}