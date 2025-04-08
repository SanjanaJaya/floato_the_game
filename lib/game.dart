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
import 'package:floato_the_game/constants.dart';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'menu_screen.dart';

class floato extends FlameGame with TapDetector, HasCollisionDetection {
  late Rocket rocket;
  late Background background;
  late Ground ground;
  late BuildingManager buildingManager;
  late ScoreText scoreText;

  @override
  FutureOr<void> onLoad() {
    background = Background(size);
    add(background);

    rocket = Rocket();
    add(rocket);

    ground = Ground();
    add(ground);

    buildingManager = BuildingManager();
    add(buildingManager);

    scoreText = ScoreText();
    add(scoreText);
  }

  @override
  void onTap() {
    if (!isGameOver) {
      rocket.flap();
    }
  }

  int score = 0;
  int currentLevelThreshold = 0;

  void incrementScore() {
    final previousLevel = _getCurrentLevelThreshold();
    score += 1;
    final newLevel = _getCurrentLevelThreshold();

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

  void updateDifficultySettings() {
    final settings = difficultyLevels[_getCurrentLevelThreshold()]!;
    buildingManager.updateDifficulty(
      buildingInterval: settings['buildingInterval'],
      enemySpawnInterval: settings['enemySpawnInterval'],
    );
    ground.updateScrollingSpeed(settings['groundScrollingSpeed']);
  }

  void showLevelUpNotification(int levelThreshold) {
    final overlay = LevelUpNotification(
      levelName: difficultyLevels[levelThreshold]?['levelName'] ?? 'New Level',
      levelRange: difficultyLevels[levelThreshold]?['levelRange'] ?? '',
    );
    add(overlay);
  }

  bool isGameOver = false;

  // Only modifying the gameOver method to add a "Back to Menu" button
  void gameOver() {
    if (isGameOver) return;

    isGameOver = true;
    pauseEngine();
    FlameAudio.play('crash.wav');

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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
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
              const SizedBox(width: 10),
              Container(
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

    children.whereType<Building>().forEach((building) => building.removeFromParent());
    children.whereType<EnemyPlane>().forEach((enemy) => enemy.removeFromParent());
    children.whereType<LevelUpNotification>().forEach((notification) => notification.removeFromParent());

    updateDifficultySettings();

    if (paused) {
      resumeEngine();
    }
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