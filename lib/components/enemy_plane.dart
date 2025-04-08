import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:floato_the_game/components/rocket.dart';
import 'package:floato_the_game/constants.dart';
import 'package:floato_the_game/game.dart';

class EnemyPlane extends SpriteAnimationComponent with CollisionCallbacks, HasGameRef<floato> {
  final int planeType;
  double speed;

  EnemyPlane({
    required Vector2 position,
    required Vector2 size,
    required this.planeType,
    this.speed = 0,  // Default value that will be overridden
  }) : super(position: position, size: size);

  @override
  FutureOr<void> onLoad() async {
    // Load the sprite sheet for animations
    final imageIndex = planeType % enemyPlaneImages.length;
    final spriteSheet = await game.images.load(enemyPlaneImages[imageIndex]);

    // Each plane takes up 1200x500 pixels in the sprite sheet
    // We'll assume each animation has multiple frames horizontally
    final frameCount = 6; // Adjust based on your actual number of frames
    final spriteSize = Vector2(7200 / frameCount, 500); // Size of each frame

    // Create the animation frames
    final frames = List.generate(
      frameCount,
          (i) => Sprite(
        spriteSheet,
        srcPosition: Vector2(i * spriteSize.x, 0),
        srcSize: spriteSize,
      ),
    );

    // Set up the animation
    animation = SpriteAnimation.spriteList(
      frames,
      stepTime: 0.1, // Adjust animation speed as needed
      loop: true,
    );

    add(RectangleHitbox());

    // Initialize speed based on the current level if it wasn't set
    if (speed == 0) {
      final baseSpeed = enemyPlaneSpeeds[planeType % enemyPlaneSpeeds.length];
      final speedMultiplier = gameRef.getEnemySpeedMultiplier();
      speed = baseSpeed * speedMultiplier;
    }
  }

  @override
  void update(double dt) {
    // Use the calculated speed with level multiplier
    position.x -= speed * dt;

    if (position.x + size.x < 0) {
      removeFromParent();
    }

    super.update(dt); // Important to call super.update for animation
  }

  // Add method to update speed during gameplay
  void updateSpeed(double newSpeed) {
    speed = newSpeed;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Rocket) {
      gameRef.gameOver();
    }
  }
}