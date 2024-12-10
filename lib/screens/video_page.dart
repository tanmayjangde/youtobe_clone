import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../services/youtube_api_service.dart';
import '../helper.dart';
import '../widgets/video_info_section.dart';
import '../widgets/video_list_widget.dart';
import '../screens/channel_page.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/comments_section.dart';

class VideoPage extends StatefulWidget {
  final VideoModel video;

  const VideoPage({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  VideoPageState createState() => VideoPageState();
}

class VideoPageState extends State<VideoPage> {
  final YouTubeApiService _apiService = YouTubeApiService();
  List<VideoModel> _recommendedVideos = [];
  bool _isLoading = true;
  String? _error;
  late YoutubePlayerWidgetState _playerState;

  List<Map<String, dynamic>> _comments = [];
  bool _isCommentsLoading = true;
  bool _isCommentsExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadRecommendedVideos();
    _loadComments();
  }

  void _toggleComments() {
    setState(() {
      _isCommentsExpanded = !_isCommentsExpanded;
    });
  }

  Future<void> _loadComments() async {
    await Helper.handleRequest(() async {
      if (mounted) {
        setState(() {
          _isCommentsLoading = true;
        });
      }

      final comments = await _apiService.fetchVideoComments(widget.video.id);

      if (mounted) {
        setState(() {
          _comments = comments;
          _isCommentsLoading = false;
        });
      }
    });
  }

  Future<void> _loadRecommendedVideos() async {
    await Helper.handleRequest(() async {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final videos = await _apiService.fetchVideos(query: widget.video.title);

      if (mounted) {
        setState(() {
          _recommendedVideos = videos;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Fixed YouTube Player at the top
          YoutubePlayerWidget(
            videoId: widget.video.id,
            onPlayerStateCreated: (state) {
              _playerState = state;
            },
          ),
          // Scrollable content below the player
          Expanded(
            child: _isCommentsExpanded
                ? CommentsSection(
                    comments: _comments,
                    isLoading: _isCommentsLoading,
                    onCommentsTap: _toggleComments,
                    isExpanded: true,
                    onClose: _toggleComments,
                  )
                : ListView(
                    children: [
                      // Video information
                      VideoInfoSection(
                        video: widget.video,
                        onChannelTap: () {
                          _playerState.pause();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChannelPage(
                                channelId: widget.video.channelId,
                              ),
                            ),
                          );
                        },
                      ),
                      CommentsSection(
                        comments: _comments,
                        isLoading: _isCommentsLoading,
                        onCommentsTap: _toggleComments,
                        isExpanded: false,
                        onClose: _toggleComments,
                      ),
                      // Recommended videos
                      if (_isLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      else if (_error != null)
                        Center(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      else
                        Column(
                          children: _recommendedVideos.map((video) {
                            return VideoListWidget(
                              videos: [video],
                              isLoading: false,
                              onVideoSelected: (video) {
                                _playerState.pause();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        VideoPage(video: video),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
