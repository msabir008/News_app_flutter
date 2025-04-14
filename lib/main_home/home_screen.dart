import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:newsapp1/main_home/search/search_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'widgets/news_card.dart';
import 'widgets/category_tabs.dart';
import 'utils/api_service.dart';
import 'utils/reaction_service.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  PageController _pageController = PageController();
  int _currentSlideIndex = 0;

  // API-related variables
  List<dynamic> _posts = [];
  bool _isLoading = true;
  String _error = '';
  String? _userId;

  // Services
  late ApiService _apiService;
  late ReactionService _reactionService;

  // Interaction tracking
  Map<String, dynamic> _reactions = {};

  final List<String> categories = [
    'All', 'Trending', 'Celebrity', 'Politics', 'Crime', "Entertainment", "News"
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _tabController!.addListener(_handleTabSelection);
    _apiService = ApiService();
    _reactionService = ReactionService();
    _loadUserData();
  }

  void _handleTabSelection() {
    if (_tabController!.indexIsChanging) {
      setState(() {
        // Additional tab selection logic if needed
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _pageController.dispose();
    _reactionService.saveReactionsToLocal(_reactions);
    super.dispose();
  }

  // Load user ID from shared preferences
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

      // If not found directly, try to parse from user object
      if (userId == null) {
        final userJson = prefs.getString('user');
        if (userJson != null) {
          final userData = json.decode(userJson);
          userId = userData['id']?.toString();
        }
      }

      setState(() {
        _userId = userId;
      });

      // Load saved reactions from SharedPreferences
      _reactions = await _reactionService.loadSavedReactions();
      setState(() {});

      _fetchPosts();
      _fetchReactions();
    } catch (e) {
      print('Error loading user data: ${e.toString()}');
      _fetchPosts();
      _fetchReactions();
    }
  }

  Future<void> _fetchReactions() async {
    try {
      Map<String, dynamic> serverReactions = await _apiService.fetchReactions();

      setState(() {
        // Merge with local reactions
        serverReactions.forEach((postId, reactions) {
          if (!_reactions.containsKey(postId)) {
            _reactions[postId] = reactions;
          }
        });
      });

      // Save the merged reactions to local storage
      _reactionService.saveReactionsToLocal(_reactions);
    } catch (e) {
      print('Error fetching reactions: ${e.toString()}');
    }
  }

  Future<void> _toggleReaction(String postId, String reactionType) async {
    if (_userId == null) {
      // User not logged in - show login prompt
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to react to posts')),
      );
      return;
    }

    try {
      Map<String, dynamic> updatedReactions = await _reactionService.toggleReaction(
          postId,
          reactionType,
          _userId!,
          _reactions
      );

      setState(() {
        _reactions = updatedReactions;
      });
    } catch (e) {
      print('Error toggling reaction: $e');
      // Ensure reactions are saved even if there's an error
      _reactionService.saveReactionsToLocal(_reactions);
    }
  }

  Future<void> _fetchPosts() async {
    try {
      final posts = await _apiService.fetchAllPosts();
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      appBar: _buildAppBar(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : Column(
        children: [
          CategoryTabs(
            categories: categories,
            tabController: _tabController!,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: categories.map((category) {
                return _buildNewsContentWithPosts(category);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 40,
      title: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: Image.asset(
          'assets/images/icon122.jpg',
          height: 22,
        ),
      ),
      backgroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: SvgPicture.asset(
            'assets/images/search.svg',
            color: Colors.white,
            width: 24,
            height: 24,
          ),
          onPressed: () {
            // Only navigate to search if posts are loaded
            if (!_isLoading && _error.isEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    apiService: _apiService,
                    userId: _userId,
                    reactions: _reactions,
                    onToggleReaction: _toggleReaction,
                    allPosts: _posts, // Pass all posts for local filtering
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please wait for content to load')),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildNewsContentWithPosts(String category) {
    // Filter posts based on category
    List<dynamic> filteredPosts = category == 'All'
        ? _posts
        : _posts.where((post) {
      return post['type'].toString().toLowerCase() == category.toLowerCase();
    }).toList();

    return filteredPosts.isEmpty
        ? Center(child: Text('No posts available in this category'))
        : RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: 10),
        itemCount: filteredPosts.length,
        itemBuilder: (context, index) {
          final post = filteredPosts[index];
          return NewsCard(
            post: post,
            userId: _userId,
            reactions: _reactions,
            onToggleReaction: _toggleReaction,
            apiService: _apiService,
          );
        },
      ),
    );
  }

  // Method to handle refresh functionality (pull to refresh)
  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    await _fetchPosts();
    await _fetchReactions();

    setState(() {
      _isLoading = false;
    });
  }
}