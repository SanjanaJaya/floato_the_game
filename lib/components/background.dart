import 'dart:async';
import 'package:flame/components.dart';
import 'package:floato_the_game/constants.dart';

class Background extends SpriteComponent with HasGameRef {
  String currentBackground = backgroundImages[0];
  String currentEnvironmentName = levelNames[0];

  Background(Vector2 size)
      : super(
    size: size,
    position: Vector2(0, 0),
  );

  @override
  FutureOr<void> onLoad() async {
    await updateBackground(0);
  }

  Future<void> updateBackground(int levelThreshold) async {
    final settings = difficultyLevels[levelThreshold]!;
    currentBackground = settings['backgroundImage'];
    currentEnvironmentName = settings['environmentName'];
    sprite = await Sprite.load(currentBackground);
  }
}