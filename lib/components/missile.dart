import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:floato_the_game/components/enemy_plane.dart';
import 'package:floato_the_game/components/explosion.dart';
import 'package:floato_the_game/game.dart';
import 'package:floato_the_game/audio_manager.dart';

class Missile extends SpriteComponent with CollisionCallbacks, HasGameRef<floato> {
  final int rocketType;
  final double speed;
  final int damage;
  final AudioManager _audioManager = AudioManager();
  bool _initialized = false;

  Missile({
    required Vector2 position,
    required this.rocketType,
    required this.speed,
    required this.damage,
  }) : super(
    position: position,
    size: Vector2(30, 15), // Default size, can be adjusted based on missile type
  ) {
    // Print debug info on creation
    print('Creating missile for rocket type: $rocketType, speed: $speed, damage: $damage');
  }

  @override
  FutureOr<void> onLoad() async {
    try {
      // Load missile sprite based on rocket type
      final missileIndex = rocketType;  // Changed from rocketType - 1
      print('Loading missile${missileIndex}.png');
      sprite = await Sprite.load('missile${missileIndex}.png');

      // Add collision detection
      add(RectangleHitbox());

      // Play missile launch sound - get singleton instance
      AudioManager().playMissileSound(rocketType);

      _initialized = true;
      print('Missile loaded successfully');
    } catch (e) {
      print('Error loading missile: $e');
    }
  }

  @override
  void update(double dt) {
    if (!_initialized) {
      print('Warning: Updating missile before initialization');
      return;
    }

    // Move missile forward
    position.x += speed * dt;

    // Remove missile if it goes off screen
    if (position.x > gameRef.size.x) {
      print('Missile went off screen, removing');
      removeFromParent();
    }

    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is EnemyPlane) {
      print('Missile hit enemy plane');
      // Apply damage to enemy plane
      other.takeDamage(damage);

      // Create explosion at impact point
      final explosion = Explosion(
        position: Vector2(position.x, position.y),
        size: Vector2(50, 50),
      );
      gameRef.add(explosion);

      // Play explosion sound
      _audioManager.playSfx('explosion.wav');

      // Remove missile after hit
      removeFromParent();
    }
  }
}