import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game.dart';
import 'audio_manager.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool showCredits = false;
  final AudioManager _audioManager = AudioManager();

  @override
  void initState() {
    super.initState();
    // Start playing background music when menu loads
    _audioManager.playBackgroundMusic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/menu_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: showCredits ? buildCreditsContent() : buildMenuContent(),
            ),
            // Mute button in top-right corner
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(
                  _audioManager.isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 36,
                ),
                onPressed: () {
                  setState(() {
                    _audioManager.toggleMute();
                  });
                },
                padding: const EdgeInsets.all(10),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.black.withOpacity(0.5),
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenuContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '',
          style: TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 20,
                color: Colors.black,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
        // Increased spacing before buttons
        const SizedBox(height: 610),
        ElevatedButton(
          onPressed: () {
            // Don't stop the music when starting the game
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => GameWidget(game: floato()),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Start Game',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        // Increased spacing between buttons
        const SizedBox(height: 25),
        ElevatedButton(
          onPressed: () {
            setState(() {
              showCredits = true;
            });
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            backgroundColor: Colors.blueGrey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Credits',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCreditsContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: 300,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Credits',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Main Developer:\nImesh Sanjana\n\n'
                'Art Designers:\nNethmina Medagedara\nNethsara Werasooriya\nAnjana Herath\n\n'
                'Music & Sound:\nKavindu Heshan\n\n'
                'Special Thanks: Flutter and Flame Community',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              setState(() {
                showCredits = false;
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              backgroundColor: Colors.orange,
            ),
            child: const Text(
              'Back to Menu',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}