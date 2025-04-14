import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../utils/api_service.dart';
import '../widgets/news_card.dart';

class SearchScreen extends StatefulWidget {
  final ApiService apiService;
  final String? userId;
  final Map<String, dynamic> reactions;
  final Function(String, String) onToggleReaction;
  final List<dynamic> allPosts; // Pass all posts from HomePage

  const SearchScreen({
    Key? key,
    required this.apiService,
    required this.userId,
    required this.reactions,
    required this.onToggleReaction,
    required this.allPosts,
  }) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    // Add listener to perform search on text changes
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    // Remove listener when disposing
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // New method that gets called whenever text changes
  void _onSearchChanged() {
    _performSearch(_searchController.text);
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    // Convert query to lowercase for case-insensitive search
    final lowercaseQuery = query.toLowerCase();

    // Filter posts locally based on title and content
    final results = widget.allPosts.where((post) {
      final title = post['title']?.toString().toLowerCase() ?? '';
      final body = post['body']?.toString().toLowerCase() ?? '';
      final type = post['type']?.toString().toLowerCase() ?? '';

      // Check for entries if they exist
      bool entryMatch = false;
      if (post['entries'] != null && post['entries'] is List) {
        entryMatch = post['entries'].any((entry) {
          final entryBody = entry['body']?.toString().toLowerCase() ?? '';
          return entryBody.contains(lowercaseQuery);
        });
      }

      return title.contains(lowercaseQuery) ||
          body.contains(lowercaseQuery) ||
          type.contains(lowercaseQuery) ||
          entryMatch;
    }).toList();

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Search', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for news, videos...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              // Remove onSubmitted as we now handle text changes with listener
              textInputAction: TextInputAction.search,
            ),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => _performSearch(_searchController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Text('Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Search for news and videos',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No results found for "${_searchController.text}"',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final post = _searchResults[index];
        return NewsCard(
          post: post,
          userId: widget.userId,
          reactions: widget.reactions,
          onToggleReaction: widget.onToggleReaction,
          apiService: widget.apiService,
        );
      },
    );
  }
}