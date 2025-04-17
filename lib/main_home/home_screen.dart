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

  // Scroll controller for ListView
  ScrollController _scrollController = ScrollController();

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

  // Pagination variables
  int _postsPerPage = 20;
  Map<String, int> _categoryCurrentPages = {};

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

    // Initialize current page for each category
    for (var category in categories) {
      _categoryCurrentPages[category] = 1;
    }

    _loadUserData();
  }

  void _handleTabSelection() {
    if (_tabController!.indexIsChanging) {
      setState(() {
        // Reset to first page when changing tabs
        String currentCategory = categories[_tabController!.index];
        _categoryCurrentPages[currentCategory] = 1;
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _pageController.dispose();
    _scrollController.dispose();
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

  // Method to change page
  void _changePage(String category, int newPage) {
    setState(() {
      _categoryCurrentPages[category] = newPage;
    });
    // Scroll to top when changing pages
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      appBar: _buildAppBar(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.black))
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

    if (filteredPosts.isEmpty) {
      return Center(child: Text('No posts available in this category'));
    }

    // Get current page for this category
    int currentPage = _categoryCurrentPages[category] ?? 1;

    // Calculate total pages
    int totalPages = (filteredPosts.length / _postsPerPage).ceil();

    // Get paginated posts
    int startIndex = (currentPage - 1) * _postsPerPage;
    int endIndex = startIndex + _postsPerPage > filteredPosts.length
        ? filteredPosts.length
        : startIndex + _postsPerPage;

    List<dynamic> paginatedPosts = filteredPosts.sublist(startIndex, endIndex);

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(bottom: 10),
              itemCount: paginatedPosts.length + 1, // +1 for pagination controls
              itemBuilder: (context, index) {
                if (index == paginatedPosts.length) {
                  // Pagination controls at the bottom
                  return totalPages > 1
                      ? _buildPaginationControls(category, currentPage, totalPages)
                      : SizedBox.shrink();
                } else {
                  // News post
                  final post = paginatedPosts[index];
                  return NewsCard(
                    post: post,
                    userId: _userId,
                    reactions: _reactions,
                    onToggleReaction: _toggleReaction,
                    apiService: _apiService,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(String category, int currentPage, int totalPages) {
    // Determine which page numbers to show
    List<int> pageNumbers = [];

    // Always show first page
    pageNumbers.add(1);

    // Calculate range of pages to show around current page
    int startPage = currentPage - 2;
    int endPage = currentPage + 2;

    // Adjust if startPage is less than 2
    if (startPage <= 2) {
      startPage = 2;
      endPage = min(6, totalPages);
    } else if (endPage >= totalPages - 1) {
      // Adjust if endPage is close to the end
      endPage = totalPages - 1;
      startPage = max(2, totalPages - 5);
    }

    // Add ellipsis after first page if needed
    if (startPage > 2) {
      pageNumbers.add(-1); // -1 represents ellipsis
    }

    // Add the range of pages
    for (int i = startPage; i <= endPage; i++) {
      if (i > 1 && i < totalPages) {
        pageNumbers.add(i);
      }
    }

    // Add ellipsis before last page if needed
    if (endPage < totalPages - 1) {
      pageNumbers.add(-1); // -1 represents ellipsis
    }

    // Always show last page
    if (totalPages > 1) {
      pageNumbers.add(totalPages);
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          if (currentPage > 1)
            _buildPageButton(
              icon: Icons.arrow_back_ios,
              onTap: () => _changePage(category, currentPage - 1),
              isActive: false,
            ),

          // Page numbers
          ...pageNumbers.map((pageNum) {
            if (pageNum == -1) {
              // Show ellipsis
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('...', style: TextStyle(fontWeight: FontWeight.bold)),
              );
            } else {
              // Show page number
              return _buildPageButton(
                text: pageNum.toString(),
                onTap: () => _changePage(category, pageNum),
                isActive: pageNum == currentPage,
              );
            }
          }).toList(),

          // Next button
          if (currentPage < totalPages)
            _buildPageButton(
              icon: Icons.arrow_forward_ios,
              onTap: () => _changePage(category, currentPage + 1),
              isActive: false,
            ),
        ],
      ),
    );
  }

  Widget _buildPageButton({String? text, IconData? icon, required VoidCallback onTap, required bool isActive}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black),
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, size: 14, color: isActive ? Colors.white : Colors.black)
              : Text(
            text!,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
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

// Helper functions for pagination
int min(int a, int b) {
  return a < b ? a : b;
}

int max(int a, int b) {
  return a > b ? a : b;
}