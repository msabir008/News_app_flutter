import 'package:flutter/material.dart';
import 'package:newsapp1/profile/profile_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../breaking_news/newsbreak1.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  String _username = '';
  String _email = '';
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        // Not logged in - redirect to login screen
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
        return;
      }

      // Try to load user data
      String? username = prefs.getString('username');
      String? email = prefs.getString('email');

      // If individual fields not found, try to parse from user object
      if (username == null || email == null) {
        final userJson = prefs.getString('user');
        if (userJson != null) {
          final userData = json.decode(userJson);
          username = userData['username'] ?? '';
          email = userData['email'] ?? '';
        }
      }

      setState(() {
        _username = username ?? '';
        _email = email ?? '';
        _isLoggedIn = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('auth_token');
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('user');
    await prefs.remove('user_id');

    // Navigate back to login screen
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => NewsbreakLoginPage1()),
            (route) => false
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking login status
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.black,
          ),
        ),
      );
    }

    // If not logged in, show login screen
    if (!_isLoggedIn) {
      return NewsbreakLoginPage1();
    }

    // Logged in - show profile page as before
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Profile header with row layout
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile avatar on left
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.grey[300],
                        child: _username.isNotEmpty
                            ? Text(
                          _username[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        )
                            : const Icon(Icons.person, color: Colors.black, size: 40),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(Icons.camera_alt, size: 18, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  // Name, email, and button on right
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Username
                        Text(
                          _username.isNotEmpty ? _username : 'User',
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Email
                        Text(
                          _email.isNotEmpty ? _email : 'user@example.com',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 10),
                        // Edit profile button
                        SizedBox(
                          width: 150,
                          child: Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => EditProfilePage())
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                minimumSize: const Size(150, 40),
                              ),
                              child: const Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Menu options
              _buildMenuOption(Icons.favorite_border, 'Favourites', () {}),
              _buildMenuOption(Icons.delete_outline, 'Clear cache', () {}),
              _buildMenuOption(Icons.history, 'Clear history', () {}),
              _buildMenuOption(Icons.privacy_tip_outlined, 'Privacy Policy', () {}),
              _buildMenuOption(Icons.share_outlined, 'Share App', () {}),
              _buildMenuOption(Icons.feedback_outlined, 'Feedback', () {}),
              _buildMenuOption(Icons.logout, 'Log out', _logout),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.black,
                size: 24,
              ),
              const SizedBox(width: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}