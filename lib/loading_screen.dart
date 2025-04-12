// loading_screen.dart
import 'package:flutter/material.dart';
import 'package:floato_the_game/menu_screen.dart';
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

  // List of game tips to display randomly
  final List<String> _gameTips = [
    'Collect blue gems for extra power!',
    'Double tap to perform a special move!',
    'Watch out for red spikes - they\'re dangerous!',
    'Hidden paths might contain valuable treasures!',
    'Hold down to charge your jump for reaching higher platforms!',
    'Bubble shields protect you from one enemy attack!',
    'Some walls can be broken with a power attack!',
    'Enemies flash red when they\'re about to attack!',
    'Golden coins increase your score multiplier!',
    'Look for secret underwater passages!',
    'Save your power-ups for boss battles!',
    'Green healing orbs restore your health!',
    'Activate checkpoints to respawn safely!',
    'Combo moves deal more damage than regular attacks!',
    'Time slowdown power-ups help with difficult jumps!',
  ];

  @override
  void initState() {
    super.initState();

    // Choose one random tip for this loading session
    _currentTip = _getRandomTip();

    // Setup animation for tip
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

    // Start tip animation after a small delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _tipAnimationController.forward();
    });

    if (widget.onInitialization != null) {
      _startLoading();
    }
  }

  @override
  void dispose() {
    _tipAnimationController.dispose();
    super.dispose();
  }

  // Get a random tip from the list
  String _getRandomTip() {
    return _gameTips[_random.nextInt(_gameTips.length)];
  }

  void _startLoading() async {
    // Simulate progress updates
    const totalSteps = 10;
    for (int i = 0; i <= totalSteps; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        _progressValue = i / totalSteps;
      });
    }

    // Perform actual initialization
    await widget.onInitialization!();

    // Navigate to menu
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MenuScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // Spacer to push content to bottom
              const Spacer(),

              // Tip container with beautiful design
              FadeTransition(
                opacity: _tipFadeAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
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
                      // Tip icon
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Colors.amber,
                        size: 32,
                      ),
                      const SizedBox(height: 12),

                      // Tip divider
                      Container(
                        height: 2,
                        width: 40,
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
                      const SizedBox(height: 12),

                      // Tip text
                      Text(
                        _currentTip,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          height: 1.4,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Loading indicator and text
              const Text(
                'Loading Game',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      color: Colors.black,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Progress percentage
              Text(
                '${(_progressValue * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
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
                      minHeight: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}