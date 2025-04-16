import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:floato_the_game/components/enemy_plane.dart';
import 'package:floato_the_game/components/explosion.dart';
import 'package:floato_the_game/game.dart';

class Missile extends SpriteComponent with CollisionCallbacks, HasGameRef<floato> {
  final int rocketType;
  final double speed;
  final int damage;
  bool _initialized = false;
  final DateTime creationTime = DateTime.now();

  Missile({
    required Vector2 position,
    required this.rocketType,
    required this.speed,
    required this.damage,
  }) : super(
    position: position,
    size: Vector2(rocketType == 0 ? 20 : 30, rocketType == 0 ? 10 : 15), // Default size
  );

  @override
  FutureOr<void> onLoad() async {
    try {
      // Apply scaling after the component is loaded
      size = Vector2(
        (rocketType == 0 ? 20 : 30) * gameRef.scaleFactor,
        (rocketType == 0 ? 10 : 15) * gameRef.scaleFactor,
      );

      // Load basic missile for Skye (type 0)
      if (rocketType == 0) {
        sprite = await Sprite.load('basic_missile.png');
      }
      // Load specialized missiles for other rockets
      else {
        sprite = await Sprite.load('missile$rocketType.png');
      }

      add(RectangleHitbox());
      _initialized = true;
    } catch (e) {
      print('Error loading missile: $e');
      removeFromParent();
    }
  }

  @override
  void update(double dt) {
    if (!_initialized) return;
    position.x += speed * dt;
    if (position.x > gameRef.size.x) {
      removeFromParent();
    }
    super.update(dt);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints,
      PositionComponent other,
      ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is EnemyPlane) {
      other.takeDamage(damage);

      final explosionPos = Vector2(
        (intersectionPoints.first.x + intersectionPoints.last.x) / 2,
        (intersectionPoints.first.y + intersectionPoints.last.y) / 2,
      );

      gameRef.add(Explosion(
        position: explosionPos,
        size: Vector2(50 * gameRef.scaleFactor, 50 * gameRef.scaleFactor),
      ));

      removeFromParent();
    }
  }
}