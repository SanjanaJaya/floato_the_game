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
    final mediaQuery = MediaQuery.of(context);
    final padding = mediaQuery.padding;
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/menu_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
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
                text: LanguageManager.getText('startGame'),
                width: buttonWidth,
                height: buttonHeight,
                gradient: LinearGradient(
                  colors: [Colors.orange.shade700, Colors.orange.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
                text: LanguageManager.getText('selectBird'),
                width: buttonWidth,
                height: buttonHeight,
                gradient: LinearGradient(
                  colors: [Colors.green.shade700, Colors.green.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onPressed: () {
                  setState(() {
                    showRocketSelection = true;
                  });
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildMenuButton(
                text: LanguageManager.getText('developers'),
                width: buttonWidth,
                height: buttonHeight,
                gradient: LinearGradient(
                  colors: [Colors.blueGrey.shade700, Colors.blueGrey.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
    required String text,
    required double width,
    required double height,
    required Gradient gradient,
    required VoidCallback onPressed,
    double fontSize = 24,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: gradient,
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
            child: Text(
              text,
              style: TextStyle(
                fontSize: width * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.black45,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
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
                  LanguageManager.getText('Nethsara Werasooriya'),
                  LanguageManager.getText('Anjana Herath'),
                  LanguageManager.getText('Nethmina Medagedara'),
                  LanguageManager.getText('Dinuwara Wijerathne'),
                  LanguageManager.getText('Kavindu Heshan'),
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
                text: LanguageManager.getText('back'),
                width: screenWidth * 0.5,
                height: screenHeight * 0.07,
                gradient: LinearGradient(
                  colors: [Colors.blueGrey.shade700, Colors.blueGrey.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
              height: screenHeight * 0.5,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: screenWidth * 0.03,
                  mainAxisSpacing: screenWidth * 0.03,
                ),
                itemCount: 8,
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
                                    Icon(
                                      Icons.lock,
                                      color: Colors.white,
                                      size: screenWidth * 0.08,
                                    ),
                                ],
                              ),
                            ),
                          ),
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
              text: LanguageManager.getText('back'),
              width: screenWidth * 0.5,
              height: screenHeight * 0.07,
              gradient: LinearGradient(
                colors: [Colors.blueGrey.shade700, Colors.blueGrey.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onPressed: () {
                setState(() {
                  showRocketSelection = false;
                });
              },
            ),
          ],
        ),
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

    return Center(
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.05),
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.8,
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
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                LanguageManager.getText('paused').toUpperCase(),
                style: TextStyle(
                  fontSize: LanguageManager.currentLanguage == LanguageManager.sinhala
                      ? screenWidth * 0.07
                      : screenWidth * 0.09,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 20,
              children: [
                _buildPauseMenuButton(
                  text: LanguageManager.getText('resume'),
                  color: Colors.green,
                  onPressed: () {
                    game.togglePause();
                  },
                  width: screenWidth * 0.3,
                  height: screenHeight * 0.06,
                ),
                _buildPauseMenuButton(
                  text: LanguageManager.getText('quit'),
                  color: Colors.red,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MenuScreen(),
                      ),
                    );
                  },
                  width: screenWidth * 0.3,
                  height: screenHeight * 0.06,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPauseMenuButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
    required double width,
    required double height,
  }) {
    return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
    gradient: LinearGradient(
    colors: [color.withOpacity(0.8), color],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    ),
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
    child: Text(
    text,
    style: TextStyle(
    fontSize: width * 0.12,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: const [
    Shadow(
    blurRadius: 4,
    color: Colors.black45,
    offset: Offset(1, 1),
    ),
    ],
    ),
    ),
    ),
    ),
    ),
    );
  }
}