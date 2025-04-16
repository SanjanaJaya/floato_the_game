import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class HealthBar3D extends PositionComponent {
  final int maxHealth;
  int currentHealth;
  int _previousHealth;
  double _animationProgress = 1.0;

  // Paints for different layers
  final Paint backgroundPaint;
  final Paint healthPaint;
  final Paint healthShinePaint;
  final Paint borderPaint;
  final Paint depthPaint;

  // Animation properties
  static const animationDuration = 0.5; // seconds
  double _timeSinceUpdate = 0;

  // Dimensions for 3D effect
  final double depthHeight;
  final double borderWidth;
  final double cornerRadius;

  HealthBar3D({
    required this.maxHealth,
    required Vector2 position,
    required Vector2 size,
    this.depthHeight = 4.0,
    this.borderWidth = 1.5,
    this.cornerRadius = 6.0,
  }) :
        currentHealth = maxHealth,
        _previousHealth = maxHealth,
        backgroundPaint = Paint()
          ..color = const Color(0xFF222222)
          ..style = PaintingStyle.fill,
        healthPaint = Paint()
          ..style = PaintingStyle.fill,
        healthShinePaint = Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.white.withOpacity(0.4),
        borderPaint = Paint()
          ..color = const Color(0xFF444444)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
        depthPaint = Paint()
          ..color = const Color(0xFF111111)
          ..style = PaintingStyle.fill,
        super(
        position: position,
        size: size,
      );

  void updateHealth(int newHealth) {
    _previousHealth = currentHealth;
    currentHealth = newHealth.clamp(0, maxHealth);
    _animationProgress = 0.0;
    _timeSinceUpdate = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update animation
    if (_animationProgress < 1.0) {
      _timeSinceUpdate += dt;
      _animationProgress = (_timeSinceUpdate / animationDuration).clamp(0.0, 1.0);
    }
  }

  @override
  void render(Canvas canvas) {
    // Save the canvas state to restore later
    canvas.save();

    // Create a rounded rectangle for the background
    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(cornerRadius),
    );

    // Draw 3D depth effect
    final depthPath = Path()
      ..moveTo(0, size.y)
      ..lineTo(depthHeight, size.y + depthHeight)
      ..lineTo(size.x + depthHeight, size.y + depthHeight)
      ..lineTo(size.x, size.y)
      ..close();
    canvas.drawPath(depthPath, depthPaint);

    final rightDepthPath = Path()
      ..moveTo(size.x, 0)
      ..lineTo(size.x + depthHeight, depthHeight)
      ..lineTo(size.x + depthHeight, size.y + depthHeight)
      ..lineTo(size.x, size.y)
      ..close();
    canvas.drawPath(rightDepthPath, depthPaint);

    // Draw background (empty health bar)
    canvas.drawRRect(backgroundRect, backgroundPaint);

    // Calculate interpolated health value for smooth animation
    final interpolatedHealth = _previousHealth +
        (_animationProgress * (currentHealth - _previousHealth));

    // Update health paint based on health percentage
    final healthPercentage = interpolatedHealth / maxHealth;
    setHealthGradient(healthPercentage);

    // Draw health (filled portion)
    final healthWidth = healthPercentage * (size.x - borderWidth * 2);
    if (healthWidth > 0) {
      final healthBarRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
            borderWidth,
            borderWidth,
            healthWidth,
            size.y - borderWidth * 2
        ),
        Radius.circular(cornerRadius - borderWidth),
      );

      canvas.drawRRect(healthBarRect, healthPaint);

      // Draw shine effect on top of health bar
      final shineRect = Rect.fromLTWH(
          borderWidth,
          borderWidth,
          healthWidth,
          (size.y - borderWidth * 2) * 0.4
      );
      canvas.drawRect(shineRect, healthShinePaint);

      // Add pulsating effect if health is low
      if (healthPercentage < 0.3) {
        final pulseOpacity = (math.sin(_timeSinceUpdate * 10) * 0.3 + 0.7).clamp(0.4, 1.0);
        canvas.drawRRect(
            healthBarRect,
            Paint()
              ..color = Colors.red.withOpacity(pulseOpacity)
              ..style = PaintingStyle.fill
        );
      }
    }

    // Draw border
    canvas.drawRRect(backgroundRect, borderPaint);

    // Restore the canvas state
    canvas.restore();
  }

  // Create a gradient color based on health percentage
  void setHealthGradient(double healthPercentage) {
    final Rect gradientRect = Rect.fromLTWH(0, 0, size.x, size.y);

    if (healthPercentage < 0.3) {
      // Red gradient for low health
      healthPaint.shader = ui.Gradient.linear(
        gradientRect.topLeft,
        gradientRect.bottomLeft,
        [
          const Color(0xFFFF1E00),
          const Color(0xFFAA0000),
        ],
        [0.0, 1.0],
      );
    } else if (healthPercentage < 0.6) {
      // Orange gradient for medium health
      healthPaint.shader = ui.Gradient.linear(
        gradientRect.topLeft,
        gradientRect.bottomLeft,
        [
          const Color(0xFFFFAA00),
          const Color(0xFFDD7700),
        ],
        [0.0, 1.0],
      );
    } else {
      // Green gradient for high health
      healthPaint.shader = ui.Gradient.linear(
        gradientRect.topLeft,
        gradientRect.bottomLeft,
        [
          const Color(0xFF00FF60),
          const Color(0xFF00AA30),
        ],
        [0.0, 1.0],
      );
    }
  }
}