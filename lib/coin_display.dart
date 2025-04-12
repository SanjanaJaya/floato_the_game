import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:floato_the_game/game.dart';

class CoinDisplay extends TextComponent with HasGameRef<floato> {
  CoinDisplay()
      : super(
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 36,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black,
            blurRadius: 5,
            offset: Offset(2, 2),
          ),
        ],
      ),
    ),
    anchor: Anchor.topLeft,
  );

  @override
  Future<void> onLoad() async {
    position = Vector2(20, 20);
    _updateText();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updateText();
    super.update(dt);
  }

  void _updateText() {
    text = 'Coins: ${gameRef.coins}';
  }
}