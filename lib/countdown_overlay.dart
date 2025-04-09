import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game.dart';

class CountdownOverlay extends StatefulWidget {
  final floato game;

  const CountdownOverlay({Key? key, required this.game}) : super(key: key);

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _count = 3;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for the countdown
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Add listener to update the count
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          if (_count > 1) {
            _count--;
            _controller.reset();
            _controller.forward();
          } else {
            // When countdown finishes, remove overlay and resume game
            widget.game.overlays.remove('countdown');
            widget.game.startGameAfterCountdown();
          }
        });
      }
    });

    // Start the countdown animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Scale animation effect
            final scale = 1.0 + _controller.value * 0.5; // Grows from 1.0 to 1.5
            final opacity = 1.0 - _controller.value * 0.5; // Fades from 1.0 to 0.5

            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Text(
                  '$_count',
                  style: GoogleFonts.poppins(
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                    color: _count == 3 ? Colors.red :
                    _count == 2 ? Colors.yellow : Colors.green,
                    shadows: [
                      Shadow(
                        blurRadius: 20,
                        color: Colors.black,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}