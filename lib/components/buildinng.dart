import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:floato_the_game/constants.dart';
import 'package:floato_the_game/game.dart';

class Building extends SpriteComponent with CollisionCallbacks, HasGameRef<floato>{
  final bool isTopBuilding;

  bool scored = false;

  Building(Vector2 position, Vector2 size, {required this.isTopBuilding})
      : super(position: position, size: size);

  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load(isTopBuilding ? 'building.png' : 'building_bottom.png');

    add(RectangleHitbox());
  }

  @override
  void update(double dt){
    position.x -= groundScrollingSpeed * dt;

    if (!scored && position.x + size.x < gameRef.rocket.position.x){
      scored = true;

      if (isTopBuilding){
        gameRef.incrementScore();
      }
    }

    if (position.x + size.x <= 0){
      removeFromParent();
    }
  }
}