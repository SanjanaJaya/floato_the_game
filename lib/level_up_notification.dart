import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LevelUpNotification extends PositionComponent with HasGameRef {
  final int level;
  final VoidCallback onFinish;

  LevelUpNotification({
    required this.level,
    required this.onFinish,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Display the notification for 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    removeFromParent();
    onFinish();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final text = TextPainter(
      text: TextSpan(
        text: 'LEVEL UP!\nReached $level points',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 10,
              color: Colors.black,
              offset: Offset(2, 2),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    text.paint(
      canvas,
      Offset(
        (gameRef.size.x - text.width) / 2,
        gameRef.size.y / 3,
      ),
    );
  }
}