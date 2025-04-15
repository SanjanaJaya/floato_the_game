import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'language_manager.dart';

class LevelUpNotification extends PositionComponent with HasGameRef {
  final String levelName;
  final String levelRange;
  final String environmentName;
  Timer? _timer;
  late final bool _isSinhala;

  LevelUpNotification({
    required this.levelName,
    required this.levelRange,
    required this.environmentName,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Check if current language is Sinhala
    _isSinhala = LanguageManager.currentLanguage == LanguageManager.sinhala;

    // Display notification for 2.5 seconds then remove
    _timer = Timer(2.5, onTick: () => removeFromParent());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Create translucent background for better readability
    final Paint backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Make background taller for Sinhala to accommodate more space
    final double backgroundHeight = _isSinhala ? 200 : 160;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          gameRef.size.x * 0.1,
          gameRef.size.y * 0.3 - 80,
          gameRef.size.x * 0.8,
          backgroundHeight,
        ),
        Radius.circular(15),
      ),
      backgroundPaint,
    );

    // Get translated strings
    final String translatedWelcome = LanguageManager.getText('welcomeTo');
    final String translatedLevelReached = LanguageManager.getText('levelReached');
    final String translatedEnvironment = LanguageManager.getEnvironmentName(environmentName);

    // Adjust font size for Sinhala (slightly smaller to accommodate longer text)
    final double welcomeFontSize = _isSinhala ? 24 : 28;
    final double levelFontSize = _isSinhala ? 28 : 32;

    // Prepare welcome text
    final welcomeText = TextPainter(
      text: TextSpan(
        text: '$translatedWelcome $translatedEnvironment!',
        style: TextStyle(
          color: Colors.cyan,
          fontSize: welcomeFontSize,
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
      textDirection: _isSinhala ? TextDirection.ltr : TextDirection.ltr, // Always LTR for proper layout
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
          fontSize: levelFontSize,
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
      textDirection: _isSinhala ? TextDirection.ltr : TextDirection.ltr, // Always LTR for proper layout
      textAlign: TextAlign.center,
    );

    // Make sure to set width constraint for proper text wrapping
    levelText.layout(maxWidth: gameRef.size.x * 0.75);

    // Adjust vertical position for Sinhala
    final double welcomeYPosition = _isSinhala
        ? gameRef.size.y / 3 - 60
        : gameRef.size.y / 3 - 40;

    final double levelYPosition = _isSinhala
        ? gameRef.size.y / 3 + 20 // More space between welcome and level text for Sinhala
        : gameRef.size.y / 3 + 10;

    // Paint welcome text centered
    welcomeText.paint(
      canvas,
      Offset(
        (gameRef.size.x - welcomeText.width) / 2,
        welcomeYPosition,
      ),
    );

    // Paint level text centered
    levelText.paint(
      canvas,
      Offset(
        (gameRef.size.x - levelText.width) / 2,
        levelYPosition,
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