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
      gameRef.size.x / 2 - 120 * gameRef.scaleFactor, // Reduced from 150 to 120
      38 * gameRef.heightScaleFactor,
    );
    size = Vector2(
      240 * gameRef.scaleFactor, // Reduced from 300 to 240
      50 * gameRef.heightScaleFactor,
    );
    priority = 10;
    await super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (gameRef.currentAbility != null) {
      final ability = gameRef.currentAbility!;
      final remaining = gameRef.abilityDuration;
      final maxDuration = _abilityDurations[ability]!;

      // Calculate progress percentage (0.0 to 1.0) with clamp to ensure it doesn't go below 0
      final progress = (remaining / maxDuration).clamp(0.0, 1.0);

      // Draw background container with rounded corners and border
      final backgroundPaint = Paint()
        ..color = Colors.black.withOpacity(0.7)
        ..style = PaintingStyle.fill;
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final backgroundRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Radius.circular(25 * gameRef.scaleFactor),
      );
      canvas.drawRRect(backgroundRRect, backgroundPaint);
      canvas.drawRRect(backgroundRRect, borderPaint);

      // Draw progress bar with gradient colors only if there's remaining time
      if (remaining > 0) {
        // Save the canvas state before clipping
        canvas.save();

        // Create a path from the background RRect to use for clipping
        final clipPath = Path()..addRRect(backgroundRRect);
        canvas.clipPath(clipPath);

        // Now draw the progress bar - it will be clipped to the background shape
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

        // Just draw a regular rectangle - the clipping will handle the corners
        canvas.drawRect(progressBarRect, progressBarPaint);

        // Restore the canvas to remove the clipping
        canvas.restore();
      }

      // Draw ability icon (larger and centered vertically)
      final iconStyle = TextStyle(
        fontSize: 28 * gameRef.scaleFactor,
        color: Colors.white,
        fontFamily: 'Arial',
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 2 * gameRef.scaleFactor,
            offset: Offset(1 * gameRef.scaleFactor, 1 * gameRef.scaleFactor),
          ),
        ],
      );

      final icon = TextPainter(
        text: TextSpan(
          text: _getAbilityIcon(ability),
          style: iconStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      icon.paint(canvas, Offset(
          15 * gameRef.scaleFactor,
          (size.y - icon.height) / 2
      ));

      // Draw ability name
      final nameStyle = TextStyle(
        fontSize: 18 * gameRef.scaleFactor,
        color: Colors.white,
        fontFamily: 'Arial',
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 2 * gameRef.scaleFactor,
            offset: Offset(1 * gameRef.scaleFactor, 1 * gameRef.scaleFactor),
          ),
        ],
      );

      final name = TextPainter(
        text: TextSpan(
          text: _getAbilityName(ability),
          style: nameStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      name.paint(canvas, Offset(
          60 * gameRef.scaleFactor,
          (size.y - name.height) / 2
      ));

      // Draw timer with dynamic color based on remaining time
      final timerColor = progress > 0.5
          ? Colors.green
          : progress > 0.2
          ? Colors.yellow
          : Colors.red;

      final timerStyle = TextStyle(
        fontSize: 18 * gameRef.scaleFactor,
        color: timerColor,
        fontFamily: 'Arial',
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 2 * gameRef.scaleFactor,
            offset: Offset(1 * gameRef.scaleFactor, 1 * gameRef.scaleFactor),
          ),
        ],
      );

      final timerText = remaining > 0 ? '${remaining.toStringAsFixed(1)}s' : '0.0s';
      final timer = TextPainter(
        text: TextSpan(
          text: timerText,
          style: timerStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      timer.paint(canvas, Offset(
          size.x - timer.width - 15 * gameRef.scaleFactor,
          (size.y - timer.height) / 2
      ));
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