import 'dart:async';
import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart' show Color;
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

  // Add these new properties for glow effect
  late SpriteComponent _glowEffect;
  bool _glowActive = false;
  final Map<AbilityType, Color> _abilityColors = {
    AbilityType.doubleScore: const Color(0xFFFFD700), // Gold
    AbilityType.invincibility: const Color(0xFF00FF00), // Green
    AbilityType.slowMotion: const Color(0xFFADD8E6), // Light Blue
    AbilityType.rapidFire: const Color(0xFFFF4500), // Orange-Red
  };

  // Effect controller for the pulsing effect
  EffectController? _pulseEffectController;

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

    // Initialize glow effect (hidden by default)
    _glowEffect = SpriteComponent(
      sprite: await gameRef.loadSprite('glow_circle.png'), // You need to add this asset
      size: size * 1.5,
      anchor: Anchor.center,
      position: size / 2,
    )..opacity = 0.0;

    add(_glowEffect);
  }

  // Add this new method to update the glow effect
  void updateGlowEffect(AbilityType? ability) {
    // Cancel any ongoing effects first by removing them
    final effectsToRemove = _glowEffect.children.where((component) => component is OpacityEffect).toList();
    for (final effect in effectsToRemove) {
      _glowEffect.remove(effect);
    }

    if (ability == null) {
      // Fade out glow when ability ends
      _glowEffect.add(
        OpacityEffect.to(
          0.0,
          EffectController(duration: 0.5),
          onComplete: () {
            _glowActive = false;
            // Ensure opacity is actually 0
            _glowEffect.opacity = 0.0;
          },
        ),
      );
    } else {
      // Set color based on ability type
      Color color;
      switch (ability) {
        case AbilityType.doubleScore:
          color = const Color(0xFFFFD700); // Gold
          break;
        case AbilityType.invincibility:
          color = const Color(0xFF00FF00); // Green
          break;
        case AbilityType.slowMotion:
          color = const Color(0xFFADD8E6); // Light Blue
          break;
        case AbilityType.rapidFire:
          color = const Color(0xFFFF4500); // Orange-Red
          break;
        default:
          color = const Color(0xFFFFFFFF); // White as fallback
      }

      // Apply the color directly to the sprite's paint
      if (_glowEffect.sprite != null) {
        _glowEffect.sprite!.paint.colorFilter = ColorFilter.mode(
            color,
            BlendMode.srcATop
        );
      }

      if (!_glowActive) {
        _glowEffect.opacity = 0.0;

        // First fade in the glow
        _glowEffect.add(
          OpacityEffect.to(
            0.7,
            EffectController(duration: 0.5),
            onComplete: () {
              // Then start pulsing effect after fade-in
              _pulseEffectController = EffectController(
                duration: 1.0,
                reverseDuration: 1.0,
                infinite: true,
              );

              _glowEffect.add(
                OpacityEffect.to(
                  0.4,
                  _pulseEffectController!,
                ),
              );
            },
          ),
        );

        _glowActive = true;
      }
    }
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