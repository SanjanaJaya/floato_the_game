import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game.dart';
import 'audio_manager.dart';
import 'shared_preferences_helper.dart';
import 'constants.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  bool showCredits = false;
  bool showRocketSelection = false;
  final AudioManager _audioManager = AudioManager();

  // Animation controller for rocket hover effect
  late AnimationController _animationController;
  late Animation<double> _animation;

  int highScore = 0;
  int highestLevel = 0;
  int unlockedRockets = 1;
  int selectedRocket = 0;
  String levelName = 'Level 1';

  @override
  void initState() {
    super.initState();
    // Start playing background music when menu loads
    _audioManager.playBackgroundMusic();

    // Setup animation for hover effect
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
      setState(() {});
    });

    // Make animation repeat back and forth
    _animationController.repeat(reverse: true);

    // Load saved data
    _loadSavedData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    highScore = await PreferencesHelper.getHighScore();
    highestLevel = await PreferencesHelper.getHighestLevel();
    unlockedRockets = await PreferencesHelper.getUnlockedRocketsCount();
    selectedRocket = await PreferencesHelper.getSelectedRocket();

    // Get level name based on threshold
    if (highestLevel >= 700) {
      levelName = 'Level 5';
    } else if (highestLevel >= 450) {
      levelName = 'Level 4';
    } else if (highestLevel >= 250) {
      levelName = 'Level 3';
    } else if (highestLevel >= 100) {
      levelName = 'Level 2';
    } else {
      levelName = 'Level 1';
    }

    setState(() {});
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
              child: showCredits
                  ? buildCreditsContent()
                  : (showRocketSelection
                  ? buildRocketSelectionContent()
                  : buildMenuContent()),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Spacer(flex: 2), // Top space

        // Game title with animated effect
        Transform.translate(
          offset: Offset(0, _animation.value),
          child: const Text(
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
        ),

        // Add this SizedBox for spacing
        const SizedBox(height: 33), // Adjust the height as needed

// High Score and Highest Level Display
        Container(
          padding: const EdgeInsets.all(15),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.amber, width: 2),
          ),
          child: Column(
            children: [
              Text(
                'HIGH SCORE: $highScore',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'HIGHEST LEVEL: $levelName',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        const Spacer(flex: 4), // Middle space

        // Animated rocket preview
        Transform.translate(
          offset: Offset(0, _animation.value * 1.5),
          child: Image.asset(
            'assets/images/bird/${rocketImages[selectedRocket]}',
            height: 100,
            width: 100,
          ),
        ),
        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.only(bottom: 20), // Ensure buttons don't touch bottom
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  // Play button sound
                  _audioManager.playSfx('button_click.wav');

                  // Don't stop the music when starting the game
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameWidget(
                        game: floato(selectedRocketType: selectedRocket),
                        overlayBuilderMap: {
                          'pauseButton': (BuildContext context, floato game) {
                            return PauseButton(game: game);
                          },
                          'pauseMenu': (BuildContext context, floato game) {
                            return PauseMenu(game: game);
                          },
                        },
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
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
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  // Play button sound
                  _audioManager.playSfx('button_click.wav');

                  setState(() {
                    showRocketSelection = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Select Bird',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  // Play button sound
                  _audioManager.playSfx('button_click.wav');

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
                  elevation: 5,
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
          ),
        ),
      ],
    );
  }

  Widget buildCreditsContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'CREDITS',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Main Developer',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            'Imesh Sanjana',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Graphics and Illustrations',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            'Nethsara Werasooriya',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const Text(
            'Anjana Herath',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const Text(
            'Nethmina Medagedara',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const Text(
            'Dinuwara Wijerathne',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Audio Effects & Music',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            'Kavindu Heshan',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          // Logo image added here
          Image.asset(
            'assets/images/logo.png',
            height: 100,
            width: 100,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Play button sound
              _audioManager.playSfx('button_click.wav');

              setState(() {
                showCredits = false;
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              backgroundColor: Colors.blueGrey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
            ),
            child: const Text(
              'Back',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRocketSelectionContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'SELECT BIRD',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 300,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.45,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 5, // Total number of rockets
              itemBuilder: (context, index) {
                final bool isUnlocked = index < unlockedRockets;
                final bool isSelected = index == selectedRocket;

                return GestureDetector(
                  onTap: isUnlocked
                      ? () async {
                    // Play selection sound
                    _audioManager.playSfx('button_click.wav');

                    setState(() {
                      selectedRocket = index;
                    });
                    await PreferencesHelper.saveSelectedRocket(index);
                  }
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.amber.withOpacity(0.3)
                          : Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Colors.amber : Colors.grey,
                        width: 2,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ] : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animating the rocket with the same hover effect
                        Transform.translate(
                          offset: Offset(0, isUnlocked ? _animation.value : 0),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Rocket image
                              Image.asset(
                                'assets/images/bird/${rocketImages[index]}',
                                height: 100,
                                color: isUnlocked ? null : Colors.black.withOpacity(0.7),
                                colorBlendMode: isUnlocked ? BlendMode.srcIn : BlendMode.srcATop,
                              ),
                              // Lock icon for locked rockets
                              if (!isUnlocked)
                                const Icon(
                                  Icons.lock,
                                  color: Colors.white,
                                  size: 50,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          rocketNames[index],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isUnlocked ? Colors.white : Colors.grey,
                          ),
                        ),
                        if (!isUnlocked)
                          Text(
                            rocketLevelRequirements[index],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Play button sound
              _audioManager.playSfx('button_click.wav');

              setState(() {
                showRocketSelection = false;
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              backgroundColor: Colors.blueGrey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
            ),
            child: const Text(
              'Back',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// PauseButton implementation
class PauseButton extends StatelessWidget {
  final floato game;

  const PauseButton({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      right: 20,
      child: IconButton(
        icon: const Icon(
          Icons.pause_circle_filled,
          color: Colors.white,
          size: 40,
        ),
        onPressed: () {
          game.togglePause();
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
    );
  }
}

// PauseMenu implementation
class PauseMenu extends StatelessWidget {
  final floato game;

  const PauseMenu({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AudioManager audioManager = AudioManager();

    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PAUSED',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    audioManager.playSfx('button_click.wav');
                    game.togglePause();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Resume',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    audioManager.playSfx('button_click.wav');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MenuScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Quit',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}