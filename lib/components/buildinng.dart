import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:floato_the_game/constants.dart';
import 'package:floato_the_game/game.dart';

class Building extends SpriteComponent with CollisionCallbacks, HasGameRef<floato>{
  final bool isTopBuilding;

  Building(Vector2 position, Vector2 size, {required this.isTopBuilding}) : super(position: position, size: size);

  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load(isTopBuilding ? 'building.png' : 'building_bottom.png');

    add(RectangleHitbox());
  }

  @override
  void update(double dt){
    position.x -= groundScrollingSpeed * dt;

    if (position.x + size.x <= 0){
      removeFromParent();
    }
  }
}