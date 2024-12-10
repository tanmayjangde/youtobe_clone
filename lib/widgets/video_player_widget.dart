import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerWidget extends StatefulWidget {
  final String videoId;
  final Function(YoutubePlayerWidgetState) onPlayerStateCreated;

  const YoutubePlayerWidget({
    Key? key,
    required this.videoId,
    required this.onPlayerStateCreated,
  }) : super(key: key);

  @override
  YoutubePlayerWidgetState createState() => YoutubePlayerWidgetState();
}

class YoutubePlayerWidgetState extends State<YoutubePlayerWidget> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
    widget.onPlayerStateCreated(this);
  }

  void _initializeController() {
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    );
  }

  void pause() {
    _controller.pause();
  }

  void seekTo(Duration position) {
    _controller.seekTo(position);
  }

  Duration getCurrentPosition() {
    return _controller.value.position;
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
          bufferedColor: Colors.grey,
          backgroundColor: Colors.black,
        ),
        onReady: () {
          // Sync position if necessary
          final currentPosition = _controller.value.position;
          _controller.seekTo(currentPosition);
        },
      ),
      builder: (context, player) {
        return player;
      },
    );
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
