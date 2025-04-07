import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:floato_the_game/components/rocket.dart';
import 'package:floato_the_game/constants.dart';
import 'package:floato_the_game/game.dart';

class Ground extends SpriteComponent with HasGameRef<floato>, CollisionCallbacks {
  Ground() : super();

  double scrollingSpeed = difficultyLevels[0]!['groundScrollingSpeed'];

  @override
  FutureOr<void> onLoad() async {
    size = Vector2(2 * gameRef.size.x, groundHeight);
    position = Vector2(0, gameRef.size.y - groundHeight);
    sprite = await Sprite.load('ground.png');
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    if (gameRef.isGameOver) return;

    position.x -= scrollingSpeed * dt;

    if (position.x + size.x / 2 <= 0) {
      position.x = 0;
    }
  }

  void updateScrollingSpeed(double newSpeed) {
    scrollingSpeed = newSpeed;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Rocket) {
      gameRef.gameOver();
    }
  }
}