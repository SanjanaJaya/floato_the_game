import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'audio_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize audio manager and ensure it completes
  final audioManager = AudioManager();
  await audioManager.init();

  // Add a delay to ensure audio initialization is complete
  await Future.delayed(Duration(milliseconds: 500));

  runApp(const Myapp());
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