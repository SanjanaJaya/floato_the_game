import 'package:flame/components.dart';
import 'package:floato_the_game/game.dart';
import 'package:floato_the_game/special_ability.dart';
import 'package:flutter/material.dart';

class AbilityIndicator extends PositionComponent with HasGameRef<floato> {
  // Store max duration for each ability type
  final Map<AbilityType, double> _abilityDurations = {
    AbilityType.doubleScore: 10.0,
    AbilityType.invincibility: 8.0,
    AbilityType.slowMotion: 12.0,
    AbilityType.rapidFire: 15.0,
  };

  @override
  Future<void> onLoad() async {
    position = Vector2(
      gameRef.size.x / 2 - 150, // Centered horizontally with 300 width
      20, // 20 pixels from top
    );
    size = Vector2(300, 50); // Slightly larger for better visibility
    priority = 10;
    await super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (gameRef.currentAbility != null) {
      final ability = gameRef.currentAbility!;
      final remaining = gameRef.abilityDuration; // Accessing the private duration
      final maxDuration = _abilityDurations[ability]!;

      // Calculate progress percentage (0.0 to 1.0)
      final progress = remaining / maxDuration;

      // Draw background container with rounded corners and border
      final backgroundPaint = Paint()
        ..color = Colors.black.withOpacity(0.7)
        ..style = PaintingStyle.fill;
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.x, size.y),
          Radius.circular(25),
        ),
        backgroundPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.x, size.y),
          Radius.circular(25),
        ),
        borderPaint,
      );

      // Draw progress bar with gradient colors
      final progressBarRect = Rect.fromLTWH(
        0,
        0,
        size.x * progress,
        size.y,
      );
      final progressBarPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.green,
            progress > 0.5 ? Colors.green : Colors.yellow,
            progress > 0.2 ? Colors.yellow : Colors.red,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          progressBarRect,
          Radius.circular(25),
        ),
        progressBarPaint,
      );

      // Draw ability icon (larger and centered vertically)
      final icon = TextPainter(
        text: TextSpan(
          text: _getAbilityIcon(ability),
          style: TextStyle(
            fontSize: 28,
            color: Colors.white,
            fontFamily: 'Arial',
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.8),
                blurRadius: 2,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      icon.paint(canvas, Offset(15, (size.y - icon.height) / 2));

      // Draw ability name
      final name = TextPainter(
        text: TextSpan(
          text: _getAbilityName(ability),
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontFamily: 'Arial',
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.8),
                blurRadius: 2,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      name.paint(canvas, Offset(60, (size.y - name.height) / 2));

      // Draw timer with dynamic color based on remaining time
      final timerColor = progress > 0.5
          ? Colors.green
          : progress > 0.2
          ? Colors.yellow
          : Colors.red;

      final timer = TextPainter(
        text: TextSpan(
          text: remaining.toStringAsFixed(1) + 's',
          style: TextStyle(
            fontSize: 18,
            color: timerColor,
            fontFamily: 'Arial',
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.8),
                blurRadius: 2,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      timer.paint(canvas, Offset(size.x - timer.width - 15, (size.y - timer.height) / 2));
    }
  }

  String _getAbilityIcon(AbilityType ability) {
    switch (ability) {
      case AbilityType.doubleScore:
        return '2X';
      case AbilityType.invincibility:
        return '🛡️';
      case AbilityType.slowMotion:
        return '🐢';
      case AbilityType.rapidFire:
        return '💥';
    }
  }

  String _getAbilityName(AbilityType ability) {
    switch (ability) {
      case AbilityType.doubleScore:
        return 'DOUBLE SCORE';
      case AbilityType.invincibility:
        return 'INVINCIBILITY';
      case AbilityType.slowMotion:
        return 'SLOW MOTION';
      case AbilityType.rapidFire:
        return 'RAPID FIRE';
    }
  }
}