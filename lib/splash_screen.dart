import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'menu_screen.dart';
import 'loading_screen.dart';
import 'audio_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset('assets/videos/studio_logo.mp4');
    await _controller.initialize();

    setState(() => _isVideoInitialized = true);
    _controller.play();

    _controller.addListener(() {
      if (!_controller.value.isPlaying &&
          _controller.value.position >= _controller.value.duration) {
        _navigateToLoadingScreen();
      }
    });
  }

  void _navigateToLoadingScreen() {
    _controller.dispose();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoadingScreen(
          onInitialization: () async {
            // Additional initialization can go here
            await Future.delayed(const Duration(milliseconds: 200));
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _isVideoInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
            : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}