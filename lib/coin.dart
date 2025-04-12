import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class Coin extends SpriteAnimationComponent with HasGameRef {
  final VoidCallback onCollected;
  final int value;
  final String type;

  Coin({
    required Vector2 position,
    required this.onCollected,
    required this.value,
    required this.type,
  }) : super(position: position, size: Vector2.all(30));

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final spriteSheet = SpriteSheet(
      image: await gameRef.images.load('${type}_coin_sheet.png'),
      srcSize: Vector2(418, 418), // Each frame is 418x418
    );

    animation = spriteSheet.createAnimation(
      row: 0,
      stepTime: 0.05,
      from: 0,
      to: 9, // 10 frames
      loop: true,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= 150 * dt; // Move left with the scrolling world

    // Remove if off screen
    if (position.x < -size.x) {
      removeFromParent();
    }
  }

  void collect() {
    onCollected();
    removeFromParent();
    // You could add a collection effect here
  }
}