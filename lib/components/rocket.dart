import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:floato_the_game/components/buildinng.dart';
import 'package:floato_the_game/components/ground.dart';
import 'package:floato_the_game/components/missile.dart';
import 'package:floato_the_game/constants.dart';
import 'package:floato_the_game/game.dart';
import 'package:floato_the_game/audio_manager.dart';

class Rocket extends SpriteAnimationComponent with CollisionCallbacks, HasGameRef<floato> {
  final int rocketType;
  double cooldownTimer = 0;
  final double shootingCooldown = 0.5; // 0.5 seconds between shots
  bool canShoot = true;
  final AudioManager _audioManager = AudioManager();

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

    // Debug print to verify rocket type
    print('Rocket initialized with type: $rocketType');
  }

  void flap() {
    velocity = jumpStrength;
  }

  void shoot() {
    // Debug print when shoot is called
    print('Regular shoot called, canShoot: $canShoot, rocketType: $rocketType');

    // Rocket 1 can't shoot
    if (rocketType == 0 || !canShoot) return;

    _createMissile();
  }

  // New method to force shoot, always creating a missile
  void forcedShoot() {
    // Debug print when forced shoot is called
    print('Forced shoot called, rocketType: $rocketType');

    // Rocket 1 can't shoot
    if (rocketType == 0) return;

    _createMissile();
  }

  // Extract missile creation logic to avoid duplication
  void _createMissile() {
    // Create a missile at rocket position
    final missile = Missile(
      position: Vector2(position.x + size.x/2, position.y + size.y/2),
      rocketType: rocketType,
      speed: missileSpeeds[rocketType],
      damage: missileDamages[rocketType],
    );

    gameRef.add(missile);

    // Let the missile play its own sound when loaded
    // We don't need to play sound here as it's done in missile.onLoad()

    // Set cooldown
    canShoot = false;
    cooldownTimer = 0;
  }

  @override
  void update(double dt) {
    velocity += gravity * dt;
    position.y += velocity * dt;

    if (position.y < 0) {
      position.y = 0;
      velocity = 0;
    }

    // Handle shooting cooldown
    if (!canShoot) {
      cooldownTimer += dt;
      if (cooldownTimer >= shootingCooldown) {
        canShoot = true;
      }
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