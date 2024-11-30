class ChannelModel {
  final String id;
  final String title;
  final String handle;
  final String description;
  final String thumbnailUrl;
  final String bannerUrl;
  final String subscriberCount;
  final String videoCount;
  final bool isVerified;
  final List<String> links;

  ChannelModel({
    required this.id,
    required this.title,
    required this.handle,
    required this.description,
    required this.thumbnailUrl,
    required this.bannerUrl,
    required this.subscriberCount,
    required this.videoCount,
    required this.isVerified,
    required this.links,
  });

  factory ChannelModel.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] ?? {};
    final statistics = json['statistics'] ?? {};
    final brandingSettings = json['brandingSettings'] ?? {};

    // Format subscriber count
    String subscriberCountStr = '0';
    if (statistics['subscriberCount'] != null) {
      int subscribers =
          int.tryParse(statistics['subscriberCount'].toString()) ?? 0;
      if (subscribers > 1000000) {
        subscriberCountStr = '${(subscribers / 1000000).toStringAsFixed(1)}M';
      } else if (subscribers > 1000) {
        subscriberCountStr = '${(subscribers / 1000).toStringAsFixed(1)}K';
      } else {
        subscriberCountStr = subscribers.toString();
      }
    }

    return ChannelModel(
      id: json['id'] ?? '',
      title: snippet['title'] ?? '',
      handle: '@${snippet['customUrl'] ?? ''}',
      description: snippet['description'] ?? '',
      thumbnailUrl: snippet['thumbnails']?['default']?['url'] ?? '',
      bannerUrl: brandingSettings['image']?['bannerExternalUrl'] ?? '',
      subscriberCount: subscriberCountStr,
      videoCount: '${statistics['videoCount'] ?? 0}',
      isVerified: snippet['isVerified'] ?? false,
      links: List<String>.from(snippet['links'] ?? []),
    );
  }
}
