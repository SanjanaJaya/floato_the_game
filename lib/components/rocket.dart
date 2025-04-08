import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:floato_the_game/components/buildinng.dart';
import 'package:floato_the_game/components/ground.dart';
import 'package:floato_the_game/constants.dart';
import 'package:floato_the_game/game.dart';

class Rocket extends SpriteAnimationComponent with CollisionCallbacks, HasGameRef<floato> {
  final int rocketType;

  Rocket({this.rocketType = 0}) : super(
      position: Vector2(rocketStartX, rocketStartY),
      size: Vector2(rocketWidth, rocketHeight)
  );

  double velocity = 0;

  @override
  FutureOr<void> onLoad() async {
    // Load the sprite sheet
    final spriteSheet = await gameRef.images.load(rocketImages[rocketType]);

    // Create sprites from the sprite sheet
    // Your sprite sheet is 6000x800 with 6 frames (each 1000x800)
    final spriteSize = Vector2(1000, 800);
    final sprites = List.generate(
      6, // Number of frames
          (i) => Sprite(
        spriteSheet,
        srcPosition: Vector2(i * spriteSize.x, 0),
        srcSize: spriteSize,
      ),
    );

    // Create and play the animation
    animation = SpriteAnimation.spriteList(
      sprites,
      stepTime: 0.1, // Adjust this value to control animation speed
    );

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

    super.update(dt); // Don't forget this line to update the animation
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Ground || other is Building) {
      gameRef.gameOver();
    }
  }
}