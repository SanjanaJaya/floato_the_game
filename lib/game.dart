import 'dart:async';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:floato_the_game/components/background.dart';
import 'package:floato_the_game/components/rocket.dart';

class floato extends FlameGame with TapDetector{

  late Rocket rocket;
  late Background background;

  @override
  FutureOr<void> onLoad() {
    background = Background(size);
    add(background);

    rocket = Rocket();
    add(rocket);

  }

  @override
  void onTap() {
    rocket.flap();
  }


}

// 9.31