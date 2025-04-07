import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game.dart';
import 'package:flame_audio/flame_audio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlameAudio.audioCache.load('crash.wav');
  runApp(const Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameWidget(game: floato()),
    );
  }
}
