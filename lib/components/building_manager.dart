import 'dart:math';
import 'package:flame/components.dart';
import 'package:floato_the_game/components/buildinng.dart';
import 'package:floato_the_game/components/enemy_plane.dart';
import 'package:floato_the_game/constants.dart';
import 'package:floato_the_game/game.dart';

class BuildingManager extends Component with HasGameRef<floato> {
  double buildingSpawnTimer = 0;
  double enemySpawnTimer = 0;

  @override
  void update(double dt) {
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
    // Random height between minBuildingHeight and maxBuildingHeight
    final double buildingHeight = minBuildingHeight +
        Random().nextDouble() * (maxBuildingHeight - minBuildingHeight);

    final building = Building(
      Vector2(gameRef.size.x, screenHeight - groundHeight - buildingHeight),
      Vector2(buildingWidth, buildingHeight),
    );

    gameRef.add(building);
  }

  void spawnEnemy() {
    final double screenHeight = gameRef.size.y;
    final double minY = 100;
    final double maxY = screenHeight - groundHeight - maxBuildingHeight - 50;

    final double yPos = minY + Random().nextDouble() * (maxY - minY);
    final random = Random();
    final planeType = random.nextInt(4); // Random number 0-3

    final enemy = EnemyPlane(
      position: Vector2(gameRef.size.x, yPos),
      size: Vector2(enemyPlaneWidth, enemyPlaneHeight),
      planeType: planeType,
    );

    gameRef.add(enemy);
  }
}