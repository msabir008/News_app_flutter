import 'package:flutter/material.dart';
import 'package:newsapp1/show_profile/profile_screen.dart';
import '../main_home/home_screen.dart';
import '../Notification/notificationscreen.dart';

class SmoothBottomNavigation extends StatefulWidget {
  @override
  _SmoothBottomNavigationState createState() => _SmoothBottomNavigationState();
}

class _SmoothBottomNavigationState extends State<SmoothBottomNavigation> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    HomePage(),
    NotificationPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _pages[_currentIndex],
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false, // Remove the extra top padding
          child: BottomNavigationBar(
            elevation: 0,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey[600],
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            iconSize: 25,
            selectedFontSize: 12,
            unselectedFontSize: 10,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            unselectedLabelStyle: TextStyle(
              color: Colors.grey[600],
            ),
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home_outlined,
                  size: 25,
                  color: _currentIndex == 0 ? Colors.black : Colors.grey[600],
                ),
                activeIcon: Icon(
                  Icons.home,
                  size: 25,
                  color: Colors.black,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.notifications_outlined,
                  size: 25,
                  color: _currentIndex == 1 ? Colors.black : Colors.grey[600],
                ),
                activeIcon: Icon(
                  Icons.notifications,
                  size: 25,
                  color: Colors.black,
                ),
                label: 'Notification',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.account_circle_outlined,
                  size: 25,
                  color: _currentIndex == 2 ? Colors.black : Colors.grey[600],
                ),
                activeIcon: Icon(
                  Icons.account_circle,
                  size: 25,
                  color: Colors.black,
                ),
                label: 'Me',
              ),
            ],
          ),
        ),
      ),
    );
  }
}