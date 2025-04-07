import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:floato_the_game/components/buildinng.dart';
import 'package:floato_the_game/components/ground.dart';
import 'package:floato_the_game/constants.dart';
import 'package:floato_the_game/game.dart';

class Rocket extends SpriteComponent with CollisionCallbacks, HasGameRef<floato> {
  Rocket() : super(
      position: Vector2(rocketStartX, rocketStartY),
      size: Vector2(rocketWidth, rocketHeight)
  );

  double velocity = 0;

  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load('rocket.png');
    add(RectangleHitbox());
  }

  void flap() {
    velocity = jumpStrength;
  }

  @override
  void update(double dt) {
    velocity += gravity * dt;
    position.y += velocity * dt;

    if (position.y < 0) {
      position.y = 0;
      velocity = 0;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Ground || other is Building) {
      gameRef.gameOver();
    }
  }
}