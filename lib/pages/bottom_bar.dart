import 'package:flutter/material.dart';
import 'package:star_chat/pages/home_chat_page.dart';
import 'package:star_chat/pages/profile_page.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});
  static const pageRoute = '/bottom_bar';

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _currentIndex = 0;
  static final List<Widget> _pages = <Widget>[
    const HomeChatPage(),
    const ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      ////////////////// تم التعديل هنا
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.messenger), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
