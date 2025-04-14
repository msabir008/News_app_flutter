import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:newsapp1/Registor/login.dart';
import 'package:permission_handler/permission_handler.dart';

import '../breaking_news/newbreak.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  // News alert options
  bool selectAll = false;
  bool breakingNewsEnabled = false;
  bool celebrityNewsEnabled = false;
  bool politicalNewsEnabled = false;
  bool businessNewsEnabled = false;
  bool crimeNewsEnabled = false;

  bool showValidationMessage = false;

  // Method to handle select all toggle
  void _toggleSelectAll(bool? value) {
    setState(() {
      selectAll = value ?? false;
      breakingNewsEnabled = selectAll;
      celebrityNewsEnabled = selectAll;
      politicalNewsEnabled = selectAll;
      businessNewsEnabled = selectAll;
      crimeNewsEnabled = selectAll;
      showValidationMessage = false;
    });
  }

  // Method to check if any individual switch is toggled
  void _onIndividualSwitchChanged() {
    setState(() {
      // Update select all if all switches are on
      selectAll = breakingNewsEnabled &&
          celebrityNewsEnabled &&
          politicalNewsEnabled &&
          businessNewsEnabled &&
          crimeNewsEnabled;
      showValidationMessage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => NewsbreakLoginPage()),
              );
            },
            child: const Text(
              'Skip',
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stay Connect',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Image.asset(
                          'assets/images/news1.jpg',
                          height: 250,
                          width: 250,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Choose the type of alerts you\'d like to receive:',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10),

                      // Select All Option
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Select All News Alerts', style: TextStyle(fontSize: 14)),
                        value: selectAll,
                        activeColor: Colors.black,
                        onChanged: _toggleSelectAll,
                      ),

                      // Individual News Type Switches
                      _buildNewsSwitch('Breaking News', breakingNewsEnabled, (value) {
                        setState(() {
                          breakingNewsEnabled = value;
                          _onIndividualSwitchChanged();
                        });
                      }),
                      _buildNewsSwitch('Celebrity News', celebrityNewsEnabled, (value) {
                        setState(() {
                          celebrityNewsEnabled = value;
                          _onIndividualSwitchChanged();
                        });
                      }),
                      _buildNewsSwitch('Political News', politicalNewsEnabled, (value) {
                        setState(() {
                          politicalNewsEnabled = value;
                          _onIndividualSwitchChanged();
                        });
                      }),
                      _buildNewsSwitch('Business News', businessNewsEnabled, (value) {
                        setState(() {
                          businessNewsEnabled = value;
                          _onIndividualSwitchChanged();
                        });
                      }),
                      _buildNewsSwitch('Crime News', crimeNewsEnabled, (value) {
                        setState(() {
                          crimeNewsEnabled = value;
                          _onIndividualSwitchChanged();
                        });
                      }),

                      const SizedBox(height: 10),

                      // Validation Message
                      if (showValidationMessage &&
                          !breakingNewsEnabled &&
                          !celebrityNewsEnabled &&
                          !politicalNewsEnabled &&
                          !businessNewsEnabled &&
                          !crimeNewsEnabled)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Colors.black, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Please select at least one option',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Allow Button - Now outside the scrollview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    // Check if at least one option is selected
                    if (!breakingNewsEnabled &&
                        !celebrityNewsEnabled &&
                        !politicalNewsEnabled &&
                        !businessNewsEnabled &&
                        !crimeNewsEnabled) {
                      setState(() {
                        showValidationMessage = true;
                      });
                      return;
                    }

                    final status = await Permission.notification.request();
                    if (status.isGranted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => NewsbreakLoginPage()),
                      );

                      // Show welcome notification
                      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
                      const AndroidNotificationDetails androidNotificationDetails =
                      AndroidNotificationDetails(
                        'hkn_news_channel',
                        'HKN News',
                        importance: Importance.max,
                        priority: Priority.high,
                      );
                      const NotificationDetails notificationDetails =
                      NotificationDetails(android: androidNotificationDetails);
                      await flutterLocalNotificationsPlugin.show(
                        0,
                        'Welcome to HKN News',
                        'Stay updated with the latest news',
                        notificationDetails,
                      );
                    }
                  },
                  child: const Text('Allow'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create consistent news switches
  Widget _buildNewsSwitch(String title, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(fontSize: 14)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.black,
      ),
    );
  }
}