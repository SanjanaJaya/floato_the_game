import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:floato_the_game/components/background.dart';
import 'package:floato_the_game/components/building_manager.dart';
import 'package:floato_the_game/components/buildinng.dart';
import 'package:floato_the_game/components/rocket.dart';
import 'package:floato_the_game/components/ground.dart';
import 'package:floato_the_game/components/score.dart';
import 'package:floato_the_game/components/enemy_plane.dart';
import 'package:floato_the_game/components/missile.dart';
import 'package:floato_the_game/components/explosion.dart';
import 'package:floato_the_game/constants.dart';
import 'package:flutter/material.dart';
import 'shared_preferences_helper.dart';
import 'menu_screen.dart';
import 'audio_manager.dart';

class floato extends FlameGame with TapDetector, HasCollisionDetection {
  late Rocket rocket;
  late Background background;
  late Ground ground;
  late BuildingManager buildingManager;
  late ScoreText scoreText;
  final AudioManager _audioManager = AudioManager();
  final int selectedRocketType;

  floato({this.selectedRocketType = 0});

  // Add pause state variables
  bool isPaused = false;
  bool isGameOver = false;
  int score = 0;
  int currentLevelThreshold = 0;

  @override
  FutureOr<void> onLoad() async {
    // Print debug info
    print('Game initialized with rocket type: $selectedRocketType');

    // Start background music
    _audioManager.playBackgroundMusic();

    background = Background(size);
    add(background);

    rocket = Rocket(rocketType: selectedRocketType);
    add(rocket);

    ground = Ground();
    add(ground);

    buildingManager = BuildingManager();
    add(buildingManager);

    scoreText = ScoreText();
    add(scoreText);

    // Add pause button overlay
    overlays.add('pauseButton');

    // Initialize difficulty settings based on starting level
    updateDifficultySettings();
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void onTap() {
    // Do nothing - using onTapDown instead for more precise control
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (isGameOver || isPaused) return;

    // Check if tap is on left or right side of screen
    // Using global position since game position isn't available
    bool isTapOnLeftSide = info.eventPosition.global.x < size.x / 2;

    // Print debug info
    print('Tap detected on ${isTapOnLeftSide ? "left" : "right"} side');

    if (isTapOnLeftSide) {
      // Left side tap: Jump
      rocket.flap();
    } else {
      // Right side tap: Shoot if rocket type allows
      print('Attempting to shoot with rocket type: ${rocket.rocketType}');
      if (rocket.rocketType > 0) {
        // Direct call to forcedShoot with simpler logic
        rocket.forcedShoot();
      } else {
        print('Cannot shoot: rocket type is 0');
      }
    }
  }

  // Add toggle pause method
  void togglePause() {
    if (isGameOver) return;

    if (isPaused) {
      // Resume the game
      resumeEngine();
      isPaused = false;
      overlays.remove('pauseMenu');

      // Resume background music
      _audioManager.resumeBackgroundMusic();
    } else {
      // Pause the game
      pauseEngine();
      isPaused = true;
      overlays.add('pauseMenu');

      // Pause music (optional)
      _audioManager.stopBackgroundMusic();
    }
  }

  void incrementScore() {
    final previousLevel = _getCurrentLevelThreshold();
    score += 1;
    final newLevel = _getCurrentLevelThreshold();

    // Update the score text without calling updateScore
    scoreText.text = 'Score: $score';

    if (newLevel != previousLevel) {
      updateDifficultySettings();
      showLevelUpNotification(newLevel);
    }
  }

  int _getCurrentLevelThreshold() {
    final thresholds = difficultyLevels.keys.toList()..sort((a, b) => b.compareTo(a));
    for (final threshold in thresholds) {
      if (score >= threshold) {
        return threshold;
      }
    }
    return 0;
  }

  String getCurrentLevelName() {
    return difficultyLevels[_getCurrentLevelThreshold()]?['levelName'] ?? 'Level 1';
  }

  String getCurrentLevelRange() {
    return difficultyLevels[_getCurrentLevelThreshold()]?['levelRange'] ?? '0-50';
  }

  // Get the enemy speed multiplier based on current level
  double getEnemySpeedMultiplier() {
    return difficultyLevels[_getCurrentLevelThreshold()]?['enemySpeedMultiplier'] ?? 1.0;
  }

  // Calculate enemy plane speed based on plane type and current level
  double getEnemyPlaneSpeed(int planeType) {
    final baseSpeed = enemyPlaneSpeeds[planeType % enemyPlaneSpeeds.length];
    final multiplier = getEnemySpeedMultiplier();
    return baseSpeed * multiplier;
  }

  void updateDifficultySettings() {
    final settings = difficultyLevels[_getCurrentLevelThreshold()]!;
    buildingManager.updateDifficulty(
      buildingInterval: settings['buildingInterval'],
      enemySpawnInterval: settings['enemySpawnInterval'],
    );
    ground.updateScrollingSpeed(settings['groundScrollingSpeed']);

    // Update speeds of existing enemy planes
    children.whereType<EnemyPlane>().forEach((enemy) {
      enemy.updateSpeed(getEnemyPlaneSpeed(enemy.planeType));
    });
  }

  void showLevelUpNotification(int levelThreshold) {
    final overlay = LevelUpNotification(
      levelName: difficultyLevels[levelThreshold]?['levelName'] ?? 'New Level',
      levelRange: difficultyLevels[levelThreshold]?['levelRange'] ?? '',
    );
    add(overlay);

    // Play level up sound effect
    _audioManager.playSfx('button_click.wav');

    // Save the highest level reached
    PreferencesHelper.saveHighestLevel(levelThreshold);
  }

  void handleMissileHit(EnemyPlane enemy, int damage) {
    // Apply damage to enemy
    enemy.takeDamage(damage);

    // Check if enemy is destroyed
    if (enemy.health <= 0) {
      // Play explosion sound
      _audioManager.playSfx('explosion.wav');

      // Create explosion animation
      final explosion = Explosion(
        position: enemy.position,
        size: Vector2(80, 80),
      );
      add(explosion);

      // Increment score
      incrementScore();
    }
  }

  void gameOver() {
    if (isGameOver) return;

    isGameOver = true;
    pauseEngine();

    // Save high score
    PreferencesHelper.saveHighScore(score);

    // Save highest level threshold
    PreferencesHelper.saveHighestLevel(_getCurrentLevelThreshold());

    // Remove pause menu if it's showing
    if (overlays.isActive('pauseMenu')) {
      overlays.remove('pauseMenu');
    }

    // Play crash sound and stop background music
    _audioManager.playSfx('crash.wav');
    _audioManager.stopBackgroundMusic();

    showDialog(
      context: buildContext!,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        backgroundColor: Colors.blueGrey[900],
        elevation: 20,
        title: const Text(
          "Game Over",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arial',
          ),
        ),
        content: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blueGrey[800],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Score: $score",
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${getCurrentLevelName()} (${getCurrentLevelRange()})",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          // Replace the Row with a Column to stack buttons vertically
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 200, // Fixed width for both buttons
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.orange, Colors.red],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _audioManager.playButtonClick();
                    resetGame();
                  },
                  child: const Text(
                    "Play Again",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 200, // Fixed width for both buttons
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    _audioManager.playButtonClick();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MenuScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Back to Menu",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void resetGame() {
    rocket.position = Vector2(rocketStartX, rocketStartY);
    rocket.velocity = 0;
    score = 0;
    isGameOver = false;

    // Reset score text
    scoreText.text = 'Score: 0';

    // Reset pause state if game was paused
    if (isPaused) {
      isPaused = false;
      overlays.remove('pauseMenu');
    }

    // Clean up game components
    children.whereType<Building>().forEach((building) => building.removeFromParent());
    children.whereType<EnemyPlane>().forEach((enemy) => enemy.removeFromParent());
    children.whereType<LevelUpNotification>().forEach((notification) => notification.removeFromParent());
    children.whereType<Missile>().forEach((missile) => missile.removeFromParent());
    children.whereType<Explosion>().forEach((explosion) => explosion.removeFromParent());

    // Reset to Level 1 difficulty
    updateDifficultySettings();

    // Resume background music
    _audioManager.resumeBackgroundMusic();

    if (paused) {
      resumeEngine();
    }
  }

  @override
  void onRemove() {
    // Clean up resources when game is removed
    _audioManager.stopBackgroundMusic();
    super.onRemove();
  }

  // Method to toggle audio
  void toggleAudio() {
    _audioManager.toggleMute();
  }

  // Check if audio is muted
  bool isAudioMuted() {
    return _audioManager.isMuted;
  }
}

class LevelUpNotification extends Component with HasGameRef<floato> {
  final String levelName;
  final String levelRange;
  Timer? _timer;

  LevelUpNotification({
    required this.levelName,
    required this.levelRange,
  });

  @override
  Future<void> onLoad() async {
    _timer = Timer(2.5, onTick: () => removeFromParent());
  }

  @override
  void render(Canvas canvas) {
    final text = TextPainter(
      text: TextSpan(
        text: '$levelName REACHED!\n$levelRange',
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 10,
              color: Colors.black,
              offset: Offset(2, 2),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    text.paint(
      canvas,
      Offset(
        (gameRef.size.x - text.width) / 2,
        gameRef.size.y / 3,
      ),
    );
  }

  @override
  void update(double dt) {
    _timer?.update(dt);
    super.update(dt);
  }

  @override
  void onRemove() {
    _timer?.stop();
    super.onRemove();
  }
}