import 'dart:async';
import 'package:flame/components.dart';
import 'package:floato_the_game/game.dart';

class Explosion extends SpriteAnimationComponent with HasGameRef<floato> {
  Explosion({
    required Vector2 position,
    required Vector2 size,
  }) : super(
    position: position,
    size: size,
    removeOnFinish: true, // Remove component when animation finishes
  );

  @override
  FutureOr<void> onLoad() async {
    // Load explosion spritesheet
    final spriteSheet = await gameRef.images.load('explosion.png');

    // Create animation with 8 frames (adjust based on your actual explosion sprite)
    final spriteSize = Vector2(64, 64); // Adjust based on your explosion sprite size
    final frames = List.generate(
      8, // Assuming 8 frames in the explosion animation
          (i) => Sprite(
        spriteSheet,
        srcPosition: Vector2(i * spriteSize.x, 0),
        srcSize: spriteSize,
      ),
    );

    // Set up animation
    animation = SpriteAnimation.spriteList(
      frames,
      stepTime: 0.1, // Animation speed
      loop: false, // Don't loop the explosion
    );
  }
}