import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';

class LevelUpNotification extends PositionComponent with HasGameRef {
  final String levelName;
  final String levelRange;
  final String environmentName;
  Timer? _timer;

  LevelUpNotification({
    required this.levelName,
    required this.levelRange,
    required this.environmentName,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Display notification for 2.5 seconds then remove
    _timer = Timer(2.5, onTick: () => removeFromParent());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final welcomeText = TextPainter(
      text: TextSpan(
        text: 'Welcome to $environmentName!',
        style: const TextStyle(
          color: Colors.cyan,
          fontSize: 28,
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

    final levelText = TextPainter(
      text: TextSpan(
        text: '$levelName REACHED!\n$levelRange',
        style: const TextStyle(
          color: Colors.amber,
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

    welcomeText.paint(
      canvas,
      Offset(
        (gameRef.size.x - welcomeText.width) / 2,
        gameRef.size.y / 3 - 40,
      ),
    );

    levelText.paint(
      canvas,
      Offset(
        (gameRef.size.x - levelText.width) / 2,
        gameRef.size.y / 3,
      ),
    );
  }

  @override
  void update(double dt) {
    _timer?.update(dt);
    super.update(dt);
  }

  @override
  void onRemove() {
    _timer?.stop();
    super.onRemove();
  }
}