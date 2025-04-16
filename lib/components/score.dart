import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:floato_the_game/game.dart';
import 'package:flutter/material.dart';
import 'package:floato_the_game/language_manager.dart';

class ScoreText extends TextComponent with HasGameRef<floato> {
  int _lastScore = 0;
  late final Paint _glowPaint;

  // Constants for base dimensions to calculate scaling
  static const double baseWidth = 800.0;
  static const double baseHeight = 600.0;

  ScoreText()
      : super(
    text: 'Score: 0',
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 48,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.blue,
            blurRadius: 10,
            offset: Offset(0, 0),
          ),
        ],
      ),
    ),
    anchor: Anchor.center,
  );

  @override
  FutureOr<void> onLoad() async {
    // Update text style with responsive values now that gameRef is available
    double fontScale = (gameRef.size.x / baseWidth).clamp(0.8, 1.5);
    double shadowScale = gameRef.size.x / baseWidth;

    textRenderer = TextPaint(
      style: TextStyle(
        color: Colors.white,
        fontSize: 48 * fontScale,
        fontWeight: FontWeight.bold,
        shadows: [
        Shadow(
        color: Colors.blue,
        blurRadius: 10 * shadowScale,
        offset: const Offset(0, 0),
        ),
        ],
      ),
    );

    _glowPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..maskFilter = MaskFilter.blur(
          BlurStyle.normal, 15 * shadowScale);

    position = Vector2(
      gameRef.size.x / 2,
      gameRef.size.y - 50 * (gameRef.size.y / baseHeight),
    );

    add(
      MoveEffect.by(
        Vector2(0, -5 * (gameRef.size.y / baseHeight)),
        EffectController(
          duration: 1.5,
          alternate: true,
          infinite: true,
        ),
      ),
    );

    return super.onLoad();
  }

  @override
  void update(double dt) {
    final newScore = gameRef.score;
    // Use LanguageManager to get translated "Score:" text
    final newText = 'Score: $newScore';

    if (text != newText) {
      text = newText;

      if (newScore > _lastScore) {
        _animateScoreIncrease();
      }

      _lastScore = newScore;
    }

    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    final textRect = Rect.fromLTWH(0, 0, width, height);
    canvas.drawRect(textRect, _glowPaint);
    super.render(canvas);
  }

  void _animateScoreIncrease() {
    removeWhere((component) => component is ScaleEffect);

    double scaleAmount = 1.2 * (gameRef.size.x / baseWidth).clamp(0.8, 1.2);

    add(
      ScaleEffect.by(
        Vector2.all(scaleAmount),
        EffectController(
          duration: 0.2,
          alternate: true,
        ),
      ),
    );

    final colorController = EffectController(
      duration: 0.3,
      alternate: true,
    );

    add(
      ColorEffect(
        Colors.yellow,
        colorController,
      ),
    );
  }
}