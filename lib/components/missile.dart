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
    size: rocketType == 0 ? Vector2(20, 10) : Vector2(30, 15), // Smaller missiles for Skye
  );

  @override
  FutureOr<void> onLoad() async {
    try {
      // Load basic missile for Skye (type 0)
      if (rocketType == 0) {
        sprite = await Sprite.load('basic_missile.png'); // Add this asset
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
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is EnemyPlane) {
      // Ensure damage is applied
      other.takeDamage(damage);

      // Add explosion at the collision point
      final explosionPos = Vector2(
        (intersectionPoints.first.x + intersectionPoints.last.x) / 2,
        (intersectionPoints.first.y + intersectionPoints.last.y) / 2,
      );

      gameRef.add(Explosion(
        position: explosionPos,
        size: Vector2(50, 50),
      ));

      // Remove missile after hitting a plane
      removeFromParent();
    }
  }
}