import 'package:flutter/material.dart';
import 'package:newsapp1/profile/widget/password_field.dart';
import 'package:newsapp1/profile/widget/phone_field.dart';
import 'package:newsapp1/profile/widget/profile_avatar.dart';
import 'package:newsapp1/profile/widget/profile_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(text: "••••••••••••");
  final TextEditingController _phoneController = TextEditingController(text: "8865312");
  String _selectedCountryCode = "+91";
  bool _isLoading = true;
  String _firstLetter = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // First try to get individual user data fields
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
        _nameController.text = username ?? 'Charlotte King';
        _emailController.text = email ?? '@johnkinggraphics.gmail.com';
        _usernameController.text = username ?? '@johnkinggraphics';
        _firstLetter = username != null && username.isNotEmpty ? username[0].toUpperCase() : 'C';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        // Set default values in case of error
        _nameController.text = 'Charlotte King';
        _emailController.text = '@johnkinggraphics.gmail.com';
        _usernameController.text = '@johnkinggraphics';
        _firstLetter = 'C';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _nameController.text);
      await prefs.setString('email', _emailController.text);

      // Also update the user object if it exists
      final userJson = prefs.getString('user');
      if (userJson != null) {
        final userData = json.decode(userJson);
        userData['username'] = _nameController.text;
        userData['email'] = _emailController.text;
        await prefs.setString('user', json.encode(userData));
      }

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully'))
      );
      Navigator.pop(context, true); // Return true to indicate data was updated
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: ${e.toString()}'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // Center the title properly
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.black),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileAvatarWidget(firstLetter: _firstLetter),
              ProfileFieldWidget(title: 'Name', controller: _nameController),
              ProfileFieldWidget(title: 'E mail address', controller: _emailController),
              ProfileFieldWidget(title: 'User name', controller: _usernameController),
              PasswordFieldWidget(controller: _passwordController),
              PhoneFieldWidget(
                controller: _phoneController,
                selectedCountryCode: _selectedCountryCode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}