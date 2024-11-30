import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../services/youtube_api_service.dart';
import '../widgets/video_list_widget.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/video_info_section.dart';
import '../screens/channel_page.dart';

class VideoPage extends StatefulWidget {
  final VideoModel video;

  const VideoPage({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  final YouTubeApiService _apiService = YouTubeApiService();
  List<VideoModel> _recommendedVideos = [];
  bool _isLoading = true;
  String? _error;
  late YoutubePlayerWidgetState _playerState;

  @override
  void initState() {
    super.initState();
    _loadRecommendedVideos();
  }

  Future<void> _loadRecommendedVideos() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final videos = await _apiService.fetchVideos(query: widget.video.title);

      if (!mounted) return;

      setState(() {
        _recommendedVideos = videos;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load recommended videos';
        _isLoading = false;
      });
      debugPrint('Error loading recommended videos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _playerState.pause();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              // Fixed Video Player Widget
              YoutubePlayerWidget(
                videoId: widget.video.id,
                onPlayerStateCreated: (state) {
                  _playerState = state;
                },
              ),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      _buildCommentSection(),
                      const SizedBox(height: 10),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (_error != null)
                        Center(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      else
                        VideoListWidget(
                          videos: _recommendedVideos,
                          isLoading: false,
                          onVideoSelected: (video) {
                            _playerState.pause();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideoPage(video: video),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundImage:
                NetworkImage('https://picsum.photos/seed/user/100'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'User123',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'There you go... the drop I was waiting for',
                  style: TextStyle(color: Colors.grey[300]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
