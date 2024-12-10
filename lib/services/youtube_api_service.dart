import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/channel_model.dart';
import '../models/video_model.dart';
import '../helper.dart';

class YouTubeApiService {
  final String _baseUrl = 'https://www.googleapis.com/youtube/v3';
  final String _apiKey = '';
  String? _nextPageToken;

  Future<List<VideoModel>> fetchVideos({
    String query = '',
    String? pageToken,
    int maxResults = 10,
  }) async {
    return await Helper.handleRequest<List<VideoModel>>(() async {
          final Uri uri = query.isEmpty
              ? Uri.parse(
                  '$_baseUrl/videos?part=snippet,statistics,contentDetails&chart=mostPopular&maxResults=$maxResults&pageToken=${pageToken ?? ''}&key=$_apiKey')
              : Uri.parse(
                  '$_baseUrl/search?part=snippet&q=$query&type=video&maxResults=$maxResults&pageToken=${pageToken ?? ''}&key=$_apiKey');

          final response = await http.get(uri);
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            _nextPageToken = data['nextPageToken'];

            final List<dynamic> items = data['items'];
            if (query.isNotEmpty) {
              final List<VideoModel> videos = [];
              for (var item in items) {
                final videoId = item['id']['videoId'];
                final details = await getVideoDetails(videoId);
                if (details != null) {
                  final video = await VideoModel.fromJson(details);
                  if (video != null) {
                    videos.add(video);
                  }
                }
              }
              return videos;
            }
            final List<VideoModel> videos = [];
            for (var item in items) {
              final video = await VideoModel.fromJson(item);
              if (video != null) {
                videos.add(video);
              }
            }
            return videos;
          } else {
            debugPrint('API Error: ${response.statusCode} - ${response.body}');
            return [];
          }
        }) ??
        [];
  }

  String? get nextPageToken => _nextPageToken;

  Future<Map<String, dynamic>?> getVideoDetails(String videoId) async {
    return await Helper.handleRequest<Map<String, dynamic>?>(() async {
      final uri = Uri.parse(
          '$_baseUrl/videos?part=snippet,statistics,contentDetails&id=$videoId&key=$_apiKey');

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        return items.isNotEmpty ? items.first : null;
      }
      debugPrint(
          'Video details API Error: ${response.statusCode} - ${response.body}');
      return null;
    });
  }

  Future<List<VideoModel>> fetchRecommendedVideos(String videoId) async {
    return await Helper.handleRequest<List<VideoModel>>(() async {
          final uri = Uri.parse(
              '$_baseUrl/search?part=snippet&relatedToVideoId=$videoId&type=video&maxResults=10&key=$_apiKey');

          final response = await http.get(uri);
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final List<dynamic> items = data['items'];

            final List<VideoModel> videos = [];
            for (var item in items) {
              final videoId = item['id']['videoId'];
              final details = await getVideoDetails(videoId);
              if (details != null) {
                final video = await VideoModel.fromJson(details);
                if (video != null) {
                  videos.add(video);
                }
              }
            }
            return videos;
          } else {
            debugPrint('API Error: ${response.statusCode} - ${response.body}');
            return [];
          }
        }) ??
        [];
  }

  Future<ChannelModel?> fetchChannelDetails(String channelId) async {
    return await Helper.handleRequest<ChannelModel?>(() async {
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
      return null;
    });
  }

  Future<List<VideoModel>> fetchChannelVideos(String channelId) async {
    return await Helper.handleRequest<List<VideoModel>>(() async {
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
                final video = await VideoModel.fromJson(details);
                if (video != null) {
                  videos.add(video);
                }
              }
            }
            return videos;
          }
          debugPrint(
              'Channel videos API Error: ${response.statusCode} - ${response.body}');
          return [];
        }) ??
        [];
  }

  Future<List<Map<String, dynamic>>> fetchVideoComments(String videoId) async {
    return await Helper.handleRequest<List<Map<String, dynamic>>>(() async {
          final uri = Uri.parse(
            '$_baseUrl/commentThreads?part=snippet&videoId=$videoId&maxResults=20&key=$_apiKey',
          );

          final response = await http.get(uri);
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final List<dynamic> items = data['items'];

            return items.map((item) {
              final snippet = item['snippet']['topLevelComment']['snippet'];
              return {
                'author': snippet['authorDisplayName'],
                'authorProfileImage': snippet['authorProfileImageUrl'],
                'text': snippet['textDisplay'],
                'likeCount': snippet['likeCount'],
                'publishedAt': snippet['publishedAt'],
              };
            }).toList();
          } else {
            debugPrint(
                'Comments API Error: ${response.statusCode} - ${response.body}');
            return [];
          }
        }) ??
        [];
  }
}
