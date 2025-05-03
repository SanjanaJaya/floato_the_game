import 'package:floato_the_game/tutorial_screen.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'game.dart';
import 'audio_manager.dart';
import 'shared_preferences_helper.dart';
import 'constants.dart';
import 'countdown_overlay.dart';
import 'bird_unlock_notification.dart';
import 'language_manager.dart';

class MenuScreen extends StatefulWidget {
  final VideoPlayerController? videoPlayerController;

  const MenuScreen({Key? key, this.videoPlayerController}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  bool showCredits = false;
  bool showRocketSelection = false;
  bool _isSinhala = false;
  final AudioManager _audioManager = AudioManager();
  VideoPlayerController? _videoPlayerController;
  bool _needToInitVideo = false;

  // Animation controller for rocket hover effect
  late AnimationController _animationController;
  late Animation<double> _animation;

  int highScore = 0;
  int highestLevel = 0;
  int coins = 0;
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

    // Set up video controller if provided or create a new one
    if (widget.videoPlayerController != null) {
      _videoPlayerController = widget.videoPlayerController;
      // Make sure video loops
      _videoPlayerController!.setLooping(true);
      // Start playing immediately
      _videoPlayerController!.play();
    } else {
      _needToInitVideo = true;
      _videoPlayerController = VideoPlayerController.asset('assets/videos/menu_background.mp4')
        ..initialize().then((_) {
          setState(() {});
          _videoPlayerController!.setLooping(true);
          _videoPlayerController!.play();
        });
    }

    _loadSavedData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    // Only dispose video controller if we created it here
    if (_needToInitVideo && _videoPlayerController != null) {
      _videoPlayerController!.dispose();
    }
    super.dispose();
  }

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
    selectedRocket = await PreferencesHelper.getSelectedRocket();

    if (highestLevel >= 10000) {
      levelName = LanguageManager.getText('masterLevel');
    } else if (highestLevel >= 9500) {
      levelName = LanguageManager.getText('level23');
    } else if (highestLevel >= 9000) {
      levelName = LanguageManager.getText('level22');
    } else if (highestLevel >= 8500) {
      levelName = LanguageManager.getText('level21');
    } else if (highestLevel >= 8000) {
      levelName = LanguageManager.getText('level20');
    } else if (highestLevel >= 7500) {
      levelName = LanguageManager.getText('level19');
    } else if (highestLevel >= 7000) {
      levelName = LanguageManager.getText('level18');
    } else if (highestLevel >= 6500) {
      levelName = LanguageManager.getText('level17');
    } else if (highestLevel >= 6000) {
      levelName = LanguageManager.getText('level16');
    } else if (highestLevel >= 5500) {
      levelName = LanguageManager.getText('level15');
    } else if (highestLevel >= 5000) {
      levelName = LanguageManager.getText('level14');
    } else if (highestLevel >= 4500) {
      levelName = LanguageManager.getText('level13');
    } else if (highestLevel >= 4000) {
      levelName = LanguageManager.getText('level12');
    } else if (highestLevel >= 3500) {
      levelName = LanguageManager.getText('level11');
    } else if (highestLevel >= 3000) {
      levelName = LanguageManager.getText('level10');
    } else if (highestLevel >= 2500) {
      levelName = LanguageManager.getText('level9');
    } else if (highestLevel >= 2000) {
      levelName = LanguageManager.getText('level8');
    } else if (highestLevel >= 1500) {
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
    final mediaQuery = MediaQuery.of(context);
    final padding = mediaQuery.padding;
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Video background
          _videoPlayerController != null && _videoPlayerController!.value.isInitialized
              ? SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoPlayerController!.value.size.width,
                height: _videoPlayerController!.value.size.height,
                child: VideoPlayer(_videoPlayerController!),
              ),
            ),
          )
          // Fallback to static image if video not ready
              : Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/menu_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Dark overlay to make UI more visible
          Container(
            color: Colors.black.withOpacity(0.3),
          ),

          // Main content
          Padding(
            padding: EdgeInsets.only(
              top: padding.top,
              bottom: padding.bottom,
              left: padding.left,
              right: padding.right,
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
                  child: _buildCircleButton(
                    child: Text(
                      _isSinhala ? 'EN' : 'SI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: _toggleLanguage,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
                // Audio button
                Positioned(
                  top: 40,
                  right: 20,
                  child: _buildCircleButton(
                    child: Icon(
                      _audioManager.isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                      size: screenWidth * 0.08,
                    ),
                    onPressed: () {
                      setState(() {
                        _audioManager.toggleMute();
                      });
                    },
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required Widget child,
    required VoidCallback onPressed,
    Color? color,
    double? size,
  }) {
    return Container(
      width: size ?? 50,
      height: size ?? 50,
      decoration: BoxDecoration(
        color: color ?? Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(50),
          child: Center(child: child),
        ),
      ),
    );
  }

  Widget buildMenuContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final buttonWidth = screenWidth * 0.7;
    final buttonHeight = screenHeight * 0.07;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Spacer(flex: 2),
        Transform.translate(
          offset: Offset(0, _animation.value),
          child: Text(
            LanguageManager.getText(''),
            style: TextStyle(
              fontSize: screenWidth * 0.15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 20,
                  color: Colors.black,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.03),
        Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.amber, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                '${LanguageManager.getText('highScore')}: $highScore',
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.monetization_on, color: Colors.yellow, size: screenWidth * 0.05),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    '$coins',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                '${LanguageManager.getText('highestLevel')}: $levelName',
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
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
            height: screenHeight * 0.12,
            width: screenHeight * 0.12,
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        Padding(
          padding: EdgeInsets.only(bottom: screenHeight * 0.03),
          child: Column(
            children: [
              _buildMenuButton(
                englishImage: 'assets/images/buttons/start_english.png',
                sinhalaImage: 'assets/images/buttons/start_sinhala.png',
                width: buttonWidth,
                height: buttonHeight,
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
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildMenuButton(
                englishImage: 'assets/images/buttons/select_english.png',
                sinhalaImage: 'assets/images/buttons/select_sinhala.png',
                width: buttonWidth,
                height: buttonHeight,
                onPressed: () {
                  setState(() {
                    showRocketSelection = true;
                  });
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildMenuButton(
                englishImage: 'assets/images/buttons/dev_english.png',
                sinhalaImage: 'assets/images/buttons/dev_sinhala.png',
                width: buttonWidth,
                height: buttonHeight,
                onPressed: () {
                  setState(() {
                    showCredits = true;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required String englishImage,
    required String sinhalaImage,
    required VoidCallback onPressed,
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onPressed,
          child: Center(
            child: Image.asset(
              _isSinhala ? sinhalaImage : englishImage,
              width: width,
              height: height,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCreditsContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Center(
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.05),
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
          constraints: BoxConstraints(maxWidth: 600), // limit width on large screens
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.amberAccent, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.3),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bird group image
              Image.asset(
                'assets/images/bird_group.png',
                height: screenHeight * 0.15,
                fit: BoxFit.contain,
              ),
              SizedBox(height: screenHeight * 0.02),

              // Title
              Text(
                LanguageManager.getText('developers').toUpperCase(),
                style: TextStyle(
                  fontSize: screenWidth * 0.085,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.amberAccent.withOpacity(0.8),
                      offset: Offset(0, 2),
                    )
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              // Developer Section
              _buildCreditSection(
                title: LanguageManager.getText(''),
                names: [
                  LanguageManager.getText('Imesh Sanjana'),
                  LanguageManager.getText('Anjana Herath'),
                  LanguageManager.getText('Nethsara Werasooriya'),
                  LanguageManager.getText('Kavindu Heshan'),
                  LanguageManager.getText('Nethmina Medagedara'),
                  LanguageManager.getText('Dinuwara Wijerathne'),
                ],
              ),

              SizedBox(height: screenHeight * 0.04),

              // Logo
              Image.asset(
                'assets/images/logo.png',
                height: screenHeight * 0.12,
                width: screenHeight * 0.12,
              ),
              SizedBox(height: screenHeight * 0.03),

              // Back button
              _buildMenuButton(
                englishImage: 'assets/images/buttons/back_english.png',
                sinhalaImage: 'assets/images/buttons/back_sinhala.png',
                width: screenWidth * 0.5,
                height: screenHeight * 0.07,
                onPressed: () {
                  setState(() {
                    showCredits = false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreditSection({required String title, required List<String> names}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: screenHeight * 0.015),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: names.map(
                  (name) => Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.008),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.15),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Colors.amberAccent.withOpacity(0.4),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPerchDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        height: 2,
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.shade100, Colors.amber.shade700, Colors.amber.shade100],
          ),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget buildRocketSelectionContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return FutureBuilder<List<bool>>(
      future: PreferencesHelper.getUnlockedBirds(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final unlockedBirds = snapshot.data!;

        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.05),
            margin: EdgeInsets.all(screenWidth * 0.05),
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
                  style: TextStyle(
                    fontSize: screenWidth * 0.09,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                SizedBox(
                  height: screenHeight * 0.6, // Increased height to accommodate missiles
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: screenWidth * 0.03,
                      mainAxisSpacing: screenWidth * 0.03,
                    ),
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      final bool isUnlocked = unlockedBirds[index];
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

                            // Unlock this specific bird
                            await PreferencesHelper.unlockBird(index);
                            unlockedBirds[index] = true;

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
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.amber.withOpacity(0.3)
                                : Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(15),
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
                              // Bird image with animation
                              Expanded(
                                flex: 2, // Give more space to the bird
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
                                        Icon(
                                          Icons.lock,
                                          color: Colors.white,
                                          size: screenWidth * 0.08,
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                              // Missile image with glow effect
                              Expanded(
                                flex: 1, // Give less space to the missile
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/bird/missile${index + 1}.png',
                                        height: screenHeight * 0.05,
                                        color: isUnlocked ? null : Colors.black.withOpacity(0.7),
                                        colorBlendMode: isUnlocked ? BlendMode.srcIn : BlendMode.srcATop,
                                      ),
                                      if (isUnlocked)
                                        Container(
                                          width: screenWidth * 0.1,
                                          height: screenHeight * 0.05,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.amber.withOpacity(0.25),
                                                blurRadius: 10,
                                                spreadRadius: 3,
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                              // Bird name and unlock cost
                              Padding(
                                padding: EdgeInsets.only(top: screenHeight * 0.01),
                                child: Column(
                                  children: [
                                    Text(
                                      LanguageManager.getText('bird${index}Name'),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.035,
                                        fontWeight: FontWeight.bold,
                                        color: isUnlocked ? Colors.white : Colors.grey,
                                      ),
                                    ),
                                    if (!isUnlocked)
                                      Padding(
                                        padding: EdgeInsets.only(top: screenHeight * 0.005),
                                        child: Text(
                                          '${birdUnlockCosts[index]} ${LanguageManager.getText('coins')}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.03,
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
                SizedBox(height: screenHeight * 0.03),
                _buildMenuButton(
                  englishImage: 'assets/images/buttons/back_english.png',
                  sinhalaImage: 'assets/images/buttons/back_sinhala.png',
                  width: screenWidth * 0.5,
                  height: screenHeight * 0.07,
                  onPressed: () {
                    setState(() {
                      showRocketSelection  = false;
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
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
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () {
              game.togglePause();
            },
            child: const Center(
              child: Icon(
                Icons.pause_circle_filled,
                color: Colors.white,
                size: 40,
              ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSinhala = LanguageManager.currentLanguage == LanguageManager.sinhala;

    // Calculate better dimensions
    final containerWidth = screenWidth * 0.7; // Slightly smaller container width
    final containerHeight = screenHeight * 0.3; // Compact container height
    final buttonWidth = containerWidth * 0.43; // Slightly smaller to prevent overflow
    final buttonHeight = containerHeight * 0.4; // Taller button (40% of container)

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: containerWidth,
          height: containerHeight,
          padding: EdgeInsets.all(screenWidth * 0.025), // Slightly reduced padding
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Padding(
                padding: EdgeInsets.only(bottom: containerHeight * 0.1),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    LanguageManager.getText('paused').toUpperCase(),
                    style: TextStyle(
                      fontSize: isSinhala ? 28 : 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ),

              // Buttons row with more space between buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // Changed from spaceEvenly to center
                children: [
                  // Resume button
                  SizedBox(
                    width: buttonWidth,
                    height: buttonHeight,
                    child: _buildImageButton(
                      imagePath: isSinhala
                          ? 'assets/images/buttons/resume_sinhala.png'
                          : 'assets/images/buttons/resume_english.png',
                      onPressed: () {
                        game.togglePause();
                      },
                    ),
                  ),

                  SizedBox(width: containerWidth * 0.04), // Add explicit spacing between buttons

                  // Quit button
                  SizedBox(
                    width: buttonWidth,
                    height: buttonHeight,
                    child: _buildImageButton(
                      imagePath: isSinhala
                          ? 'assets/images/buttons/quit_sinhala.png'
                          : 'assets/images/buttons/quit_english.png',
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MenuScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageButton({
    required String imagePath,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}