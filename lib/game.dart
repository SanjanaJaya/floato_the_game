import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
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
import 'package:floato_the_game/components/coin_manager.dart';
import 'package:floato_the_game/components/ability_indicator.dart';
import 'package:floato_the_game/coin_display.dart';
import 'package:floato_the_game/coin.dart';
import 'package:floato_the_game/constants.dart';
import 'package:floato_the_game/level_up_notification.dart';
import 'package:floato_the_game/components/vehicle_manager.dart';
import 'package:floato_the_game/vehicle.dart';
import 'package:flutter/material.dart';
import 'shared_preferences_helper.dart';
import 'menu_screen.dart';
import 'audio_manager.dart';
import 'special_ability.dart';
import 'main.dart';
import 'package:floato_the_game/language_manager.dart';

// Add these constants at the top of the file
const double baseWidth = 360.0; // Base width for reference (e.g., iPhone SE)
const double baseHeight = 640.0; // Base height for reference

class floato extends FlameGame with TapDetector, DragCallbacks, HasCollisionDetection {
  late Rocket rocket;
  late Background background;
  late Ground ground;
  late BuildingManager buildingManager;
  late ScoreText scoreText;
  late CoinDisplay coinDisplay;
  final AudioManager _audioManager = AudioManager();
  final int selectedRocketType;

  // Add this at the top of the floato class
  bool _assetsLoaded = false;

  // Control zones
  late Rect dragZone;
  late Rect shootZone;
  bool isTouchInDragZone = false;

  floato({this.selectedRocketType = 0});

  // Game state variables
  bool isPaused = false;
  bool isGameOver = false;
  bool showingTutorial = false;
  bool showingCountdown = false;
  int score = 0;
  int currentLevelThreshold = 0;

  // Coin related variables
  int coins = 0;
  late CoinManager coinManager;
  late VehicleManager vehicleManager;

  // Performance management
  int _maxEnemyPlanes = 6;
  int _maxBuildings = 10;
  int _maxMissiles = 8;

  // Ability system variables
  Timer? _abilityTimer;
  AbilityType? currentAbility;
  double _abilityDuration = 0;

  // Performance monitoring
  final List<double> _fpsHistory = [];
  static const int _fpsHistoryMaxSize = 30; // Track last 30 frames
  static const double _lowFpsThreshold = 40.0; // FPS below this is considered low performance
  int _lastPerformanceCheckTime = 0;
  int _lastAudioProcessTime = 0;
  static const int _audioProcessInterval = 100; // Process audio less frequently

  // Add scaling factors
  double get scaleFactor => size.x / baseWidth;
  double get heightScaleFactor => size.y / baseHeight;

  // Add this to the floato class
  double get abilityDuration => _abilityDuration;

  // Update the onLoad method to check for preloaded assets
  @override
  FutureOr<void> onLoad() async {
    print('Game initialized with rocket type: $selectedRocketType');
    // Check if assets are preloaded
    if (!_assetsLoaded) {
      try {
        await Flame.images.ready(); // Wait for all images to be loaded
        _assetsLoaded = true;
      } catch (e) {
        print('Error loading assets: $e');
        // Handle error or proceed with loading assets on demand
      }
    }
    // Start background music
    _audioManager.playBackgroundMusic();
    // Initialize coins
    coins = await PreferencesHelper.getCoins();
    coinManager = CoinManager();
    add(coinManager);
    background = Background(size);
    add(background);
    rocket = Rocket(rocketType: selectedRocketType);
    add(rocket);
    ground = Ground();
    add(ground);
    vehicleManager = VehicleManager();
    add(vehicleManager);
    buildingManager = BuildingManager();
    add(buildingManager);
    scoreText = ScoreText();
    add(scoreText);
    // Initialize coin display with image
    coinDisplay = CoinDisplay();
    add(coinDisplay);
    // Define responsive control zones
    dragZone = Rect.fromLTWH(0, 0, size.x * 0.66, size.y);
    shootZone = Rect.fromLTWH(size.x * 0.66, 0, size.x * 0.34, size.y);
    // Add pause button overlay
    overlays.add('pauseButton');
    add(AbilityIndicator());
    // Check if tutorial is needed
    bool needsTutorial = await PreferencesHelper.hasTutorialBeenSeen();
    if (!needsTutorial) {
      showingTutorial = true;
      pauseEngine();
      overlays.add('tutorial');
    } else {
      showCountdown();
    }
    // Initialize difficulty settings
    updateDifficultySettings();
  }

  void incrementCoins(int amount) {
    coins += amount;
    PreferencesHelper.saveCoins(coins);
    coinDisplay.updateCoins(coins);
  }

  void checkCoinCollisions() {
    final coins = children.whereType<Coin>().toList();
    int coinsCollected = 0;

    for (final coin in coins) {
      if (rocket.toRect().overlaps(coin.toRect())) {
        incrementCoins(coin.value);
        coin.collect();
        coinsCollected++;
      }
    }

    if (coinsCollected > 0) {
      _audioManager.playSfx('coin_collect.ogg');
    }
  }

  void checkAbilityCollisions() {
    final abilities = children.whereType<SpecialAbility>().toList();
    for (final ability in abilities) {
      if (rocket.toRect().overlaps(ability.toRect())) {
        activateAbility(ability.type);
        ability.removeFromParent();
      }
    }
  }

  void showCountdown() {
    showingCountdown = true;
    pauseEngine();
    overlays.add('countdown');
  }

  void startGameAfterCountdown() {
    showingCountdown = false;
    resumeEngine();
    _audioManager.playSfx('go.ogg');
  }

  void spawnRandomAbility() {
    if (currentAbility != null) return; // Don't spawn if ability is active

    final random = Random();
    if (random.nextDouble() < 0.01) { // 1% chance per frame
      final abilityType = AbilityType.values[random.nextInt(AbilityType.values.length)];
      final yPos = random.nextDouble() * (size.y - 100) + 50;

      final ability = SpecialAbility(
        position: Vector2(size.x, yPos),
        type: abilityType,
      );
      add(ability);
    }
  }

  void activateAbility(AbilityType type) {
    currentAbility = type;
    _audioManager.playSfx('ability_collected.ogg');

    // Update rocket's glow effect
    rocket.updateGlowEffect(type);

    switch (type) {
      case AbilityType.doubleScore:
        _abilityDuration = 10.0;
        break;
      case AbilityType.invincibility:
        _abilityDuration = 8.0;
        break;
      case AbilityType.slowMotion:
        _abilityDuration = 12.0;
        break;
      case AbilityType.rapidFire:
        _abilityDuration = 15.0;
        // Reset shooting cooldown for all rockets during rapid fire
        if (rocket.rocketType == 0) {
          rocket.shootingCooldown = 0.1; // Very fast for Skye
        } else {
          rocket.shootingCooldown = 0.2; // Fast for other rockets too
        }
        rocket.canShoot = true; // Make sure we can shoot immediately
        break;
    }

    _abilityTimer = Timer(_abilityDuration, onTick: () {
      // Clean up when ability expires
      currentAbility = null;
      _abilityTimer = null;
      // Reset cooldowns
      rocket.shootingCooldown = 0.5;
      if (rocket.rocketType == 0) {
        rocket.canShoot = false;
      }
      // Remove glow effect when ability ends
      rocket.updateGlowEffect(null);
    });
  }

  void updateAbilityTimer(double dt) {
    if (_abilityTimer != null) {
      _abilityTimer!.update(dt);
      _abilityDuration -= dt;
    }
  }

  @override
  void update(double dt) {
    if (!isGameOver && !isPaused) {
      // Performance monitoring - add FPS to history
      if (dt > 0) {
        final fps = 1 / dt;
        _fpsHistory.add(fps);
        if (_fpsHistory.length > _fpsHistoryMaxSize) {
          _fpsHistory.removeAt(0);
        }

        // Check performance and update audio settings when needed
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - _lastPerformanceCheckTime > 2000) { // Check every 2 seconds
          _lastPerformanceCheckTime = now;
          _updatePerformanceSettings();
        }

        // Process audio queue less frequently
        if (now - _lastAudioProcessTime > _audioProcessInterval) {
          _audioManager.processSoundQueue();
          _lastAudioProcessTime = now;
        }
      }

      spawnRandomAbility();
      updateAbilityTimer(dt);

      // Batch collision checks on a schedule
      _batchCollisionChecks();

      // Apply slow motion effect if active
      if (currentAbility == AbilityType.slowMotion) {
        dt *= 0.5; // Slow time to half speed
      }

      final levelThreshold = _getCurrentLevelThreshold();

      // Performance optimization based on level
      if (levelThreshold >= 350) {
        dt = dt.clamp(0.0, 0.04);
        manageGameObjects();
      } else if (levelThreshold >= 200) {
        dt = dt.clamp(0.0, 0.05);
        if (DateTime.now().millisecondsSinceEpoch % 5 == 0) {
          manageGameObjects();
        }
      }
    }
    super.update(dt);
  }

  // Batch collision checks instead of checking each frame
  void _batchCollisionChecks() {
    // Check if we're in a performance-critical situation
    final isPerformanceCritical = _isPerformanceCritical();

    // Use time-based throttling for collision checks
    final now = DateTime.now().millisecondsSinceEpoch;

    // Skip frequent checks during performance issues
    if (isPerformanceCritical && now % 3 != 0) {
      return;
    }

    checkCoinCollisions();
    checkAbilityCollisions();
  }

  // Check if game is in a performance-critical state
  bool _isPerformanceCritical() {
    if (_fpsHistory.length < 5) return false;

    // Calculate average recent FPS
    double sum = 0;
    for (int i = _fpsHistory.length - 5; i < _fpsHistory.length; i++) {
      sum += _fpsHistory[i];
    }
    final avgFps = sum / 5;

    return avgFps < _lowFpsThreshold;
  }

  // Update performance settings with improved audio handling
  void _updatePerformanceSettings() {

    if (_fpsHistory.length < 10) return;

    // Calculate average FPS with more weight on recent frames
    double sum = 0;
    double weight = 0;
    for (int i = 0; i < _fpsHistory.length; i++) {
      // More weight to recent frames (last 5 frames are most important)
      double frameWeight = i >= _fpsHistory.length - 5 ? 1.5 : 1.0;
      sum += _fpsHistory[i] * frameWeight;
      weight += frameWeight;
    }
    final avgFps = sum / weight;

    // Update audio manager performance mode
    final shouldBeInLowPerfMode = avgFps < _lowFpsThreshold;

    if (shouldBeInLowPerfMode != _audioManager.isLowPerfMode) {
      _audioManager.setLowPerformanceMode(shouldBeInLowPerfMode);
      print('Audio performance mode changed: Low Performance = $shouldBeInLowPerfMode (FPS: $avgFps)');

      // More aggressive object management during performance issues
      if (shouldBeInLowPerfMode) {
        _clearSomeElements();
      }
    }
  }

  // Clear elements to improve performance
  void _clearSomeElements() {
    // First, clear non-essential sounds
    _audioManager.processSoundQueue(); // Process and clear pending queue

    // Clear less important visual elements
    final explosions = children.whereType<Explosion>().toList();
    if (explosions.length > 2) {
      for (int i = 0; i < explosions.length - 2; i++) {
        explosions[i].removeFromParent();
      }
    }

    // Clear coins that are far from the player
    final coins = children.whereType<Coin>().toList();
    if (coins.length > 5) {
      coins.sort((a, b) {
        final distA = (a.position - rocket.position).length;
        final distB = (b.position - rocket.position).length;
        return distB.compareTo(distA); // Sort descending to remove furthest
      });

      for (int i = 0; i < coins.length - 5; i++) {
        coins[i].removeFromParent();
      }
    }
  }

  void manageGameObjects() {
    // Scale object limits based on screen size
    final scaledMaxEnemyPlanes = (_maxEnemyPlanes * scaleFactor).round();
    final scaledMaxBuildings = (_maxBuildings * scaleFactor).round();
    final scaledMaxMissiles = (_maxMissiles * scaleFactor).round();

    final levelThreshold = _getCurrentLevelThreshold();
    final isPerformanceCritical = _isPerformanceCritical();

    // Make more aggressive limits during performance issues
    if (isPerformanceCritical) {
      _maxEnemyPlanes = (_maxEnemyPlanes * 0.7).floor();
      _maxBuildings = (_maxBuildings * 0.7).floor();
      _maxMissiles = (_maxMissiles * 0.7).floor();
    }

    // Set object limits based on current level
    if (levelThreshold >= 600) {
      _maxEnemyPlanes = 4;
      _maxBuildings = 7;
      _maxMissiles = 5;
    } else if (levelThreshold >= 350) {
      _maxEnemyPlanes = 5;
      _maxBuildings = 8;
      _maxMissiles = 6;
    } else if (levelThreshold >= 200) {
      _maxEnemyPlanes = 6;
      _maxBuildings = 9;
      _maxMissiles = 7;
    } else {
      _maxEnemyPlanes = 7;
      _maxBuildings = 10;
      _maxMissiles = 8;
    }

    // Limit enemy planes
    final enemies = children.whereType<EnemyPlane>().toList();
    if (enemies.length > scaledMaxEnemyPlanes) {
      enemies.sort((a, b) => b.position.x.compareTo(a.position.x));
      for (int i = scaledMaxEnemyPlanes; i < enemies.length; i++) {
        if (enemies[i].position.x < -enemyPlaneWidth * 1.5 ||
            enemies[i].position.x > size.x + enemyPlaneWidth * 1.5) {
          enemies[i].removeFromParent();
        }
      }
    }

    // Limit buildings
    final buildings = children.whereType<Building>().toList();
    if (buildings.length > scaledMaxBuildings) {
      buildings.sort((a, b) => b.position.x.compareTo(a.position.x));
      for (int i = scaledMaxBuildings; i < buildings.length; i++) {
        if (buildings[i].position.x < -buildingWidth * 1.5) {
          buildings[i].removeFromParent();
        }
      }
    }

    // Limit missiles
    final missiles = children.whereType<Missile>().toList();
    if (missiles.length > scaledMaxMissiles) {
      missiles.sort((a, b) => a.creationTime.compareTo(b.creationTime));
      for (int i = 0; i < missiles.length - scaledMaxMissiles; i++) {
        missiles[i].removeFromParent();
      }
    }

    // Limit explosions
    final explosions = children.whereType<Explosion>().toList();
    if (explosions.length > 8) {
      explosions.sort((a, b) => a.creationTime.compareTo(b.creationTime));
      for (int i = 0; i < explosions.length - 8; i++) {
        explosions[i].removeFromParent();
      }
    }

    // Limit vehicles
    final vehicles = children.whereType<Vehicle>().toList();
    if (vehicles.length > 3) {
      vehicles.sort((a, b) => b.position.x.compareTo(a.position.x));
      for (int i = 3; i < vehicles.length; i++) {
        if (vehicles[i].position.x < -vehicleWidth || vehicles[i].position.x > size.x + vehicleWidth) {
          vehicles[i].removeFromParent();
        }
      }
    }
  }

  // Input handling methods
  @override
  void onDragStart(DragStartEvent event) {
    if (isGameOver || isPaused || showingTutorial || showingCountdown) return;

    final touchPosition = event.canvasPosition;
    isTouchInDragZone = dragZone.contains(Offset(touchPosition.x, touchPosition.y));

    if (isTouchInDragZone) {
      rocket.startDrag(touchPosition);
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (isGameOver || isPaused || showingTutorial || showingCountdown) return;

    if (isTouchInDragZone) {
      rocket.updateDragPosition(event.canvasEndPosition);
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (isGameOver || isPaused || showingTutorial || showingCountdown) return;

    if (isTouchInDragZone) {
      rocket.stopDrag();
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    if (isGameOver || isPaused || showingTutorial || showingCountdown) return;

    if (isTouchInDragZone) {
      rocket.stopDrag();
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (isGameOver || isPaused || showingTutorial || showingCountdown) return;

    final touchPosition = info.eventPosition.global;
    final isTapInShootZone = shootZone.contains(Offset(touchPosition.x, touchPosition.y));

    if (isTapInShootZone) {
      if (rocket.rocketType > 0 || currentAbility == AbilityType.rapidFire) {
        rocket.forcedShoot();
      }
    } else {
      rocket.flap();
    }
  }

  void togglePause() {
    if (isGameOver || showingTutorial || showingCountdown) return;

    if (isPaused) {
      resumeEngine();
      isPaused = false;
      overlays.remove('pauseMenu');
      _audioManager.resume();
    } else {
      pauseEngine();
      isPaused = true;
      overlays.add('pauseMenu');
      _audioManager.pause();
    }
  }

  void onTutorialComplete() {
    showingTutorial = false;
    overlays.remove('tutorial');
    PreferencesHelper.saveTutorialSeen(true);
    showCountdown();
  }

  void incrementScore([int points = 1]) {
    final previousLevel = _getCurrentLevelThreshold();

    // Apply score multiplier if double score ability is active
    final multiplier = currentAbility == AbilityType.doubleScore ? 2 : 1;
    score += points * multiplier;

    scoreText.text = 'Score: $score';

    final newLevel = _getCurrentLevelThreshold();

    if (newLevel != previousLevel) {
      updateDifficultySettings();
      showLevelUpNotification(newLevel, background.currentEnvironmentName);

      if (newLevel >= 200) {
        _clearSomeEnemies();
      }
    }
  }

  void _clearSomeEnemies() {
    final enemies = children.whereType<EnemyPlane>().toList();
    if (enemies.isNotEmpty) {
      final enemiesToRemove = (enemies.length / 2).floor();
      if (enemiesToRemove > 0) {
        enemies.sort((a, b) {
          final distA = (a.position - rocket.position).length;
          final distB = (b.position - rocket.position).length;
          return distA.compareTo(distB);
        });

        for (int i = 0; i < enemiesToRemove; i++) {
          if (i < enemies.length) {
            add(Explosion(
              position: enemies[i].position,
              size: Vector2(100, 100),
            ));
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

  double getEnemySpeedMultiplier() {
    double baseMultiplier = difficultyLevels[_getCurrentLevelThreshold()]?['enemySpeedMultiplier'] ?? 1.0;

    // Apply slow motion effect if active
    if (currentAbility == AbilityType.slowMotion) {
      baseMultiplier *= 0.5; // Half speed during slow motion
    }

    return baseMultiplier;
  }

  double getEnemyPlaneSpeed(int planeType) {
    final baseSpeed = enemyPlaneSpeeds[planeType % enemyPlaneSpeeds.length];
    final multiplier = getEnemySpeedMultiplier();
    return baseSpeed * multiplier;
  }

  void updateDifficultySettings() {
    final levelThreshold = _getCurrentLevelThreshold();
    final settings = difficultyLevels[levelThreshold]!;

    // Update background and ground
    background.updateBackground(levelThreshold);
    ground.updateGround(levelThreshold);

    buildingManager.updateDifficulty(
      buildingInterval: settings['buildingInterval'],
      enemySpawnInterval: settings['enemySpawnInterval'],
    );
    ground.updateScrollingSpeed(settings['groundScrollingSpeed']);

    // Update existing enemies
    children.whereType<EnemyPlane>().forEach((enemy) {
      enemy.updateSpeed(getEnemyPlaneSpeed(enemy.planeType));
    });

    // Update performance limits
    if (score >= 700) {
      _maxEnemyPlanes = 5;
      _maxBuildings = 8;
      _maxMissiles = 6;
    } else if (score >= 450) {
      _maxEnemyPlanes = 6;
      _maxBuildings = 10;
      _maxMissiles = 8;
    } else {
      _maxEnemyPlanes = 8;
      _maxBuildings = 12;
      _maxMissiles = 10;
    }
  }

  void showLevelUpNotification(int levelThreshold, String environmentName) {
    final overlay = LevelUpNotification(
      levelName: difficultyLevels[levelThreshold]?['levelName'] ?? 'New Level',
      levelRange: difficultyLevels[levelThreshold]?['levelRange'] ?? '',
      environmentName: environmentName,
    );
    add(overlay);
    PreferencesHelper.saveHighestLevel(levelThreshold);
  }

  void handleMissileHit(EnemyPlane enemy, int damage) {
    enemy.takeDamage(damage);
  }

  void gameOver() {
    // If invincibility is active, prevent game over
    if (currentAbility == AbilityType.invincibility) {
      return;
    }

    if (isGameOver) return;

    isGameOver = true;
    pauseEngine();

    PreferencesHelper.saveHighScore(score);
    PreferencesHelper.saveHighestLevel(_getCurrentLevelThreshold());

    if (overlays.isActive('pauseMenu')) {
      overlays.remove('pauseMenu');
    }

    _audioManager.stopBackgroundMusic();
    _audioManager.processSoundQueue();
    _audioManager.playCrashSound();

    // Show interstitial ad
    AdManager.showInterstitialAd();

    showDialog(
      context: buildContext!,
      barrierDismissible: false,
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final screenWidth = mediaQuery.size.width;
        final screenHeight = mediaQuery.size.height;

        // Calculate responsive sizes
        final dialogWidth = screenWidth * 0.9; // 90% of screen width
        final dialogMaxWidth = 500.0; // Maximum width for very large screens

        // Increased button widths
        final buttonWidth = screenWidth * 0.5; // Increased from 0.4 to 0.5 (50% of screen width)
        final buttonMaxWidth = 240.0; // Increased from 200.0 to 240.0

        final fontSizeMultiplier = screenWidth < 400 ? 0.8 : 1.0;

        // Get localized text
        final gameOverText = LanguageManager.getText('gameOver');
        final scoreText = LanguageManager.getText('Score:');
        final environmentText = LanguageManager.getText('environment');
        final coinsCollectedText = LanguageManager.getText('coinsCollected');

        // Get environment name translated
        final translatedEnvironmentName = LanguageManager.getEnvironmentName(background.currentEnvironmentName);

        // Use text direction from language manager
        final textDirection = LanguageManager.getTextDirection();

        // Determine which language button images to use
        final bool isSinhala = textDirection == TextDirection.rtl ||
            LanguageManager.getText('language_code') == 'si';

        final String playAgainImagePath = isSinhala ?
        'assets/images/buttons/playagain_sinhala.png' : 'assets/images/buttons/playagain_english.png';
        final String quitImagePath = isSinhala ?
        'assets/images/buttons/quit_sinhala.png' : 'assets/images/buttons/quit_english.png';

        return Directionality(
          textDirection: textDirection,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: mediaQuery.padding.bottom,
            ),
            child: AlertDialog(
              insetPadding: EdgeInsets.symmetric(
                horizontal: max(16, (screenWidth - min(dialogWidth, dialogMaxWidth)) / 2),
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              backgroundColor: Colors.blueGrey[900],
              elevation: 20,
              title: Text(
                gameOverText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30 * fontSizeMultiplier,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Arial',
                ),
              ),
              content: SingleChildScrollView(
                child: Container(
                  width: min(dialogWidth, dialogMaxWidth),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[800],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$scoreText $score",
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 24 * fontSizeMultiplier,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "${LanguageManager.getText(getCurrentLevelName())} (${getCurrentLevelRange()})",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20 * fontSizeMultiplier,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "$environmentText: $translatedEnvironmentName",
                        style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 18 * fontSizeMultiplier,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "$coinsCollectedText: $coins",
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 18 * fontSizeMultiplier,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Play Again button with image - larger size, no shadow
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        resetGame();
                      },
                      child: Container(
                        width: min(buttonWidth, buttonMaxWidth),
                        height: min(60, screenHeight * 0.1), // Increased height from 50 to 60
                        margin: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          // Shadow removed
                        ),
                        child: Image.asset(
                          playAgainImagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Quit button with image - larger size, no shadow
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MenuScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: min(buttonWidth, buttonMaxWidth),
                        height: min(60, screenHeight * 0.1), // Increased height from 50 to 60
                        margin: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          // Shadow removed
                        ),
                        child: Image.asset(
                          quitImagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void resetGame() {
    // Don't reset coins here - they should persist between games
    rocket.position = Vector2(rocketStartX, rocketStartY);
    rocket.velocity = 0;
    score = 0;
    isGameOver = false;

    // Reset ability state
    currentAbility = null;
    _abilityTimer = null;
    _abilityDuration = 0;

    scoreText.text = 'Score: 0';
    coinDisplay.updateCoins(coins); // Update coin display with current coins

    if (isPaused) {
      isPaused = false;
      overlays.remove('pauseMenu');
    }

    // Clean up game elements
    children.whereType<Building>().forEach((building) => building.removeFromParent());
    children.whereType<EnemyPlane>().forEach((enemy) => enemy.removeFromParent());
    children.whereType<LevelUpNotification>().forEach((notification) => notification.removeFromParent());
    children.whereType<Missile>().forEach((missile) => missile.removeFromParent());
    children.whereType<Explosion>().forEach((explosion) => explosion.removeFromParent());
    children.whereType<Coin>().forEach((coin) => coin.removeFromParent());
    children.whereType<SpecialAbility>().forEach((ability) => ability.removeFromParent());
    children.whereType<Vehicle>().forEach((vehicle) => vehicle.removeFromParent());

    // Reset fps tracking
    _fpsHistory.clear();
    _lastPerformanceCheckTime = DateTime.now().millisecondsSinceEpoch;
    _lastAudioProcessTime = _lastPerformanceCheckTime;

    updateDifficultySettings();
    _audioManager.resumeBackgroundMusic();

    if (paused) {
      resumeEngine();
    }

    showCountdown();
  }

  @override
  void onRemove() {
    // Ensure audio resources are properly disposed
    _audioManager.dispose();
    super.onRemove();
  }

  // Add this method to clean up resources when game is paused for a long time
  void cleanupResources() {
    _fpsHistory.clear();
    _audioManager.dispose();
  }

  void toggleAudio() {
    _audioManager.toggleMute();
  }

  bool isAudioMuted() {
    return _audioManager.isMuted;
  }
}