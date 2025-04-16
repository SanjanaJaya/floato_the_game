import 'dart:async';
import 'package:flame/components.dart';
import 'package:floato_the_game/game.dart';

class Explosion extends SpriteAnimationComponent with HasGameRef<floato> {
  final DateTime creationTime = DateTime.now();
  final bool playSoundEffect;
  final Vector2 originalSize;

  Explosion({
    required Vector2 position,
    required Vector2 size,
    this.playSoundEffect = false,
  })  : originalSize = size,
        super(
        position: position,
        size: size, // Temporary size, will be scaled in onLoad
        removeOnFinish: true,
      );

  @override
  FutureOr<void> onLoad() async {
    // Apply scaling
    size = Vector2(
      originalSize.x * gameRef.scaleFactor,
      originalSize.y * gameRef.scaleFactor,
    );

    // Load explosion spritesheet
    final spriteSheet = await gameRef.images.load('explosion.png');

    // Adjust for actual sprite sheet dimensions: 5355x512 with 6 frames
    final frameWidth = 5355.0 / 6.0; // Calculate single frame width
    final frameHeight = 512.0; // Height of each frame
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
      stepTime: 0.05, // Animation speed
      loop: false, // Don't loop the explosion
    );
  }
}