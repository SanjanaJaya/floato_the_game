import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';

class LevelUpNotification extends PositionComponent with HasGameRef {
  final String levelName;
  final String levelRange;
  Timer? _timer;

  LevelUpNotification({
    required this.levelName,
    required this.levelRange,
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

    final text = TextPainter(
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

    text.paint(
      canvas,
      Offset(
        (gameRef.size.x - text.width) / 2,
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