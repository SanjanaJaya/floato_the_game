import 'dart:async';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:floato_the_game/components/background.dart';
import 'package:floato_the_game/components/rocket.dart';
import 'package:floato_the_game/components/ground.dart';
import 'package:floato_the_game/constants.dart';
import 'package:flutter/material.dart';

class floato extends FlameGame with TapDetector, HasCollisionDetection{

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

  //Game Over
  bool isGameOver = false;

  void gameOver() {
    if (isGameOver) return;

    isGameOver = true;
    pauseEngine();

    showDialog(
      context: buildContext!,
      builder: (context) => AlertDialog(
        title: const Text("Game Over Hutto"),
        actions: [
          TextButton(
            onPressed: (){

              Navigator.pop(context);

              resetGame();
            },
            child: const Text("Restart"),
          )
        ],
      ),
    );
  }

  void resetGame(){
    rocket.position = Vector2(rocketStartX, rocketStartY);
    rocket.velocity = 0;
    isGameOver = false;
    resumeEngine();
  }

}

