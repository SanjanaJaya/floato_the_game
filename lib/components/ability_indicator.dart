import 'package:flame/components.dart';
import 'package:floato_the_game/game.dart';
import 'package:floato_the_game/special_ability.dart'; // Add this import
import 'package:flutter/material.dart';


class AbilityIndicator extends PositionComponent with HasGameRef<floato> {
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (gameRef.currentAbility != null) { // Changed from _currentAbility to currentAbility
      final ability = gameRef.currentAbility!; // Changed from _currentAbility to currentAbility
      final remaining = gameRef.abilityDuration; // This will need to be made public too

      // Draw ability icon and timer
      final icon = TextPainter(
        text: TextSpan(
          text: _getAbilityIcon(ability),
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontFamily: 'Arial',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final timer = TextPainter(
        text: TextSpan(
          text: remaining.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontFamily: 'Arial',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      icon.paint(canvas, Offset(10, 10));
      timer.paint(canvas, Offset(40, 14));
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
}