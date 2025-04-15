import 'package:floato_the_game/tutorial_screen.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game.dart';
import 'audio_manager.dart';
import 'shared_preferences_helper.dart';
import 'constants.dart';
import 'countdown_overlay.dart';
import 'bird_unlock_notification.dart';
import 'language_manager.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  bool showCredits = false;
  bool showRocketSelection = false;
  bool _isSinhala = false;
  final AudioManager _audioManager = AudioManager();

  // Animation controller for rocket hover effect
  late AnimationController _animationController;
  late Animation<double> _animation;

  int highScore = 0;
  int highestLevel = 0;
  int coins = 0;
  int unlockedRockets = 1;
  int selectedRocket = 0;
  String levelName = 'Level 1';

  @override
  void initState() {
    super.initState();
    _audioManager.playBackgroundMusic();

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

    _animationController.repeat(reverse: true);
    _loadSavedData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Add this method to toggle between languages
  void _toggleLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSinhala = !_isSinhala;
      LanguageManager.changeLanguage(_isSinhala ? LanguageManager.sinhala : LanguageManager.english);
      prefs.setBool('isSinhala', _isSinhala);
    });
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    _isSinhala = prefs.getBool('isSinhala') ?? false;
    LanguageManager.changeLanguage(_isSinhala ? LanguageManager.sinhala : LanguageManager.english);
    highScore = await PreferencesHelper.getHighScore();
    highestLevel = await PreferencesHelper.getHighestLevel();
    coins = await PreferencesHelper.getCoins();
    unlockedRockets = await PreferencesHelper.getUnlockedRocketsCount();
    selectedRocket = await PreferencesHelper.getSelectedRocket();
    if (highestLevel >= 1500) {
      levelName = LanguageManager.getText('level7');
    } else if (highestLevel >= 1000) {
      levelName = LanguageManager.getText('level6');
    } else if (highestLevel >= 600) {
      levelName = LanguageManager.getText('level5');
    } else if (highestLevel >= 350) {
      levelName = LanguageManager.getText('level4');
    } else if (highestLevel >= 200) {
      levelName = LanguageManager.getText('level3');
    } else if (highestLevel >= 80) {
      levelName = LanguageManager.getText('level2');
    } else {
      levelName = LanguageManager.getText('level1');
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
            // Language toggle button
            Positioned(
              top: 40,
              left: 20,
              child: IconButton(
                icon: Text(
                  _isSinhala ? 'EN' : 'SI',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _toggleLanguage,
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
            // Audio button
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
        const Spacer(flex: 2),
        Transform.translate(
          offset: Offset(0, _animation.value),
          child: Text(
            LanguageManager.getText('gameTitle'),
            style: const TextStyle(
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
        const SizedBox(height: 33),
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
                '${LanguageManager.getText('highScore')}: $highScore',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.yellow, size: 20),
                  const SizedBox(width: 5),
                  Text(
                    '$coins',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${LanguageManager.getText('highestLevel')}: $levelName',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const Spacer(flex: 4),
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
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
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
                          'tutorial': (BuildContext context, floato game) {
                            return TutorialScreen(
                              onComplete: () {
                                game.onTutorialComplete();
                              },
                            );
                          },
                          'countdown': (BuildContext context, floato game) {
                            return CountdownOverlay(game: game);
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
                child: Text(
                  LanguageManager.getText('startGame'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
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
                child: Text(
                  LanguageManager.getText('selectBird'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 15),
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
                  elevation: 5,
                ),
                child: Text(
                  LanguageManager.getText('credits'),
                  style: const TextStyle(
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
          Text(
            LanguageManager.getText('credits').toUpperCase(),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            LanguageManager.getText('mainDeveloper'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            LanguageManager.getText('Imesh Sanjana'),
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            LanguageManager.getText('graphicsAndIllustrations'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            LanguageManager.getText('Nethsara Werasooriya'),
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          Text(
            LanguageManager.getText('Anjana Herath'),
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          Text(
            LanguageManager.getText('Nethmina Medagedara'),
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          Text(
            LanguageManager.getText('Dinuwara Wijerathne'),
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            LanguageManager.getText('audioEffectsAndMusic'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            LanguageManager.getText('Kavindu Heshan'),
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          Image.asset(
            'assets/images/logo.png',
            height: 100,
            width: 100,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
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
            child: Text(
              LanguageManager.getText('back'),
              style: const TextStyle(
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
          Text(
            LanguageManager.getText('selectBird').toUpperCase(),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.85,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 5,
              itemBuilder: (context, index) {
                final bool isUnlocked = index < unlockedRockets;
                final bool isSelected = index == selectedRocket;

                return GestureDetector(
                  onTap: isUnlocked
                      ? () async {
                    setState(() {
                      selectedRocket = index;
                    });
                    await PreferencesHelper.saveSelectedRocket(index);
                  }
                      : () async {
                    if (coins >= birdUnlockCosts[index]!) {
                      // Deduct coins
                      coins -= birdUnlockCosts[index]!;
                      await PreferencesHelper.saveCoins(coins);

                      // Unlock the bird
                      unlockedRockets = index + 1;
                      await PreferencesHelper.saveUnlockedRockets(unlockedRockets);

                      // Select the newly unlocked bird
                      selectedRocket = index;
                      await PreferencesHelper.saveSelectedRocket(index);

                      setState(() {});

                      // Show unlock notification
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => BirdUnlockNotification(
                          birdIndex: index,
                          onClose: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${LanguageManager.getText('notEnoughCoins')}! ${LanguageManager.getText('need')} ${birdUnlockCosts[index]! - coins} ${LanguageManager.getText('more')}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.amber.withOpacity(0.3)
                          : Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Colors.amber : Colors.grey,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Transform.translate(
                            offset: Offset(0, isUnlocked ? _animation.value : 0),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/bird/${rocketImages[index]}',
                                  fit: BoxFit.contain,
                                  color: isUnlocked ? null : Colors.black.withOpacity(0.7),
                                  colorBlendMode: isUnlocked ? BlendMode.srcIn : BlendMode.srcATop,
                                ),
                                if (!isUnlocked)
                                  const Icon(
                                    Icons.lock,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            children: [
                              Text(
                                LanguageManager.getText('bird${index}Name'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isUnlocked ? Colors.white : Colors.grey,
                                ),
                              ),
                              if (!isUnlocked)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '${birdUnlockCosts[index]} ${LanguageManager.getText('coins')}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: coins >= birdUnlockCosts[index]! ? Colors.green : Colors.grey,
                                    ),
                                  ),
                                ),
                            ],
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
            child: Text(
              LanguageManager.getText('back'),
              style: const TextStyle(
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

class PauseMenu extends StatelessWidget {
  final floato game;

  const PauseMenu({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AudioManager audioManager = AudioManager();

    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8, // Limit width to prevent overflow
        ),
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
            FittedBox( // This will scale down text if needed
              fit: BoxFit.scaleDown,
              child: Text(
                LanguageManager.getText('paused').toUpperCase(),
                style: TextStyle(
                  fontSize: LanguageManager.currentLanguage == LanguageManager.sinhala ? 28 : 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Wrap( // Changed from Row to Wrap for better responsiveness
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 20,
              children: [
                ElevatedButton(
                  onPressed: () {
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
                  child: Text(
                    LanguageManager.getText('resume'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
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
                  child: Text(
                    LanguageManager.getText('quit'),
                    style: const TextStyle(
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