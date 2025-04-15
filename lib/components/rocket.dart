import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:floato_the_game/components/buildinng.dart';
import 'package:floato_the_game/components/ground.dart';
import 'package:floato_the_game/components/missile.dart';
import 'package:floato_the_game/constants.dart';
import 'package:floato_the_game/game.dart';
import 'package:floato_the_game/audio_manager.dart';
import 'package:floato_the_game/special_ability.dart';
import 'package:floato_the_game/components/ability_indicator.dart';

class Rocket extends SpriteAnimationComponent with CollisionCallbacks, HasGameRef<floato> {
  final int rocketType;
  double cooldownTimer = 0;
  double shootingCooldown = 0.5; // Made non-final so we can modify it
  bool canShoot = true;
  final AudioManager _audioManager = AudioManager();

  // Variables for drag-based movement
  bool isDragging = false;
  Vector2 targetPosition = Vector2.zero();
  double movementSpeed = 200.0;

  // Boundaries for movement
  double minY = 0;
  double maxY = 0;
  double minX = 80;
  double maxX = 0;

  // Rapid fire controls
  Timer? _rapidFireTimer;
  double _rapidFireInterval = 0.2; // How often to shoot during rapid fire

  Rocket({this.rocketType = 0}) : super(
      position: Vector2(rocketStartX, rocketStartY),
      size: Vector2(rocketWidth, rocketHeight)
  );

  double velocity = 0;

  bool get isInvincible => gameRef.currentAbility == AbilityType.invincibility;

  @override
  FutureOr<void> onLoad() async {
    final spriteSheet = await gameRef.images.load(rocketImages[rocketType]);
    final spriteSize = Vector2(1000, 800);
    final sprites = List.generate(
      6,
          (i) => Sprite(
        spriteSheet,
        srcPosition: Vector2(i * spriteSize.x, 0),
        srcSize: spriteSize,
      ),
    );

    animation = SpriteAnimation.spriteList(
      sprites,
      stepTime: 0.1,
    );

    add(RectangleHitbox());
    maxX = gameRef.size.x - size.x;
    maxY = gameRef.size.y - groundHeight - size.y;
    targetPosition = position.clone();
    print('Rocket initialized with type: $rocketType');
  }

  void flap() {
    velocity = jumpStrength;
  }

  void startDrag(Vector2 dragPosition) {
    isDragging = true;
    updateTargetPosition(dragPosition);
  }

  void updateDragPosition(Vector2 dragPosition) {
    if (isDragging) {
      updateTargetPosition(dragPosition);
    }
  }

  void stopDrag() {
    isDragging = false;
  }

  void updateTargetPosition(Vector2 newPosition) {
    targetPosition.x = newPosition.x.clamp(minX, maxX);
    targetPosition.y = newPosition.y.clamp(minY, maxY);
  }

  void shoot() {
    if (!canShoot) return;

    // Check if we can shoot based on rocket type and abilities
    if (rocketType == 0 && gameRef.currentAbility != AbilityType.rapidFire) return;

    _createMissile();
  }

  void forcedShoot() {
    // Allow shooting for any rocket type
    _createMissile();
  }

  void _createMissile() {
    // For rapid fire, all rockets should shoot
    final isRapidFireActive = gameRef.currentAbility == AbilityType.rapidFire;

    // Determine missile properties
    final missileType = rocketType;
    double missileSpeed = missileSpeeds[rocketType];
    int missileDamage = missileDamages[rocketType];

    // Apply rapid fire modifiers
    if (isRapidFireActive) {
      missileSpeed *= 1.5;  // 50% faster during rapid fire
      missileDamage *= 2;   // Double damage during rapid fire

      // Make sure Skye has non-zero values during rapid fire
      if (rocketType == 0) {
        // Give Skye a base damage during rapid fire if it was 0
        if (missileDamage == 0) missileDamage = 15;
        // Give Skye a base speed during rapid fire if it was 0
        if (missileSpeed == 0) missileSpeed = 250;
      }
    }

    // Create missile at the correct position
    final missile = Missile(
      position: Vector2(position.x + size.x/2, position.y + size.y/2),
      rocketType: missileType,
      speed: missileSpeed,
      damage: missileDamage,
    );

    gameRef.add(missile);
    canShoot = false;
    cooldownTimer = 0;
  }

  void _activateRapidFire() {
    // Clear any existing timer
    _rapidFireTimer?.stop();

    // Reset shooting cooldown for all rockets during rapid fire
    if (rocketType == 0) {
      shootingCooldown = 0.1; // Very fast for Skye
    } else {
      shootingCooldown = 0.2; // Fast for other rockets too
    }
    canShoot = true; // Make sure we can shoot immediately

    // Create a new timer for automatic firing during rapid fire
    _rapidFireTimer = Timer(
        _rapidFireInterval,
        onTick: () {
          if (gameRef.currentAbility == AbilityType.rapidFire) {
            forcedShoot();
          } else {
            _rapidFireTimer?.stop();
            // Reset to normal cooldown when ability ends
            shootingCooldown = rocketType == 0 ? 0.5 : 0.5;
          }
        },
        repeat: true
    );
  }

  @override
  void update(double dt) {

    // Check if rapid fire was just activated
    if (gameRef.currentAbility == AbilityType.rapidFire && _rapidFireTimer == null) {
      _activateRapidFire();
    }

    // Update rapid fire timer if active
    if (_rapidFireTimer != null && gameRef.currentAbility == AbilityType.rapidFire) {
      _rapidFireTimer!.update(dt);
    }

    if (isDragging) {
      final direction = targetPosition - position;
      if (direction.length > 5) {
        direction.normalize();
        position += direction * movementSpeed * dt;
        position.x = position.x.clamp(minX, maxX);
        position.y = position.y.clamp(minY, maxY);
      }
    } else {
      velocity += gravity * dt;
      position.y += velocity * dt;

      if (position.y < minY) {
        position.y = minY;
        velocity = 0;
      }
      if (position.y > maxY) {
        position.y = maxY;
        velocity = 0;
      }
    }

    if (!canShoot) {
      cooldownTimer += dt;
      if (cooldownTimer >= shootingCooldown) {
        canShoot = true;
      }
    }

    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (isInvincible) return;

    if (other is Ground || other is Building) {
      gameRef.gameOver();
    }
  }
}