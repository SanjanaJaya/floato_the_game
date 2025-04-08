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

    // Adjust for actual sprite sheet dimensions: 5355x512 with 6 frames
    final frameWidth = 5355.0 / 6.0; // Calculate single frame width - explicitly using doubles
    final frameHeight = 512.0; // Height of each frame - explicitly using double
    final spriteSize = Vector2(frameWidth, frameHeight);

    final frames = List.generate(
      6, // 6 frames in the explosion animation
          (i) => Sprite(
        spriteSheet,
        srcPosition: Vector2(i * frameWidth, 0),
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