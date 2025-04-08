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
    final double screenHeight = gameRef.size.y;
    final double buildingHeight = minBuildingHeight +
        random.nextDouble() * (maxBuildingHeight - minBuildingHeight);

    final building = Building(
      Vector2(gameRef.size.x, screenHeight - groundHeight),
      Vector2(buildingWidth, buildingHeight),
    );

    gameRef.add(building);
  }

  void spawnEnemy() {
    final double screenHeight = gameRef.size.y;
    final double minY = 100;
    final double maxY = screenHeight - groundHeight - maxBuildingHeight - 50;

    final double yPos = minY + random.nextDouble() * (maxY - minY);
    final planeType = random.nextInt(enemyPlaneImages.length);

    // Calculate the correct speed based on the current level
    final baseSpeed = enemyPlaneSpeeds[planeType % enemyPlaneSpeeds.length];
    final speedMultiplier = gameRef.getEnemySpeedMultiplier();
    final adjustedSpeed = baseSpeed * speedMultiplier;

    final enemy = EnemyPlane(
      position: Vector2(gameRef.size.x, yPos),
      size: Vector2(enemyPlaneWidth, enemyPlaneHeight),
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