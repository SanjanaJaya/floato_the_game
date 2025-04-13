import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:floato_the_game/game.dart';
import 'package:floato_the_game/components/rocket.dart';

enum AbilityType {
  doubleScore,    // Doubles score points for 10 seconds
  invincibility,  // Makes rocket invincible for 8 seconds
  slowMotion,     // Slows down enemies for 12 seconds
  rapidFire,      // Allows Skye to shoot temporarily
}

class SpecialAbility extends SpriteComponent with CollisionCallbacks, HasGameRef<floato> {
  final AbilityType type;
  final Vector2 _velocity = Vector2(-150, 0);

  SpecialAbility({
    required Vector2 position,
    required this.type,
  }) : super(
    position: position,
    size: Vector2(40, 40),
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Load appropriate sprite based on ability type
    final spritePath = _getSpritePath();
    sprite = await Sprite.load(spritePath);

    add(CircleHitbox()..collisionType = CollisionType.passive);
  }

  String _getSpritePath() {
    switch (type) {
      case AbilityType.doubleScore:
        return 'abilities/double_score.png';
      case AbilityType.invincibility:
        return 'abilities/invincibility.png';
      case AbilityType.slowMotion:
        return 'abilities/slow_motion.png';
      case AbilityType.rapidFire:
        return 'abilities/rapid_fire.png';
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += _velocity * dt;

    // Remove if off screen
    if (position.x < -size.x) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Rocket) {
      gameRef.activateAbility(type);
      removeFromParent();
    }
  }
}