import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlameAudio.audioCache.load('crash.wav');
  // You might want to load menu background music as well
  await FlameAudio.audioCache.load('menu_music.wav');
  runApp(const Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MenuScreen(),
    );
  }
}