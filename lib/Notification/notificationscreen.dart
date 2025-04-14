import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // Dummy notification data
  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'Breaking News: Political Summit Announced',
      'description': 'A major political summit has been scheduled for next week involving world leaders.',
      'image': 'assets/images/image1.jpg',
      'time': DateTime.now().subtract(Duration(hours: 2)),
      'isRead': false,
    },
    {
      'title': 'New Tech Review: Latest Smartphone Release',
      'description': 'Check out our comprehensive review of the newest smartphone in the market.',
      'image': 'assets/images/image2.png',
      'time': DateTime.now().subtract(Duration(hours: 5)),
      'isRead': true,
    },
    {
      'title': 'App Update Available',
      'description': 'A new version of the app is available with improved features and bug fixes.',
      'image': 'assets/images/icon122.jpg',
      'time': DateTime.now().subtract(Duration(hours: 12)),
      'isRead': false,
    },
    {
      'title': 'Health Alert: Seasonal Flu Prevention Tips',
      'description': 'Important health guidelines to help you stay safe during flu season.',
      'image': 'assets/images/img.png',
      'time': DateTime.now().subtract(Duration(days: 1)),
      'isRead': true,
    },
    {
      'title': 'You Saved an Article',
      'description': 'The article "Science Breakthrough: New Discovery" has been saved to your bookmarks.',
      'image': 'assets/images/images12.jpg',
      'time': DateTime.now().subtract(Duration(days: 2)),
      'isRead': true,
    },
    {
      'title': 'Weekly News Digest',
      'description': 'Your personalized summary of the week\'s top stories is ready to view.',
      'image': 'assets/images/images123.jpg',
      'time': DateTime.now().subtract(Duration(days: 3)),
      'isRead': false,
    },
    {
      'title': 'New Topics Available',
      'description': 'We\'ve added "Space Exploration" and "Climate" to your topic preferences.',
      'image': 'assets/images/icon122.jpg',
      'time': DateTime.now().subtract(Duration(days: 4)),
      'isRead': true,
    },
  ];

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.check_circle_outline,
              color: Colors.white,
            ),
            onPressed: () {
              // Mark all as read
              setState(() {
                for (var notification in notifications) {
                  notification['isRead'] = true;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All notifications marked as read'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 10),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return _buildNotificationCard(notifications[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    // Fixed height for all notification cards
    const double cardHeight = 100.0;
    const double imageSize = 70.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () {
            // Mark as read when tapped
            setState(() {
              notification['isRead'] = true;
            });
            // Here you would normally navigate to the relevant content
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opening: ${notification['title']}'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: cardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: notification['isRead'] ? Colors.white : Colors.grey.shade50,
              border: notification['isRead']
                  ? null
                  : Border.all(color: Colors.black, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left indicator for unread notifications
                if (!notification['isRead'])
                  Container(
                    width: 4,
                    height: cardHeight,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                    ),
                  ),

                // Image container with fixed size
                Padding(
                  padding: EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: imageSize,
                      height: imageSize,
                      child: Image.asset(
                        notification['image'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // Content with fixed layout
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title and time row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                notification['title'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: notification['isRead']
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              _getTimeAgo(notification['time']),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 6),

                        // Description - limited to 2 lines with fixed height
                        Expanded(
                          child: Text(
                            notification['description'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}