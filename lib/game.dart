import 'dart:async';

import 'package:flame/game.dart';
import 'package:floato_the_game/components/rocket.dart';

class floato extends FlameGame{

  late Rocket rocket;

  @override
  FutureOr<void> onLoad() {
    rocket = Rocket();
    add(rocket);
  }


}