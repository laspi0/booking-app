import 'package:flutter/material.dart';
import 'package:register/screens/home/tabs/home_tab.dart';
import 'package:register/screens/home/tabs/messages_tab.dart';
import '../../widgets/custom_nav_bar.dart';
import 'tabs/favorites_tab.dart';
import 'tabs/profile_tab.dart';
import '../../models/user.dart';

class HomeScreen extends StatefulWidget {
   final User user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeTab(user: widget.user),
      MessagesTab(),
      FavoritesTab(user: widget.user),
      ProfileTab(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}