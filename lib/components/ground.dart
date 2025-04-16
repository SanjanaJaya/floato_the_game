import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:floato_the_game/components/rocket.dart';
import 'package:floato_the_game/constants.dart';
import 'package:floato_the_game/game.dart';

class Ground extends SpriteComponent with HasGameRef<floato>, CollisionCallbacks {
  double scrollingSpeed = difficultyLevels[0]!['groundScrollingSpeed'];
  String currentGround = groundImages[0];

  Ground() : super();

  @override
  FutureOr<void> onLoad() async {
    size = Vector2(
      2 * gameRef.size.x,
      groundHeight * gameRef.scaleFactor,
    );
    position = Vector2(0, gameRef.size.y - groundHeight * gameRef.scaleFactor);
    await updateGround(0);
    add(RectangleHitbox());
  }

  Future<void> updateGround(int levelThreshold) async {
    final settings = difficultyLevels[levelThreshold]!;
    currentGround = settings['groundImage'];
    scrollingSpeed = settings['groundScrollingSpeed'];
    sprite = await Sprite.load(currentGround);
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