import 'dart:math';
import 'package:flame/components.dart';
import 'package:floato_the_game/components/buildinng.dart';
import 'package:floato_the_game/components/enemy_plane.dart';
import 'package:floato_the_game/constants.dart';
import 'package:floato_the_game/game.dart';

class BuildingManager extends Component with HasGameRef<floato> {
  double buildingSpawnTimer = 0;
  double enemySpawnTimer = 0;
  double buildingInterval = difficultyLevels[0]!['buildingInterval'];
  double enemySpawnInterval = difficultyLevels[0]!['enemySpawnInterval'];
  final random = Random();

  @override
  void update(double dt) {
    if (gameRef.isGameOver) return;

    buildingSpawnTimer += dt;
    enemySpawnTimer += dt;

    if (buildingSpawnTimer > buildingInterval) {
      buildingSpawnTimer = 0;
      spawnBuilding();
    }

    if (enemySpawnTimer > enemySpawnInterval) {
      enemySpawnTimer = 0;
      spawnEnemy();
    }
  }

  void spawnBuilding() {
    final buildingHeight = (minBuildingHeight +
        random.nextDouble() * (maxBuildingHeight - minBuildingHeight)) * gameRef.scaleFactor;

    final building = Building(
      Vector2(gameRef.size.x, gameRef.size.y - groundHeight * gameRef.scaleFactor),
      Vector2(
        buildingWidth * gameRef.scaleFactor,
        buildingHeight,
      ),
    );

    gameRef.add(building);
  }

  void spawnEnemy() {
    // Define spawn area parameters
    final double screenHeight = gameRef.size.y;
    final double screenWidth = gameRef.size.x;

    // Use 20% of screen height from top as minimum Y
    final double minY = screenHeight * 0.05;
    // Use 70% of screen height as maximum Y (leaving space for ground buildings)
    final double maxY = screenHeight * 0.7;

    // Random Y position within the defined range
    final double yPos = minY + random.nextDouble() * (maxY - minY);

    // Random plane type
    final planeType = random.nextInt(enemyPlaneImages.length);

    // Calculate the correct speed based on the current level
    final baseSpeed = enemyPlaneSpeeds[planeType % enemyPlaneSpeeds.length];
    final speedMultiplier = gameRef.getEnemySpeedMultiplier();
    final adjustedSpeed = baseSpeed * speedMultiplier;

    // Create the enemy plane
    final enemy = EnemyPlane(
      position: Vector2(screenWidth, yPos),
      size: Vector2(
        enemyPlaneWidth * gameRef.scaleFactor,
        enemyPlaneHeight * gameRef.scaleFactor,
      ),
      planeType: planeType,
      speed: adjustedSpeed,
    );

    gameRef.add(enemy);
  }

  void updateDifficulty({
    required double buildingInterval,
    required double enemySpawnInterval,
  }) {
    this.buildingInterval = buildingInterval;
    this.enemySpawnInterval = enemySpawnInterval;
    buildingSpawnTimer = 0;
    enemySpawnTimer = 0;
  }
}