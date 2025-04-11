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

class floato extends FlameGame with TapDetector, DragCallbacks, HasCollisionDetection {
  late Rocket rocket;
  late Background background;
  late Ground ground;
  late BuildingManager buildingManager;
  late ScoreText scoreText;
  final AudioManager _audioManager = AudioManager();
  final int selectedRocketType;

  // Control zones
  late Rect dragZone;
  late Rect shootZone;
  bool isTouchInDragZone = false;

  floato({this.selectedRocketType = 0});

  // Add pause state variables
  bool isPaused = false;
  bool isGameOver = false;
  // Add tutorial flag
  bool showingTutorial = false;
  // Add countdown flag
  bool showingCountdown = false;
  int score = 0;
  int currentLevelThreshold = 0;

  // Maximum number of objects to track performance
  int _maxEnemyPlanes = 6;
  int _maxBuildings = 10;
  int _maxMissiles = 8;

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

    // Define control zones - left 2/3 for movement, right 1/3 for shooting
    dragZone = Rect.fromLTWH(0, 0, size.x * 0.66, size.y);
    shootZone = Rect.fromLTWH(size.x * 0.66, 0, size.x * 0.34, size.y);

    // Add pause button overlay
    overlays.add('pauseButton');

    // Check if we need to show tutorial
    bool needsTutorial = await PreferencesHelper.hasTutorialBeenSeen();
    if (!needsTutorial) {
      // If tutorial hasn't been seen, pause the game and show tutorial
      showingTutorial = true;
      pauseEngine();
      overlays.add('tutorial');
    } else {
      // If no tutorial needed, show countdown instead
      showCountdown();
    }

    // Initialize difficulty settings based on starting level
    updateDifficultySettings();
  }

  // Show countdown overlay and pause the game
  void showCountdown() {
    showingCountdown = true;
    pauseEngine();
    overlays.add('countdown');
  }

  // Method to be called after countdown completes
  void startGameAfterCountdown() {
    showingCountdown = false;
    resumeEngine();

    // Play a "go" sound if you have one
    _audioManager.playSfx('go.wav');
  }

  // In your game class
  @override
  void update(double dt) {
    if (!isGameOver && !isPaused && !showingTutorial && !showingCountdown) {
      // Apply performance optimization based on current level threshold
      final levelThreshold = _getCurrentLevelThreshold();

      // For higher levels, apply stronger performance management
      if (levelThreshold >= 350) { // Level 4 or 5
        // Limit update rate if dt is too high (indicates slowdown)
        dt = dt.clamp(0.0, 0.04); // Stricter cap than before

        // More frequent object management for higher levels
        manageGameObjects();
      } else if (levelThreshold >= 200) { // Level 3
        // Modest performance optimization
        dt = dt.clamp(0.0, 0.05);

        // Manage objects occasionally
        if (DateTime.now().millisecondsSinceEpoch % 5 == 0) {
          manageGameObjects();
        }
      }
    }
    super.update(dt);
  }

  void manageGameObjects() {
    final levelThreshold = _getCurrentLevelThreshold();

    // Set object limits based on current level
    if (levelThreshold >= 600) { // Level 5
      _maxEnemyPlanes = 4;
      _maxBuildings = 7;
      _maxMissiles = 5;
    } else if (levelThreshold >= 350) { // Level 4
      _maxEnemyPlanes = 5;
      _maxBuildings = 8;
      _maxMissiles = 6;
    } else if (levelThreshold >= 200) { // Level 3
      _maxEnemyPlanes = 6;
      _maxBuildings = 9;
      _maxMissiles = 7;
    } else { // Level 1-2
      _maxEnemyPlanes = 7;
      _maxBuildings = 10;
      _maxMissiles = 8;
    }

    // Limit the number of enemy planes
    final enemies = children.whereType<EnemyPlane>().toList();
    if (enemies.length > _maxEnemyPlanes) {
      // Remove furthest enemies that are off-screen
      enemies.sort((a, b) => b.position.x.compareTo(a.position.x));
      for (int i = _maxEnemyPlanes; i < enemies.length; i++) {
        if (enemies[i].position.x < -enemyPlaneWidth * 1.5 ||
            enemies[i].position.x > size.x + enemyPlaneWidth * 1.5) {
          enemies[i].removeFromParent();
        }
      }
    }

    // Limit the number of buildings
    final buildings = children.whereType<Building>().toList();
    if (buildings.length > _maxBuildings) {
      // Remove furthest buildings that are off-screen
      buildings.sort((a, b) => b.position.x.compareTo(a.position.x));
      for (int i = _maxBuildings; i < buildings.length; i++) {
        if (buildings[i].position.x < -buildingWidth * 1.5) {
          buildings[i].removeFromParent();
        }
      }
    }

    // Limit the number of missiles
    final missiles = children.whereType<Missile>().toList();
    if (missiles.length > _maxMissiles) {
      // Remove oldest missiles
      missiles.sort((a, b) => a.creationTime.compareTo(b.creationTime));
      for (int i = 0; i < missiles.length - _maxMissiles; i++) {
        missiles[i].removeFromParent();
      }
    }

    // Limit the number of explosion effects (new)
    final explosions = children.whereType<Explosion>().toList();
    if (explosions.length > 8) {
      // Remove oldest explosions
      explosions.sort((a, b) => a.creationTime.compareTo(b.creationTime));
      for (int i = 0; i < explosions.length - 8; i++) {
        explosions[i].removeFromParent();
      }
    }
  }

  // Drag event handlers
  @override
  void onDragStart(DragStartEvent event) {
    if (isGameOver || isPaused || showingTutorial || showingCountdown) return;

    final touchPosition = event.canvasPosition;
    isTouchInDragZone = dragZone.contains(Offset(touchPosition.x, touchPosition.y));

    if (isTouchInDragZone) {
      // Start dragging the rocket
      rocket.startDrag(touchPosition);
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (isGameOver || isPaused || showingTutorial || showingCountdown) return;

    if (isTouchInDragZone) {
      // Update rocket position
      rocket.updateDragPosition(event.canvasEndPosition);
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (isGameOver || isPaused || showingTutorial || showingCountdown) return;

    if (isTouchInDragZone) {
      // Stop dragging
      rocket.stopDrag();
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    if (isGameOver || isPaused || showingTutorial || showingCountdown) return;

    if (isTouchInDragZone) {
      // Stop dragging
      rocket.stopDrag();
    }
  }

  @override
  void onTap() {
    // Do nothing - using onTapDown instead for more precise control
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (isGameOver || isPaused || showingTutorial || showingCountdown) return;

    final touchPosition = info.eventPosition.global;
    final isTapInShootZone = shootZone.contains(Offset(touchPosition.x, touchPosition.y));

    // Print debug info
    print('Tap detected in ${isTapInShootZone ? "shoot" : "drag"} zone');

    if (isTapInShootZone) {
      // Right side tap: Shoot if rocket type allows
      print('Attempting to shoot with rocket type: ${rocket.rocketType}');
      if (rocket.rocketType > 0) {
        // Direct call to forcedShoot with simpler logic
        rocket.forcedShoot();
      } else {
        print('Cannot shoot: rocket type is 0');
      }
    } else {
      // Left side tap (used when not dragging): Jump using the old control method
      rocket.flap();
    }
  }

  // Add toggle pause method
  void togglePause() {
    if (isGameOver || showingTutorial || showingCountdown) return;

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

  void onTutorialComplete() {
    print('Tutorial completed');
    showingTutorial = false;
    overlays.remove('tutorial');

    // Save that tutorial has been seen
    PreferencesHelper.saveTutorialSeen(true);

    // Show countdown after tutorial
    showCountdown();
  }

  void incrementScore([int points = 1]) {
    final previousLevel = _getCurrentLevelThreshold();

    // Debug print to verify score increment
    print('Score increasing from $score to ${score + points}');

    // Update score with the specified points
    score += points;

    // Update the score text
    scoreText.text = 'Score: $score';

    final newLevel = _getCurrentLevelThreshold();

    if (newLevel != previousLevel) {
      updateDifficultySettings();
      showLevelUpNotification(newLevel);

      // Provide a small breathing space when reaching a new level
      // by removing some enemies to give player a moment of relief
      if (newLevel >= 200) { // Only for higher levels
        _clearSomeEnemies();
      }
    }
  }

// Add this helper method
  void _clearSomeEnemies() {
    final enemies = children.whereType<EnemyPlane>().toList();
    if (enemies.isNotEmpty) {
      // Remove up to half of the enemies that are close to the player
      final enemiesToRemove = (enemies.length / 2).floor();
      if (enemiesToRemove > 0) {
        // Sort by distance to player (closest first)
        enemies.sort((a, b) {
          final distA = (a.position - rocket.position).length;
          final distB = (b.position - rocket.position).length;
          return distA.compareTo(distB);
        });

        // Remove some of the closest enemies
        for (int i = 0; i < enemiesToRemove; i++) {
          if (i < enemies.length) {
            // Add explosion effect
            final explosion = Explosion(
              position: enemies[i].position,
              size: Vector2(100, 100), // Adjust size as needed for your explosion animation
            );
            add(explosion);

            // Remove enemy
            enemies[i].removeFromParent();
          }
        }
      }
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

    // Update max object limits based on difficulty level
    if (score >= 700) {
      // Level 5 - stricter limits for performance
      _maxEnemyPlanes = 5;
      _maxBuildings = 8;
      _maxMissiles = 6;
    } else if (score >= 450) {
      // Level 4
      _maxEnemyPlanes = 6;
      _maxBuildings = 10;
      _maxMissiles = 8;
    } else {
      // Lower levels - more relaxed limits
      _maxEnemyPlanes = 8;
      _maxBuildings = 12;
      _maxMissiles = 10;
    }
  }

  void showLevelUpNotification(int levelThreshold) {
    final overlay = LevelUpNotification(
      levelName: difficultyLevels[levelThreshold]?['levelName'] ?? 'New Level',
      levelRange: difficultyLevels[levelThreshold]?['levelRange'] ?? '',
    );
    add(overlay);

    // Save the highest level reached
    PreferencesHelper.saveHighestLevel(levelThreshold);
  }

  void handleMissileHit(EnemyPlane enemy, int damage) {
    // Apply damage to enemy
    enemy.takeDamage(damage);

    // The explosion sound and animation are now handled directly in the EnemyPlane class
    // This prevents duplication of sound and animation logic

    // If the enemy is destroyed, the score is incremented in the takeDamage method
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

    // Show countdown before starting the game again
    showCountdown();
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