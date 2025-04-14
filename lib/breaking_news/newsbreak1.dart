import 'package:flutter/material.dart';
import 'package:newsapp1/Registor/signup.dart';
import '../Registor/login.dart';

class NewsbreakLoginPage1 extends StatelessWidget {
  const NewsbreakLoginPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Changed from white to black
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            SizedBox(height: 40),

            // Image at the top
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Image.asset(
                'assets/icon/icon.png',
                height: 220,
                width: 220,
                fit: BoxFit.cover,
              ),
            ),

            // Main Content
            // Expanded(
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Text(
            //         'HKN News',
            //         style: TextStyle(
            //           fontSize: 32,
            //           fontWeight: FontWeight.bold,
            //           letterSpacing: 1.5,
            //           color: Colors.white, // Changed from black87 to white87
            //         ),
            //       ),
            //       SizedBox(height: 10),
            //     ],
            //   ),
            // ),
            Spacer(),

            // Login Buttons Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // Signup Button
                  _buildLoginButton(
                    text: 'Signup',
                    backgroundColor: Colors.white, // Changed from black to white
                    textColor: Colors.black, // Changed from white to black
                    onPressed: () {
                      _onSignupPressed(context);
                    },
                  ),

                  SizedBox(height: 16),

                  // Login Button
                  _buildLoginButton(
                    text: 'Login',
                    backgroundColor: Colors.black, // Changed from white to black
                    textColor: Colors.white, // Changed from black to white
                    borderColor: Colors.white, // Changed from black to white
                    onPressed: () {
                      _onLoginPressed(context);
                    },
                  ),

                  SizedBox(height: 50),

                  // Terms and Privacy Policy
                  // RichText(
                  //   textAlign: TextAlign.center,
                  //   text: TextSpan(
                  //     style: TextStyle(
                  //       color: Colors.white, // Changed from black54 to white54
                  //       fontSize: 12,
                  //     ),
                  //     children: [
                  //       TextSpan(
                  //         text: 'By using Hard Knock News, you agree to our ',
                  //       ),
                  //       TextSpan(
                  //         text: 'Terms of Use',
                  //         style: TextStyle(
                  //           color: Colors.white, // Changed from black to white
                  //           decoration: TextDecoration.underline,
                  //         ),
                  //       ),
                  //       TextSpan(
                  //         text: ' and ',
                  //       ),
                  //       TextSpan(
                  //         text: 'Privacy Policy',
                  //         style: TextStyle(
                  //           color: Colors.white, // Changed from black to white
                  //           decoration: TextDecoration.underline,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom Login Button Widget
  Widget _buildLoginButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: borderColor != null
              ? BorderSide(color: borderColor, width: 1)
              : BorderSide.none,
        ),
        elevation: borderColor == null ? 2 : 0,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Navigation Methods
  void _onSignupPressed(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
  }

  void _onLoginPressed(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }
}