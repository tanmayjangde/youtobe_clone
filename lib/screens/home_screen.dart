import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../services/youtube_api_service.dart';
import 'video_page.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/category_widget.dart';
import '../widgets/video_list_widget.dart';
import '../widgets/bottom_navigation_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final YouTubeApiService _apiService = YouTubeApiService();
  List<VideoModel> _videos = [];
  bool _isLoading = true;
  int _selectedCategoryIndex = 1; // 'All' selected by default

  final List<String> _categories = [
    'Explore',
    'All',
    'New to you',
    'Music',
    'AI',
    'JavaScript',
  ];

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    try {
      final videos = await _apiService.fetchVideos();
      setState(() {
        _videos = videos;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading videos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const AppBarWidget(),
      body: Column(
        children: [
          CategoryWidget(
            categories: _categories,
            selectedCategoryIndex: _selectedCategoryIndex,
            onCategorySelected: (index) {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: VideoListWidget(
                videos: _videos,
                isLoading: _isLoading,
                onVideoSelected: (video) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPage(video: video),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigationWidget(),
    );
  }
}
