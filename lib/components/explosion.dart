import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:floato_the_game/game.dart';

class Explosion extends SpriteAnimationComponent with HasGameRef<floato> {
  final DateTime creationTime = DateTime.now();
  final bool playSoundEffect;
  final Vector2 originalSize;
  final Random _random = Random();

  // Define your explosion variants
  final List<ExplosionVariant> _explosionVariants = [
    ExplosionVariant(
      imagePath: 'explosion1.png',
      frameCount: 6,
      frameWidth: 5355.0,
      frameHeight: 512.0,
    ),
    ExplosionVariant(
      imagePath: 'explosion2.png',
      frameCount: 9,
      frameWidth: 12288.0,
      frameHeight: 1158.0,
    ),
    ExplosionVariant(
      imagePath: 'explosion3.png',
      frameCount: 6,
      frameWidth: 7500.0,
      frameHeight: 1250.0,
    ),
  ];

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

    // Select a random explosion variant
    final variant = _explosionVariants[_random.nextInt(_explosionVariants.length)];

    // Load explosion spritesheet
    final spriteSheet = await gameRef.images.load(variant.imagePath);

    // Calculate frame dimensions
    final frameWidth = variant.frameWidth / variant.frameCount;
    final frameHeight = variant.frameHeight;
    final spriteSize = Vector2(frameWidth, frameHeight);

    // Generate frames
    final frames = List.generate(
      variant.frameCount,
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

// Helper class to store explosion variant data
class ExplosionVariant {
  final String imagePath;
  final int frameCount;
  final double frameWidth;
  final double frameHeight;

  ExplosionVariant({
    required this.imagePath,
    required this.frameCount,
    required this.frameWidth,
    required this.frameHeight,
  });
}