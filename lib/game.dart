import 'dart:async';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:floato_the_game/components/background.dart';
import 'package:floato_the_game/components/rocket.dart';
import 'package:floato_the_game/components/ground.dart';

class floato extends FlameGame with TapDetector{

  late Rocket rocket;
  late Background background;
  late Ground ground;

  @override
  FutureOr<void> onLoad() {
    background = Background(size);
    add(background);

    rocket = Rocket();
    add(rocket);

    ground = Ground();
    add(ground);

  }

  @override
  void onTap() {
    rocket.flap();
  }


}

// 9.31