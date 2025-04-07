import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:floato_the_game/components/rocket.dart';
import 'package:floato_the_game/constants.dart';
import 'package:floato_the_game/game.dart';

class Building extends SpriteComponent with CollisionCallbacks, HasGameRef<floato> {
  bool scored = false;
  final Random _random = Random();

  Building(Vector2 position, Vector2 size)
      : super(position: position, size: size);

  @override
  FutureOr<void> onLoad() async {
    // Randomly select a building image
    final buildingIndex = _random.nextInt(buildingImages.length);
    sprite = await Sprite.load(buildingImages[buildingIndex]);
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    position.x -= groundScrollingSpeed * dt;

    if (!scored && position.x + size.x < gameRef.rocket.position.x) {
      scored = true;
      gameRef.incrementScore();
    }

    if (position.x + size.x <= 0) {
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