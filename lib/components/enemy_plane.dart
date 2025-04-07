import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:floato_the_game/components/rocket.dart';
import 'package:floato_the_game/constants.dart';
import 'package:floato_the_game/game.dart';

class EnemyPlane extends SpriteComponent with CollisionCallbacks, HasGameRef<floato> {
  final int planeType;

  EnemyPlane({
    required Vector2 position,
    required Vector2 size,
    required this.planeType,
  }) : super(position: position, size: size);

  @override
  FutureOr<void> onLoad() async {
    // Randomly select one of the enemy plane images
    final imageIndex = planeType % enemyPlaneImages.length;
    sprite = await Sprite.load(enemyPlaneImages[imageIndex]);
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    // Use different speed based on plane type
    final speed = enemyPlaneSpeeds[planeType % enemyPlaneSpeeds.length];
    position.x -= speed * dt;

    if (position.x + size.x < 0) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Rocket) {
      gameRef.gameOver();
    }
  }
}