import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class HealthBar extends PositionComponent {
  final int maxHealth;
  int currentHealth;
  final Paint backgroundPaint;
  final Paint healthPaint;

  HealthBar({
    required this.maxHealth,
    required Vector2 position,
    required Vector2 size,
  }) :
        currentHealth = maxHealth,
        backgroundPaint = Paint()..color = Colors.grey.withOpacity(0.8),
        healthPaint = Paint()..color = Colors.green,
        super(position: position, size: size);

  void updateHealth(int newHealth) {
    currentHealth = newHealth;
    if (currentHealth < 0) currentHealth = 0;

    // Change color based on health percentage
    final healthPercentage = currentHealth / maxHealth;
    if (healthPercentage < 0.3) {
      healthPaint.color = Colors.red;
    } else if (healthPercentage < 0.6) {
      healthPaint.color = Colors.orange;
    } else {
      healthPaint.color = Colors.green;
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw background (empty health bar)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      backgroundPaint,
    );

    // Draw health (filled portion)
    final healthWidth = (currentHealth / maxHealth) * size.x;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, healthWidth, size.y),
      healthPaint,
    );
  }
}