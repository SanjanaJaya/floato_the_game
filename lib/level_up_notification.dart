import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'language_manager.dart';

class LevelUpNotification extends PositionComponent with HasGameRef {
  final String levelName;
  final String levelRange;
  final String environmentName;
  Timer? _timer;
  late final TextDirection _textDirection;

  LevelUpNotification({
    required this.levelName,
    required this.levelRange,
    required this.environmentName,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Set text direction based on current language
    _textDirection = LanguageManager.currentLanguage == LanguageManager.sinhala
        ? TextDirection.rtl
        : TextDirection.ltr;

    // Display notification for 2.5 seconds then remove
    _timer = Timer(2.5, onTick: () => removeFromParent());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Create translucent background for better readability
    final Paint backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          gameRef.size.x * 0.1,
          gameRef.size.y * 0.3 - 60,
          gameRef.size.x * 0.8,
          160,
        ),
        Radius.circular(15),
      ),
      backgroundPaint,
    );

    // Get translated welcome text string
    final String translatedWelcome = LanguageManager.getText('welcomeTo');
    final String translatedLevelReached = LanguageManager.getText('levelReached');

    // Prepare welcome text
    final welcomeText = TextPainter(
      text: TextSpan(
        text: '$translatedWelcome $environmentName!',
        style: TextStyle(
          color: Colors.cyan,
          fontSize: 28,
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
      textDirection: _textDirection,
      textAlign: TextAlign.center,
    );

    // Make sure to set width constraint for proper text wrapping
    welcomeText.layout(maxWidth: gameRef.size.x * 0.75);

    // Prepare level text
    final levelText = TextPainter(
      text: TextSpan(
        text: '$levelName $translatedLevelReached\n$levelRange',
        style: TextStyle(
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
      textDirection: _textDirection,
      textAlign: TextAlign.center,
    );

    // Make sure to set width constraint for proper text wrapping
    levelText.layout(maxWidth: gameRef.size.x * 0.75);

    // Paint welcome text centered
    welcomeText.paint(
      canvas,
      Offset(
        (gameRef.size.x - welcomeText.width) / 2,
        gameRef.size.y / 3 - 40,
      ),
    );

    // Paint level text centered
    levelText.paint(
      canvas,
      Offset(
        (gameRef.size.x - levelText.width) / 2,
        gameRef.size.y / 3 + 10,
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