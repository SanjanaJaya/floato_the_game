import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:floato_the_game/components/rocket.dart';
import 'package:floato_the_game/constants.dart';
import 'package:floato_the_game/game.dart';

class EnemyPlane extends SpriteComponent with CollisionCallbacks, HasGameRef<floato> {
  EnemyPlane({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load('enemy_plane.png');
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    position.x -= enemyPlaneSpeed * dt;

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