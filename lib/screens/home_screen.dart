import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../services/youtube_api_service.dart';
import '../helper.dart';
import 'video_page.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/category_widget.dart';
import '../widgets/video_list_widget.dart';
import '../widgets/bottom_navigation_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final YouTubeApiService _apiService = YouTubeApiService();
  List<VideoModel> _videos = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _selectedCategoryIndex = 1; // 'All' selected by default

  final List<String> _categories = [
    'Explore',
    'All',
    'New to you',
    'Music',
    'AI',
    'JavaScript',
  ];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadVideos();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreVideos();
    }
  }

  Future<void> _loadVideos() async {
    await Helper.handleRequest(() async {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      final videos = await _apiService.fetchVideos();

      if (mounted) {
        setState(() {
          _videos = videos;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _loadMoreVideos() async {
    if (_isLoadingMore) return;

    final nextPageToken = _apiService.nextPageToken;
    if (nextPageToken == null) return;

    await Helper.handleRequest(() async {
      if (mounted) {
        setState(() {
          _isLoadingMore = true;
        });
      }

      final moreVideos =
          await _apiService.fetchVideos(pageToken: nextPageToken);

      if (mounted) {
        setState(() {
          _videos.addAll(moreVideos);
          _isLoadingMore = false;
        });
      }
    });
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
            child: RefreshIndicator(
              onRefresh: _loadVideos,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate([
                      VideoListWidget(
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
                    ]),
                  ),
                  if (_isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigationWidget(),
    );
  }
}
