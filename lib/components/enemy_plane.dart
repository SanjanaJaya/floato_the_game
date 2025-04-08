import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:floato_the_game/components/rocket.dart';
import 'package:floato_the_game/constants.dart';
import 'package:floato_the_game/game.dart';

class EnemyPlane extends SpriteComponent with CollisionCallbacks, HasGameRef<floato> {
  final int planeType;
  double speed;

  EnemyPlane({
    required Vector2 position,
    required Vector2 size,
    required this.planeType,
    this.speed = 0,  // Default value that will be overridden
  }) : super(position: position, size: size);

  @override
  FutureOr<void> onLoad() async {
    // Randomly select one of the enemy plane images
    final imageIndex = planeType % enemyPlaneImages.length;
    sprite = await Sprite.load(enemyPlaneImages[imageIndex]);
    add(RectangleHitbox());

    // Initialize speed based on the current level if it wasn't set
    if (speed == 0) {
      final baseSpeed = enemyPlaneSpeeds[planeType % enemyPlaneSpeeds.length];
      final speedMultiplier = gameRef.getEnemySpeedMultiplier();
      speed = baseSpeed * speedMultiplier;
    }
  }

  @override
  void update(double dt) {
    // Use the calculated speed with level multiplier
    position.x -= speed * dt;

    if (position.x + size.x < 0) {
      removeFromParent();
    }
  }

  // Add method to update speed during gameplay
  void updateSpeed(double newSpeed) {
    speed = newSpeed;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Rocket) {
      gameRef.gameOver();
    }
  }
}