import 'package:flutter/material.dart';
import 'package:floato_the_game/menu_screen.dart';
import 'package:floato_the_game/language_manager.dart';
import 'package:floato_the_game/audio_manager.dart';
import 'dart:math' show Random;

class LoadingScreen extends StatefulWidget {
  final Future Function()? onInitialization;

  const LoadingScreen({Key? key, this.onInitialization}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  double _progressValue = 0.0;
  late String _currentTip;
  final Random _random = Random();
  late AnimationController _tipAnimationController;
  late Animation<double> _tipFadeAnimation;
  late AudioManager _audioManager;

  final List<String> _gameTips = [
    LanguageManager.getText('tipCollectAbilities'),
    LanguageManager.getText('tipTapToShoot'),
    LanguageManager.getText('tipWatchHelicopter'),
    LanguageManager.getText('tipHigherLevels'),
    LanguageManager.getText('tipCollectCoins'),
    LanguageManager.getText('tipSkyeAbility'),
    LanguageManager.getText('tipDifferentMissiles'),
  ];

  @override
  void initState() {
    super.initState();
    _audioManager = AudioManager();
    _currentTip = _getRandomTip();

    _tipAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _tipFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _tipAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _tipAnimationController.forward();
    });

    _startLoading();
  }

  @override
  void dispose() {
    _tipAnimationController.dispose();
    super.dispose();
  }

  String _getRandomTip() {
    return _gameTips[_random.nextInt(_gameTips.length)];
  }

  Future<void> _preloadResources() async {
    // Start audio preloading
    final audioFuture = _audioManager.init();

    // Simulate progress updates while loading
    const totalSteps = 10;
    for (int i = 0; i <= totalSteps; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        setState(() => _progressValue = i / totalSteps);
      }
    }

    // Wait for audio to finish loading
    await audioFuture;

    // Run additional initialization if provided
    if (widget.onInitialization != null) {
      await widget.onInitialization!();
    }
  }

  void _startLoading() async {
    await _preloadResources();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MenuScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/loading_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2), // Increased spacer to push content down
              FadeTransition(
                opacity: _tipFadeAnimation,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.06,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.amber,
                        size: screenWidth * 0.08,
                      ),
                      SizedBox(height: screenHeight * 0.012),
                      Container(
                        height: 2,
                        width: screenWidth * 0.1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.amber.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.012),
                      Text(
                        _currentTip,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isPortrait ? screenWidth * 0.045 : screenHeight * 0.045,
                          color: Colors.white,
                          height: 1.4,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.06), // Increased spacing here
              Text(
                LanguageManager.getText('loadingGame'),
                style: TextStyle(
                  fontSize: isPortrait ? screenWidth * 0.06 : screenHeight * 0.06,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      color: Colors.black,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                '${(_progressValue * 100).toInt()}%',
                style: TextStyle(
                  fontSize: isPortrait ? screenWidth * 0.04 : screenHeight * 0.04,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.15),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _progressValue,
                      backgroundColor: Colors.grey[800],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                      minHeight: screenHeight * 0.015,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 3), // Adjusted spacer to balance the layout
            ],
          ),
        ),
      ),
    );
  }
}