import 'dart:async';

import 'package:flame/components.dart';

class Rocket extends SpriteComponent{

  Rocket() : super(position: Vector2(100, 100),size: Vector2(60, 40));

  double velocity = 0;
  final double gravity = 800;
  final double jumpStrength = -300;

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