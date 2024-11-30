class VideoModel {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String channelTitle;
  final String viewCount;
  final String publishedTime;
  final String channelAvatarUrl;
  final String duration;
  final String channelId;

  VideoModel({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.viewCount,
    required this.publishedTime,
    required this.channelAvatarUrl,
    required this.duration,
    required this.channelId,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] ?? {};
    final statistics = json['statistics'] ?? {};
    final contentDetails = json['contentDetails'] ?? {};

    // Extract the correct video ID
    String videoId = '';
    if (json['id'] is String) {
      videoId = json['id'];
    } else if (json['id'] is Map) {
      videoId = json['id']['videoId'] ?? '';
    }

    // Format view count
    String viewCountStr = '0 views';
    if (statistics['viewCount'] != null) {
      int views = int.tryParse(statistics['viewCount'].toString()) ?? 0;
      if (views > 1000000) {
        viewCountStr = '${(views / 1000000).toStringAsFixed(1)}M views';
      } else if (views > 1000) {
        viewCountStr = '${(views / 1000).toStringAsFixed(1)}K views';
      } else {
        viewCountStr = '$views views';
      }
    }

    // Format duration
    String durationStr = '0:00';
    if (contentDetails['duration'] != null) {
      final duration = contentDetails['duration'].toString();
      final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
      final match = regex.firstMatch(duration);
      if (match != null) {
        final hours = match.group(1);
        final minutes = match.group(2);
        final seconds = match.group(3);

        if (hours != null) {
          durationStr =
              '$hours:${minutes?.padLeft(2, '0') ?? '00'}:${seconds?.padLeft(2, '0') ?? '00'}';
        } else if (minutes != null) {
          durationStr = '$minutes:${seconds?.padLeft(2, '0') ?? '00'}';
        } else if (seconds != null) {
          durationStr = '0:${seconds.padLeft(2, '0')}';
        }
      }
    }

    return VideoModel(
      id: videoId,
      title: snippet['title'] ?? '',
      channelId: snippet['channelId'] ?? '',
      thumbnailUrl: snippet['thumbnails']?['high']?['url'] ??
          snippet['thumbnails']?['default']?['url'] ??
          '',
      channelTitle: snippet['channelTitle'] ?? '',
      viewCount: viewCountStr,
      publishedTime: _getTimeAgo(snippet['publishedAt'] ?? ''),
      channelAvatarUrl:
          'https://picsum.photos/seed/${snippet['channelId']}/200/200',
      duration: durationStr,
    );
  }

  static String _getTimeAgo(String publishedAt) {
    try {
      final published = DateTime.parse(publishedAt);
      final now = DateTime.now();
      final difference = now.difference(published);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} years ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} months ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }
}
