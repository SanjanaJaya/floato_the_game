import 'dart:async';

import 'package:flame/components.dart';
import 'package:floato_the_game/constants.dart';

class Rocket extends SpriteComponent{

  Rocket() : super(position: Vector2(rocketStartX, rocketStartY),size: Vector2(rocketWidth, rocketHeight));

  double velocity = 0;


  @override
  FutureOr<void> onLoad() async {
    // TODO: implement onLoad
    sprite = await Sprite.load('rocket.png');
  }

  void flap(){
    velocity = jumpStrength;
  }

  @override
  void update(double dt) {
    velocity += gravity * dt;

    position.y += velocity * dt;
  }
}