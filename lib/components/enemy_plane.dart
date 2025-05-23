import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:floato_the_game/components/rocket.dart';
import 'package:floato_the_game/components/health_bar.dart';
import 'package:floato_the_game/components/explosion.dart';
import 'package:floato_the_game/constants.dart';
import 'package:floato_the_game/game.dart';
import 'package:floato_the_game/special_ability.dart';
import 'package:floato_the_game/audio_manager.dart';

class EnemyPlane extends SpriteAnimationComponent with CollisionCallbacks, HasGameRef<floato> {
  final int planeType;
  double speed;
  int health;
  int maxHealth;
  late HealthBar3D healthBar;
  bool _isDestroyed = false;
  final AudioManager _audioManager = AudioManager();
  Vector2 _initialSize;

  EnemyPlane({
    required Vector2 position,
    required Vector2 size,
    required this.planeType,
    this.speed = 0,  // Default value that will be overridden
  }) :
        maxHealth = enemyPlaneHealths[planeType % enemyPlaneHealths.length],
        health = enemyPlaneHealths[planeType % enemyPlaneHealths.length],
        _initialSize = size,
        super(position: position, size: size);

  @override
  FutureOr<void> onLoad() async {
    // Apply scaling to the size
    size = Vector2(
      _initialSize.x * gameRef.scaleFactor,
      _initialSize.y * gameRef.scaleFactor,
    );

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

    // Add health bar with scaled position and size
    healthBar = HealthBar3D(
      maxHealth: maxHealth,
      position: Vector2(0, -15 * gameRef.scaleFactor),
      size: Vector2(size.x, 5 * gameRef.scaleFactor),
    );
    add(healthBar);
  }

  @override
  void update(double dt) {
    // Get the actual speed considering slow motion ability
    double effectiveSpeed = speed;
    if (gameRef.currentAbility == AbilityType.slowMotion) {
      effectiveSpeed *= 0.075; // Half speed during slow motion
    }

    position.x -= effectiveSpeed * dt;

    if (position.x + size.x < 0) {
      removeFromParent();
    }
    super.update(dt);
  }

  // Add method to update speed during gameplay
  void updateSpeed(double newSpeed) {
    speed = newSpeed;
  }

  // Method to handle taking damage from missiles
  void takeDamage(int damage) {
    if (_isDestroyed) return;

    health -= damage;
    healthBar.updateHealth(health);

    if (health <= 0 && !_isDestroyed) {
      _isDestroyed = true; // Mark as destroyed to prevent double processing

      // Calculate points based on plane's health - scale from base of 3 points
      int pointsAwarded = calculatePointsForPlane();

      // Award points to the player
      gameRef.incrementScore(pointsAwarded);

      // Play explosion sound only when plane is completely destroyed
      _audioManager.playSfx('explosion.ogg');

      // Create explosion at plane position
      final explosion = Explosion(
        position: Vector2(position.x + size.x/2, position.y + size.y/2),
        size: Vector2(80, 80),
      );
      gameRef.add(explosion);

      // Remove plane after a tiny delay to prevent audio stacking issues
      Future.delayed(Duration(milliseconds: 50), () {
        if (isMounted) {
          removeFromParent();
        }
      });
    }
  }

  // Calculate points based on plane's health
  int calculatePointsForPlane() {
    // Base calculations on max health
    // We'll use the following formula to scale points:
    // - Planes with health 175-199: 3 points (lowest tier)
    // - Planes with health 200-249: 5 points
    // - Planes with health 250-299: 7 points
    // - Planes with health 300-349: 10 points
    // - Planes with health 350+: 15 points (highest tier)

    if (maxHealth >= 350) {
      return 15; // Highest tier planes
    } else if (maxHealth >= 300) {
      return 10; // High tier planes
    } else if (maxHealth >= 250) {
      return 8;  // Medium-high tier planes
    } else if (maxHealth >= 200) {
      return 6;  // Medium tier planes
    } else {
      return 4;  // Basic planes (default)
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