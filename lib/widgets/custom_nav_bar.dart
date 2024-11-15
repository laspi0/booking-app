import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../config/theme.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(0, 255, 255, 255),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 255, 76).withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey[400],
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 5,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(MaterialCommunityIcons.home_outline),
              activeIcon: Icon(MaterialCommunityIcons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(MaterialCommunityIcons.message_outline),
              activeIcon: Icon(MaterialCommunityIcons.message),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(MaterialCommunityIcons.heart_outline),
              activeIcon: Icon(MaterialCommunityIcons.heart),
              label: 'Favoris',
            ),
            BottomNavigationBarItem(
              icon: Icon(MaterialCommunityIcons.account_outline),
              activeIcon: Icon(MaterialCommunityIcons.account),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
