import 'dart:async';
import 'package:flutter/material.dart';
import 'package:newsapp1/main.dart';
import 'package:newsapp1/onboard_permission/permission.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../BTM/bottom_navigation.dart';
import '../Registor/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool hasShownAd = false;

  @override
  void initState() {
    super.initState();
    // Initialize the AnimationController
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _navigateAfterSplash();
  }

  void _navigateAfterSplash() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    Timer(const Duration(seconds: 2), () {
      _loadAndShowAd(isFirstTime);
    });
  }

  void _loadAndShowAd(bool isFirstTime) {
      _navigateToNextScreen(isFirstTime);
  }

  void _navigateToNextScreen(bool isFirstTime) {
    if (isFirstTime) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const PermissionScreen()),
      );
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('isFirstTime', false);
      });
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SmoothBottomNavigation()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black
        ),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SizedBox(
                height: 300, // Image height
                width: 300,  // Image width
                child: Image.asset('assets/icon/icon.png'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
