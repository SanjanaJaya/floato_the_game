import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:floato_the_game/game.dart';
import 'package:flutter/material.dart';

class ScoreText extends TextComponent with HasGameRef<floato> {
  int _lastScore = 0;
  late final Paint _glowPaint;

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
  FutureOr<void> onLoad() {
    _glowPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    position = Vector2(
      gameRef.size.x / 2,
      gameRef.size.y - 50,
    );

    // Add a subtle floating effect
    add(
      MoveEffect.by(
        Vector2(0, -5),
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
    final newText = 'Score: $newScore';

    if (text != newText) {
      text = newText;

      // Animate score change if it increased
      if (newScore > _lastScore) {
        _animateScoreIncrease();
      }

      _lastScore = newScore;
    }

    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    // Add glow effect behind text
    final textRect = Rect.fromLTWH(0, 0, width, height);
    canvas.drawRect(textRect, _glowPaint);

    super.render(canvas);
  }

  void _animateScoreIncrease() {
    // Remove any existing scale effects
    removeWhere((component) => component is ScaleEffect);

    // Add a pulse animation when score increases
    add(
      ScaleEffect.by(
        Vector2.all(1.2),
        EffectController(
          duration: 0.2,
          alternate: true,
        ),
      ),
    );

    // Add a color tint effect
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