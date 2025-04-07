import 'dart:async';

import 'package:flame/components.dart';
import 'package:floato_the_game/constants.dart';
import 'package:floato_the_game/game.dart';

class Ground extends SpriteComponent with HasGameRef<floato>{
  Ground() : super();


  @override
  FutureOr<void> onLoad() async{
    size = Vector2(gameRef.size.x, groundHeight);
    position = Vector2(0, gameRef.size.y-groundHeight);

    sprite = await Sprite.load('ground.png');
  }

}