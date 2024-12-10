import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../helper.dart';

class VideoStreamService {
  final _yt = YoutubeExplode();

  Future<String?> getVideoUrl(String videoId) async {
    if (videoId.isEmpty) {
      debugPrint('Video ID cannot be empty');
      return null;
    }

    return Helper.handleRequest(() async {
      // Get the video manifest
      var manifest = await _yt.videos.streamsClient.getManifest(videoId);

      // Try to get the highest quality muxed stream
      var streams = manifest.muxed;
      if (streams.isEmpty) {
        // If no muxed streams available, try to get the highest quality video-only stream
        var videoStreams = manifest.videoOnly;
        if (videoStreams.isEmpty) {
          throw Exception('No available video streams');
        }
        var streamInfo = videoStreams.withHighestBitrate();
        return streamInfo.url.toString();
      }

      var streamInfo = streams.withHighestBitrate();
      return streamInfo.url.toString();
    });
  }

  void dispose() {
    _yt.close();
  }
}
