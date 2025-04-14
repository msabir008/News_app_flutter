// import 'package:chewie/chewie.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:newsapp1/video_player.dart';
// import 'package:video_player/video_player.dart';
//
// import 'article_reading.dart';
//
// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
//   TabController? _tabController;
//   PageController _pageController = PageController();
//   int _currentSlideIndex = 0;
//
//   // Map to track liked/disliked state for each news item
//   Map<String, bool> _likedItems = {};
//   Map<String, bool> _dislikedItems = {};
//   Map<String, bool> _commentedItems = {};
//   Map<String, bool> _sharedItems = {};
//   final List<String> categories = [
//     'All', 'Celebrity', 'Entertainment', 'Politics', 'Crime', 'Business'
//   ];
//
//   final List<Map<String, dynamic>> featuredItems = [
//     {
//       'title': 'Lizzo Blames Harassment Allegations for Mental Health Spiral: "I Didn t Want to Live Anymore.',
//       'description': 'This is the first breaking news item. Tap to read more about this interesting topic. The article contains important information that affects many citizens and provides context to recent developments in political landscape. Read on to discover the full implications of this breaking news and how it might affect your daily life.',
//       'image': 'assets/images/image23.png',
//       'video': 'assets/videos/breaking_news.mp4',
//       'category': 'Celebrity',
//       'isVideo': true,
//     },
//     {
//       'title': 'Entertainment Scoop: Latest Gossip and Exclusive Celebrity News!',
//       'description': 'Breaking entertainment updates and behind-the-scenes stories. Get the latest scoop on your favorite celebrities, movie releases, and entertainment industry trends.',
//       'image': 'assets/images/image2.png',
//       'video': 'assets/videos/entertainment_news.mp4',
//       'category': 'Entertainment',
//       'isVideo': true,
//     },
//     {
//       'title': 'Political Landscape: In-Depth Analysis and Breaking Political News',
//       'description': 'Comprehensive coverage of current political developments, electoral insights, policy changes, and expert political analysis from around the world.',
//       'image': 'assets/images/img.png',
//       'category': 'Politics',
//       'isVideo': false,
//     },
//   ];
//
//   final List<Map<String, dynamic>> newsItems = [
//     {
//       'id': '1',
//       'title': 'Lizzo Blames Harassment Allegations for Mental Health Spiral: "I Didn t Want to Live Anymore.',
//       'description': 'This is the first breaking news item. Tap to read more about this interesting topic. The article contains important information that affects many citizens and provides context to recent developments in political landscape. Read on to discover the full implications of this breaking news and how it might affect your daily life.',
//       'image': 'assets/images/image23.png',
//       'video': 'assets/videos/breaking_news.mp4',
//       'category': 'Celebrity',
//       'isVideo': true,
//       'likes': '198',
//       'dislikes': '23',
//       'comments': '41',
//     },
//     {
//       'id': '2',
//       'title': 'Entertainment Scoop: Latest Gossip and Exclusive Celebrity News!',
//       'description': 'Breaking entertainment updates and behind-the-scenes stories. Get the latest scoop on your favorite celebrities, movie releases, and entertainment industry trends.',
//       'image': 'assets/images/image2.png',
//       'video': 'assets/videos/entertainment_news.mp4',
//       'category': 'Entertainment',
//       'isVideo': true,
//       'likes': '154',
//       'dislikes': '18',
//       'comments': '27',
//     },
//     {
//       'id': '3',
//       'title': 'Political Landscape: In-Depth Analysis and Breaking Political News',
//       'description': 'Comprehensive coverage of current political developments, electoral insights, policy changes, and expert political analysis from around the world.',
//       'image': 'assets/images/img.png',
//       'category': 'Politics',
//       'isVideo': false,
//       'likes': '312',
//       'dislikes': '8',
//       'comments': '45',
//     },
//     {
//       'id': '4',
//       'title': 'Crime Report: Latest Updates on Legal and Criminal Cases',
//       'description': 'Detailed reporting on recent criminal investigations, legal proceedings, and significant crime stories that are making headlines.',
//       'image': 'assets/images/images12.jpg',
//       'video': 'assets/videos/crime_news.mp4',
//       'category': 'Crime',
//       'isVideo': true,
//       'likes': '245',
//       'dislikes': '15',
//       'comments': '36',
//     },
//     {
//       'id': '5',
//       'title': 'Business Insights: Market Trends, Economic News, and Corporate Developments',
//       'description': 'Comprehensive analysis of current business landscapes, market trends, stock market updates, and pivotal corporate news.',
//       'image': 'assets/images/images123.jpg',
//       'category': 'Business',
//       'isVideo': false,
//       'likes': '189',
//       'dislikes': '37',
//       'comments': '52',
//     },
//   ];
// // Map to store video controllers
// Map<String, VideoPlayerController> _videoControllers = {};
// Map<String, ChewieController> _chewieControllers = {};
//
// // List to store filtered featured items
// List<Map<String, dynamic>> _filteredFeaturedItems = [];
//
// @override
// void initState() {
//   super.initState();
//   _tabController = TabController(length: categories.length, vsync: this);
//   _tabController!.addListener(_handleTabSelection);
//
//   // Initialize video controllers for all video items
//   for (var item in newsItems.where((item) => item['isVideo'])) {
//     _initializeVideoController(item);
//   }
//
//   // Initialize controllers for featured videos too
//   for (var item in featuredItems.where((item) => item['isVideo'])) {
//     _initializeVideoController(item);
//   }
//
//   // Initialize filtered featured items to all items initially
//   _filteredFeaturedItems = List.from(featuredItems);
// }
//
// void _handleTabSelection() {
//   if (_tabController!.indexIsChanging) {
//     setState(() {
//       // Update featured items to match the selected category
//       _updateFeaturedItemsForCategory();
//     });
//   }
// }
//
// void _updateFeaturedItemsForCategory() {
//   String selectedCategory = categories[_tabController!.index];
//
//   setState(() {
//     // Filter featured items based on selected category
//     if (selectedCategory == 'All') {
//       _filteredFeaturedItems = List.from(featuredItems);
//     } else {
//       _filteredFeaturedItems = featuredItems
//           .where((item) => item['category'] == selectedCategory)
//           .toList();
//     }
//
//     // If no items match the category, show all items
//     if (_filteredFeaturedItems.isEmpty) {
//       _filteredFeaturedItems = List.from(featuredItems);
//     }
//
//     // Reset slide index when category changes
//     _currentSlideIndex = 0;
//     _pageController.jumpToPage(0);
//   });
// }
//
// void _initializeVideoController(Map<String, dynamic> item) {
//   if (item['isVideo']) {
//     final videoPath = item['video'];
//     final controller = VideoPlayerController.asset(videoPath);
//     _videoControllers[videoPath] = controller;
//
//     controller.initialize().then((_) {
//       if (mounted) {
//         final chewieController = ChewieController(
//           videoPlayerController: controller,
//           autoPlay: false,
//           looping: false,
//           aspectRatio: 16 / 10,
//           allowFullScreen: true,
//           allowMuting: true,
//           showControls: true,
//           materialProgressColors: ChewieProgressColors(
//             playedColor: Colors.black,
//             handleColor: Colors.black,
//             backgroundColor: Colors.grey.shade300,
//             bufferedColor: Colors.grey.shade500,
//           ),
//         );
//         _chewieControllers[videoPath] = chewieController;
//         setState(() {});
//       }
//     });
//   }
// }
//
// @override
// void dispose() {
//   _tabController?.dispose();
//   _pageController.dispose();
//
//   // Dispose all video controllers
//   for (var controller in _videoControllers.values) {
//     controller.dispose();
//   }
//   for (var controller in _chewieControllers.values) {
//     controller.dispose();
//   }
//
//   super.dispose();
// }
//
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(
//         // Explicitly set to center the title
//       title: Image.asset(
//         'assets/images/icon122.jpg',
//         height: 23, // Adjust height as needed
//       ),
//       backgroundColor: Colors.black,
//       iconTheme: IconThemeData(color: Colors.white),
//       actions: [
//         IconButton(
//           icon: SvgPicture.asset(
//             'assets/images/search.svg',
//             color: Colors.white,
//             width: 20,
//             height: 20,
//           ),
//           onPressed: () {
//             // Add your search functionality here
//           },
//         ),
//       ],
//     ),
//     body: Column(
//       children: [
//         // Category tabs - moved to the top
//         _buildCategoryTabs(),
//
//         // News content with featured slider integrated
//         Expanded(
//           child: TabBarView(
//             controller: _tabController,
//             children: categories.map((category) {
//               return _buildNewsContentWithSlider(category);
//             }).toList(),
//           ),
//         ),
//       ],
//     ),
//   );
// }
//   Widget _buildCategoryTabs() {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 10),
//       height: 35,
//       child: TabBar(
//         controller: _tabController,
//         isScrollable: true,
//         labelColor: Colors.white,
//         unselectedLabelColor: Colors.black,
//         indicatorColor: Colors.transparent, // Removes the divider line
//         dividerColor: Colors.transparent, // Remove bottom divider
//         indicatorSize: TabBarIndicatorSize.label,
//         indicator: BoxDecoration(
//           color: Colors.black,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         // Remove all padding in the TabBar itself
//         padding: EdgeInsets.zero,
//         tabAlignment: TabAlignment.start, // Align tabs from the start
//         labelPadding: EdgeInsets.symmetric(horizontal: 4), // Reduce space between tabs
//         tabs: categories.map((category) {
//           return Tab(
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//                 color: Colors.grey.withOpacity(0.1), // Changed from 0.3 to 0.1
//                 border: Border.all(color: Colors.grey.withOpacity(0.3)), // Added border
//               ),
//               child: Center(
//                 child: Text(
//                   category,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 10,
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
// // Combined news content with featured slider
// Widget _buildNewsContentWithSlider(String category) {
//   List<Map<String, dynamic>> filteredNews;
//
//   // Filter the news items based on selected category
//   if (category == 'All') {
//     filteredNews = newsItems;
//   } else {
//     filteredNews = newsItems.where((item) => item['category'] == category).toList();
//   }
//
//   return ListView(
//     padding: EdgeInsets.only(bottom: 24), // Added bottom padding
//     children: [
//
//       Padding(
//         padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'All News',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//           ],
//         ),
//       ),
//
//       ...filteredNews.map((item) => _buildNewsCard(item)).toList(),
//     ],
//   );
// }
//
// Widget _buildNewsCard(Map<String, dynamic> item) {
//   // Get all video items for related videos list if this is a video
//   List<Map<String, dynamic>> relatedVideos = [];
//   if (item['isVideo']) {
//     relatedVideos = newsItems.where((related) =>
//     related['isVideo'] && related['video'] != item['video']).toList();
//     // Add this video to the related list too (for demo purposes)
//     relatedVideos.add(item);
//   }
//
//   String itemId = item['id'] ?? item['title']; // Fallback to title if id isn't available
//
//   return Container(
//     margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(15),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.05),
//           blurRadius: 10,
//           offset: Offset(0, 5),
//         ),
//       ],
//     ),
//     child: InkWell(
//       onTap: () {
//         if (item['isVideo']) {
//           _openVideoPlayer(context, item['video'], item['title'], item['description'], relatedVideos);
//         } else {
//           // Open article detail screen for non-video items
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ArticleDetailScreen(
//                 title: item['title'],
//                 description: item['description'],
//                 image: item['image'],
//                 category: item['category'],
//               ),
//             ),
//           );
//         }
//       },
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Image with video play button and duration
//           Stack(
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(15),
//                   topRight: Radius.circular(15),
//                 ),
//                 child: Image.asset(
//                   item['image'],
//                   width: double.infinity,
//                   height: 200,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               // Category tag
//               Positioned(
//                 top: 10,
//                 left: 10,
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: _getCategoryColor(item['category']),
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//                   child: Text(
//                     item['category'].toUpperCase(),
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               // Play button
//               if (item['isVideo'])
//                 Positioned.fill(
//                   child: Center(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.7),
//                         shape: BoxShape.circle,
//                       ),
//                       padding: EdgeInsets.all(12),
//                       child: Icon(
//                         Icons.play_arrow,
//                         color: Colors.grey.shade700,
//                         size: 32,
//                       ),
//                     ),
//                   ),
//                 ),
//               // Duration badge
//               if (item['isVideo'])
//                 Positioned(
//                   right: 10,
//                   bottom: 10,
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: Colors.black,
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: Text(
//                       '3:45',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           // Title and details
//           Padding(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Title
//                 Text(
//                   item['title'],
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                     height: 1.3,
//                   ),
//                 ),
//                 SizedBox(height: 12),
//                 // Time and category information
//                 Row(
//                   children: [
//                     Text(
//                       item['category'],
//                       style: TextStyle(
//                         color: Colors.grey.shade600,
//                         fontSize: 14,
//                       ),
//                     ),
//                     Text(
//                       ' • ',
//                       style: TextStyle(
//                         color: Colors.grey.shade600,
//                         fontSize: 14,
//                       ),
//                     ),
//                     Text(
//                       '2 hours ago',
//                       style: TextStyle(
//                         color: Colors.grey.shade600,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),
//                 // Action buttons with SVG icons
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     _buildLikeButton(
//                       itemId,
//                       item['likes'] ?? '0',
//                     ),
//                     _buildDislikeButton(
//                       itemId,
//                       item['dislikes'] ?? '0',
//                     ),
//                     _buildCommentButton(
//                       itemId,
//                       item['comments'] ?? '0',
//                     ),
//                     _buildShareButton(
//                       itemId,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
//
// Widget _buildLikeButton(String itemId, String count) {
//   bool isActive = _likedItems[itemId] ?? false;
//
//   return InkWell(
//     onTap: () {
//       setState(() {
//         // Toggle like state
//         _likedItems[itemId] = !isActive;
//
//         // If liking, ensure dislike is off
//         if (_likedItems[itemId] == true) {
//           _dislikedItems[itemId] = false;
//         }
//       });
//     },
//     borderRadius: BorderRadius.circular(20),
//     child: Padding(
//       padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//       child: Row(
//         children: [
//           // Change SVG based on active state
//           SvgPicture.asset(
//             isActive ? 'assets/images/like2.svg' : 'assets/images/like1.svg', // Use different SVG files
//             width: 20,
//             height: 20,
//             color: isActive ? Colors.black : Colors.grey.shade700,
//           ),
//           SizedBox(width: 6),
//           Text(
//             count,
//             style: TextStyle(
//               color: isActive ? Colors.black : Colors.grey.shade700,
//               fontSize: 14,
//               fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
//
// Widget _buildDislikeButton(String itemId, String count) {
//   bool isActive = _dislikedItems[itemId] ?? false;
//
//   return InkWell(
//     onTap: () {
//       setState(() {
//         // Toggle dislike state
//         _dislikedItems[itemId] = !isActive;
//
//         // If disliking, ensure like is off
//         if (_dislikedItems[itemId] == true) {
//           _likedItems[itemId] = false;
//         }
//       });
//     },
//     borderRadius: BorderRadius.circular(20),
//     child: Padding(
//       padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//       child: Row(
//         children: [
//           // Change SVG based on active state
//           SvgPicture.asset(
//             isActive ? 'assets/images/dislike2.svg' : 'assets/images/dislike1.svg', // Use different SVG files
//             width: 20,
//             height: 20,
//             color: isActive ? Colors.black : Colors.grey.shade700,
//           ),
//           SizedBox(width: 6),
//           Text(
//             count,
//             style: TextStyle(
//               color: isActive ? Colors.black : Colors.grey.shade700,
//               fontSize: 14,
//               fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
//
// Widget _buildCommentButton(String itemId, String count) {
//   bool isActive = _commentedItems[itemId] ?? false;
//
//   return InkWell(
//     onTap: () {
//       setState(() {
//         _commentedItems[itemId] = !isActive;
//       });
//     },
//     borderRadius: BorderRadius.circular(20),
//     child: Padding(
//       padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//       child: Row(
//         children: [
//           SvgPicture.asset(
//             'assets/images/comment.svg',
//             width: 20,
//             height: 20,
//             color: isActive ? Colors.black : Colors.grey.shade700,
//           ),
//           SizedBox(width: 6),
//           Text(
//             count,
//             style: TextStyle(
//               color: isActive ? Colors.black : Colors.grey.shade700,
//               fontSize: 14,
//               fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
//
// Widget _buildShareButton(String itemId) {
//   bool isActive = _sharedItems[itemId] ?? false;
//
//   return InkWell(
//     onTap: () {
//       setState(() {
//         _sharedItems[itemId] = !isActive;
//       });
//     },
//     borderRadius: BorderRadius.circular(20),
//     child: Padding(
//       padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//       child: Row(
//         children: [
//           SvgPicture.asset(
//             'assets/images/share.svg',
//             width: 20,
//             height: 20,
//             color: isActive ? Colors.black : Colors.grey.shade700,
//           ),
//           SizedBox(width: 6),
//           Text(
//             'Share',
//             style: TextStyle(
//               color: isActive ? Colors.black : Colors.grey.shade700,
//               fontSize: 14,
//               fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
//
// Color _getCategoryColor(String category) {
//   // All categories now return black color
//   return Colors.black;
// }
//
// void _openVideoPlayer(BuildContext context, String videoPath, String title, String description, List<Map<String, dynamic>> relatedVideos) {
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => VideoPlayerScreen(
//         videoPath: videoPath,
//         title: title,
//         description: description,
//         relatedVideos: relatedVideos,
//       ),
//     ),
//   );
// }
// }