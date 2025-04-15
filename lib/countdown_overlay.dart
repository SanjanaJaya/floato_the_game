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
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  int _count = 3;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Added new animations
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.3), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 1),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          if (_count > 1) {
            _count--;
            _controller.reset();
            _controller.forward();
          } else {
            widget.game.overlays.remove('countdown');
            widget.game.startGameAfterCountdown();
          }
        });
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // Made background transparent
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                opacity: _opacityAnimation,
                child: Text(
                '$_count',
                style: GoogleFonts.poppins(
                fontSize: 120,
                fontWeight: FontWeight.bold,
                color: _count == 3 ? Colors.red :
                _count == 2 ? Colors.yellow : Colors.green,
                decoration: TextDecoration.none, // Removed underline
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