import 'package:flutter/material.dart';
import '../models/video_model.dart';

class VideoInfoSection extends StatelessWidget {
  final VideoModel video;
  final VoidCallback onChannelTap;

  const VideoInfoSection({
    Key? key,
    required this.video,
    required this.onChannelTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            video.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              Text(
                video.viewCount,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(width: 8),
              Text(
                '•',
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(width: 8),
              Text(
                video.publishedTime,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          ),
        ),
        ListTile(
          onTap: onChannelTap,
          leading: CircleAvatar(
            backgroundImage: NetworkImage(video.channelAvatarUrl),
          ),
          title: Text(
            video.channelTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            '2.3M subscribers',
            style: TextStyle(color: Colors.grey[400]),
          ),
          trailing: TextButton(
            onPressed: () {},
            child: const Text(
              'SUBSCRIBE',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
