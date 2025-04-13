import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_screen.dart';
import 'audio_manager.dart';
import 'game.dart';
import 'tutorial_screen.dart';
import 'loading_screen.dart';
import 'language_manager.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load language preference
  final prefs = await SharedPreferences.getInstance();
  final isSinhala = prefs.getBool('isSinhala') ?? false;
  LanguageManager.changeLanguage(isSinhala ? LanguageManager.sinhala : LanguageManager.english);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
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