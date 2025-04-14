// main.dart - VideoPlayerScreen
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:newsapp1/video_player_section/widget/comment_section.dart';
import 'package:newsapp1/video_player_section/widget/description.dart';
import 'package:newsapp1/video_player_section/widget/related_video.dart';
import 'package:newsapp1/video_player_section/widget/video_action.dart';
import 'package:newsapp1/video_player_section/widget/video_info.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  final String title;
  final String description;
  final List<Map<String, dynamic>> relatedVideos;

  const VideoPlayerScreen({
    Key? key,
    required this.videoPath,
    required this.title,
    required this.description,
    required this.relatedVideos,
  }) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _videoEnded = false;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.network(widget.videoPath);
      await _videoPlayerController.initialize();
      _videoPlayerController.addListener(_onVideoStateChange);

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        aspectRatio: 16 / 9,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.black,
          handleColor: Colors.black,
          backgroundColor: Colors.grey.shade300,
          bufferedColor: Colors.grey.shade500,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error loading video: ${e.toString()}';
        print('Video Player Error: $e');
      });
    }
  }

  void _onVideoStateChange() {
    if (_videoPlayerController.value.position >= _videoPlayerController.value.duration) {
      setState(() {
        _videoEnded = true;
      });
    } else if (_videoEnded && _videoPlayerController.value.isPlaying) {
      setState(() {
        _videoEnded = false;
      });
    }
  }

  void _replayVideo() {
    _videoPlayerController.seekTo(Duration.zero);
    _videoPlayerController.play();
    setState(() {
      _videoEnded = false;
    });
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(_onVideoStateChange);
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Video Player',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Video player at the top
            _buildVideoPlayer(),

            // Scrollable content below video
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView(
                  children: [
                    // Video info (title and views)
                    VideoInfoWidget(title: widget.title),

                    // Action buttons
                    VideoActionsWidget(),

                    Divider(thickness: 1),

                    // Description - expandable section
                    DescriptionWidget(description: widget.description),

                    Divider(thickness: 1),

                    // Comments section
                    CommentsWidget(),

                    Divider(thickness: 1, height: 32),

                    // Related Videos header
                    Padding(
                      padding: EdgeInsets.only(left: 12, bottom: 12),
                      child: Text(
                        'Related Videos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Related videos list
                    RelatedVideosWidget(
                      relatedVideos: widget.relatedVideos,
                      onVideoSelected: (video) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerScreen(
                              videoPath: video['video'],
                              title: video['title'],
                              description: video['description'],
                              relatedVideos: widget.relatedVideos,
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (_isLoading)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          )
        else if (_error.isNotEmpty)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 50),
                  SizedBox(height: 10),
                  Text(
                    'Failed to load video',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          )
        else if (_chewieController != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Chewie(controller: _chewieController!),
            ),

        // Replay button appears when video ends
        if (_videoEnded && !_isLoading && _error.isEmpty)
          IconButton(
            onPressed: _replayVideo,
            icon: Icon(
              Icons.replay_circle_filled,
              color: Colors.white,
              size: 60,
            ),
          ),
      ],
    );
  }
}