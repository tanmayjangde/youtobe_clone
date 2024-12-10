import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../services/youtube_api_service.dart';
import '../helper.dart';
import '../widgets/video_list_widget.dart';
import 'video_page.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final YouTubeApiService _apiService = YouTubeApiService();
  List<VideoModel> _searchResults = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  Future<void> _performSearch(String query) async {
    await Helper.handleRequest(() async {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      final videos = await _apiService.fetchVideos(query: query);

      if (mounted) {
        setState(() {
          _searchResults = videos;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search YouTube',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _performSearch(value);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                _performSearch(_searchController.text);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : SingleChildScrollView(
                    child: VideoListWidget(
                      videos: _searchResults,
                      isLoading: false,
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
    );
  }
}
