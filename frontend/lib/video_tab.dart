import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoTab extends StatefulWidget {
  const VideoTab({super.key});

  @override
  VideoTabState createState() => VideoTabState();
}

class VideoTabState extends State<VideoTab> {
  late VideoPlayerController _controller1;
  late VideoPlayerController _controller2;
  bool _isInitialized1 = false;
  bool _isInitialized2 = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer1();
    _initializeVideoPlayer2();
  }

  Future<void> _initializeVideoPlayer1() async {
    _controller1 = VideoPlayerController.networkUrl(
      Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'),
    );
    await _controller1.initialize();
    _controller1.setLooping(true); // Enable looping
    _controller1.setVolume(0.0); // Mute the video
    setState(() {
      _isInitialized1 = true;
      _controller1.play(); // Start playing the video
    });
  }

  Future<void> _initializeVideoPlayer2() async {
    _controller2 = VideoPlayerController.networkUrl(
      Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
    );
    await _controller2.initialize();
    _controller2.setLooping(true); // Enable looping
    _controller2.setVolume(0.0); // Mute the video
    setState(() {
      _isInitialized2 = true;
      _controller2.play(); // Start playing the video
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _isInitialized1
              ? SizedBox(
                  width: 600,
                  height: 900,
                  child: AspectRatio(
                    aspectRatio: _controller1.value.aspectRatio,
                    child: VideoPlayer(_controller1),
                  ),
                )
              : const CircularProgressIndicator(),
          _isInitialized2
              ? SizedBox(
                  width: 600,
                  height: 900,
                  child: AspectRatio(
                    aspectRatio: _controller2.value.aspectRatio,
                    child: VideoPlayer(_controller2),
                  ),
                )
              : const CircularProgressIndicator(),
        ],
      ),
    );
  }
}