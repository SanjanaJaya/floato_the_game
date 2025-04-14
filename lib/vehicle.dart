import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:floato_the_game/game.dart';
import 'package:floato_the_game/constants.dart';
import 'package:floato_the_game/special_ability.dart';

class Vehicle extends SpriteAnimationComponent with HasGameRef<floato> {
  final double speed;
  final int vehicleType;

  Vehicle({
    required Vector2 position,
    required this.speed,
    required this.vehicleType,
  }) : super(
    position: position,
    size: Vector2(vehicleWidth, vehicleHeight),
    anchor: Anchor.bottomLeft,
  );

  @override
  FutureOr<void> onLoad() async {
    // Load the appropriate vehicle image from constants
    final vehicleImage = vehicleImages[vehicleType % vehicleImages.length];
    final spriteSheet = await gameRef.images.load(vehicleImage);

    // Sprite sheet configuration
    // Assuming each vehicle spritesheet has 6 frames in a horizontal strip
    const framesPerVehicle = 6;
    final frameWidth = spriteSheet.width / framesPerVehicle;
    final frameHeight = spriteSheet.height.toDouble();

    // Create animation from spritesheet
    animation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: framesPerVehicle,
        stepTime: 0.2, // Adjust animation speed as needed
        textureSize: Vector2(frameWidth, frameHeight),
      ),
    );

    // Set priority to appear above ground but below other elements
    priority = 2;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move vehicle from right to left
    position.x -= speed * dt;

    // Remove vehicle when it's off-screen
    if (position.x < -size.x) {
      removeFromParent();
    }

    // Apply slow motion effect if active
    if (gameRef.currentAbility == AbilityType.slowMotion) {
      // Slow down vehicles during slow motion ability
      position.x += speed * dt * 0.5; // Counteract half of the movement
    }
  }
}