import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'menu_screen.dart';
import 'loading_screen.dart'; // Add this import
import 'audio_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  late AudioManager _audioManager;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _audioManager = AudioManager();

    // Set device orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // Set system UI overlay style
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    // Load the video from assets
    _controller = VideoPlayerController.asset('assets/videos/studio_logo.mp4');

    // Initialize the controller and start playing
    await _controller.initialize();

    // Once initialized, set the flag and update UI
    setState(() {
      _isVideoInitialized = true;
    });

    // Play the video with audio
    _controller.play();

    // Add listener for video completion
    _controller.addListener(() {
      if (!_controller.value.isPlaying && _controller.value.position >= _controller.value.duration) {
        // Video has completed playing, navigate to loading screen
        _navigateToLoadingScreen();
      }
    });
  }

  void _navigateToLoadingScreen() {
    // Dispose the video controller first
    _controller.dispose();

    // Navigate to the loading screen and replace the splash screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoadingScreen(
          onInitialization: () async {
            // Initialize audio manager and ensure it completes
            final audioManager = AudioManager();
            await audioManager.init();
            await Future.delayed(const Duration(milliseconds: 500));
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed
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
            : const CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }
}