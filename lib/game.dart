import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:floato_the_game/components/rocket.dart';

class floato extends FlameGame with TapDetector{

  late Rocket rocket;

  @override
  FutureOr<void> onLoad() {
    rocket = Rocket();
    add(rocket);
  }

  @override
  void onTap() {
    rocket.flap();
  }


}