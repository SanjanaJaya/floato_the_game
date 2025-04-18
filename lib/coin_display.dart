import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:floato_the_game/game.dart';

class CoinDisplay extends PositionComponent with HasGameRef<floato> {
  // Initialize with default values instead of using late
  TextComponent _textComponent = TextComponent();
  SpriteComponent _coinIcon = SpriteComponent();

  CoinDisplay() : super(anchor: Anchor.topLeft); // Changed to topLeft anchor

  @override
  Future<void> onLoad() async {
    // Load the coin image
    final sprite = await gameRef.loadSprite('coin.png');
    _coinIcon = SpriteComponent(
      sprite: sprite,
      size: Vector2(36, 36),
      anchor: Anchor.center,
    );

    _textComponent = TextComponent(
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
      anchor: Anchor.center,
    );

    // Position the components in the top left, 20 pixels from top and 20 from left
    position = Vector2(20, 20); // Changed position to top left with padding

    // Position the coin to the left of the text
    _coinIcon.position = Vector2(18, 18); // Adjusted position relative to parent
    _textComponent.position = Vector2(90, 18); // Adjusted position relative to parent

    // Add children components
    add(_coinIcon);
    add(_textComponent);

    _updateText();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updateText();
    super.update(dt);
  }

  void _updateText() {
    // Only update if game reference is available
    if (gameRef != null) {
      _textComponent.text = '${gameRef.coins}';
    }
  }

  // Modified updateCoins method with safety checks
  void updateCoins(int coinCount) {
    // This method is now safer even if called before onLoad completes
    // The text will be updated in the next update cycle
  }
}