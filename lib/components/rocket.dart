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

  // Variables for drag-based movement
  bool isDragging = false;
  Vector2 targetPosition = Vector2.zero();
  double movementSpeed = 200.0; // Speed at which rocket moves toward target position

  // Boundaries for movement
  double minY = 0;  // Top of screen
  double maxY = 0;  // Will be set based on ground height in onLoad
  double minX = 80; // Left boundary
  double maxX = 0;  // Will be set based on screen width in onLoad

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

    // Initialize boundaries based on game size
    maxX = gameRef.size.x - size.x;
    maxY = gameRef.size.y - groundHeight - size.y;

    // Initialize target position to current position
    targetPosition = position.clone();

    // Debug print to verify rocket type
    print('Rocket initialized with type: $rocketType');
  }

  // Traditional flap method - kept for backward compatibility
  void flap() {
    velocity = jumpStrength;
  }

  // Method to start dragging
  void startDrag(Vector2 dragPosition) {
    isDragging = true;
    updateTargetPosition(dragPosition);
  }

  // Method to update position during drag
  void updateDragPosition(Vector2 dragPosition) {
    if (isDragging) {
      updateTargetPosition(dragPosition);
    }
  }

  // Method to stop dragging
  void stopDrag() {
    isDragging = false;
  }

  // Update target position with constraints
  void updateTargetPosition(Vector2 newPosition) {
    targetPosition.x = newPosition.x.clamp(minX, maxX);
    targetPosition.y = newPosition.y.clamp(minY, maxY);
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
    if (isDragging) {
      // Move toward target position with smooth interpolation
      final direction = targetPosition - position;
      if (direction.length > 5) {  // Only move if we're more than 5 pixels away
        direction.normalize();
        position += direction * movementSpeed * dt;

        // Clamp position to boundaries
        position.x = position.x.clamp(minX, maxX);
        position.y = position.y.clamp(minY, maxY);
      }
    } else {
      // Apply gravity when not being dragged
      velocity += gravity * dt;
      position.y += velocity * dt;

      // Keep rocket within bounds
      if (position.y < minY) {
        position.y = minY;
        velocity = 0;
      }
      if (position.y > maxY) {
        position.y = maxY;
        velocity = 0;
      }
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