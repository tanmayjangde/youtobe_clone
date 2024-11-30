import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/channel_model.dart';
import '../models/video_model.dart';

class YouTubeApiService {
  final String _baseUrl = 'https://www.googleapis.com/youtube/v3';
  final String _apiKey = ''; // Replace with your actual API key

  Future<List<VideoModel>> fetchVideos({String query = ''}) async {
    try {
      final Uri uri;
      if (query.isEmpty) {
        uri = Uri.parse(
            '$_baseUrl/videos?part=snippet,statistics,contentDetails&chart=mostPopular&maxResults=10&key=$_apiKey');
      } else {
        uri = Uri.parse(
            '$_baseUrl/search?part=snippet&q=$query&type=video&maxResults=10&key=$_apiKey');
      }

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'];

        if (query.isNotEmpty) {
          // For search results, we need to fetch additional details
          final List<VideoModel> videos = [];
          for (var item in items) {
            final videoId = item['id']['videoId'];
            final details = await getVideoDetails(videoId);
            if (details != null) {
              videos.add(VideoModel.fromJson(details));
            }
          }
          return videos;
        }

        return items.map((item) => VideoModel.fromJson(item)).toList();
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching videos: $e');
      return [];
    }
  }

  Future<List<VideoModel>> fetchRecommendedVideos(String videoId) async {
    if (videoId.isEmpty) return [];
    print('aygdugduwghduwguwhwh : ${videoId}');

    try {
      final uri = Uri.parse(
          '$_baseUrl/search?part=snippet&relatedToVideoId=$videoId&type=video&maxResults=10&key=$_apiKey');

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'];

        // Fetch additional details for each recommended video
        final List<VideoModel> videos = [];
        for (var item in items) {
          final videoId = item['id']['videoId'];
          final details = await getVideoDetails(videoId);
          if (details != null) {
            videos.add(VideoModel.fromJson(details));
          }
        }
        return videos;
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching recommended videos: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getVideoDetails(String videoId) async {
    try {
      final uri = Uri.parse(
          '$_baseUrl/videos?part=snippet,statistics,contentDetails&id=$videoId&key=$_apiKey');

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        return items.isNotEmpty ? items.first : null;
      } else {
        debugPrint(
            'Video details API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching video details: $e');
    }
    return null;
  }

  // Add these methods to your existing YouTubeApiService class

  Future<ChannelModel?> fetchChannelDetails(String channelId) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/channels?part=snippet,statistics,brandingSettings&id=$channelId&key=$_apiKey',
      );

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        if (items.isNotEmpty) {
          return ChannelModel.fromJson(items.first);
        }
      }
      debugPrint(
          'Channel API Error: ${response.statusCode} - ${response.body}');
    } catch (e) {
      debugPrint('Error fetching channel details: $e');
    }
    return null;
  }

  Future<List<VideoModel>> fetchChannelVideos(String channelId) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/search?part=snippet&channelId=$channelId&order=date&type=video&maxResults=15&key=$_apiKey',
      );

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'];

        final List<VideoModel> videos = [];
        for (var item in items) {
          final videoId = item['id']['videoId'];
          final details = await getVideoDetails(videoId);
          if (details != null) {
            videos.add(VideoModel.fromJson(details));
          }
        }
        return videos;
      }
      debugPrint(
          'Channel videos API Error: ${response.statusCode} - ${response.body}');
    } catch (e) {
      debugPrint('Error fetching channel videos: $e');
    }
    return [];
  }
}
