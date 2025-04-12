import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'splash_screen.dart';
import 'audio_manager.dart';
import 'game.dart';
import 'tutorial_screen.dart';
import 'loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Start with the splash screen
    ),
  );
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}