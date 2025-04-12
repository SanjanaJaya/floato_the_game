import 'package:flutter/material.dart';
import 'package:floato_the_game/constants.dart';

class BirdUnlockNotification extends StatefulWidget {
  final Function onClose;
  final int birdIndex;

  const BirdUnlockNotification({
    Key? key,
    required this.onClose,
    required this.birdIndex,
  }) : super(key: key);

  @override
  State<BirdUnlockNotification> createState() => _BirdUnlockNotificationState();
}

class _BirdUnlockNotificationState extends State<BirdUnlockNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Setup animation for hover effect
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
      setState(() {});
    });

    // Make animation repeat back and forth
    _animationController.repeat(reverse: true);


  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.amber,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'NEW BIRD UNLOCKED!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 5,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Animated bird image
            Transform.translate(
              offset: Offset(0, _animation.value),
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.amber.withOpacity(0.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.asset(
                    'assets/images/bird/${rocketImages[widget.birdIndex]}',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              rocketNames[widget.birdIndex],
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            _buildBirdAbility(widget.birdIndex),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                widget.onClose();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: const Text(
                'Awesome!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirdAbility(int birdIndex) {
    String ability;
    IconData icon;
    Color color;

    switch (birdIndex) {
      case 1:
        ability = 'Basic Shooting (25 damage)';
        icon = Icons.flash_on;
        color = Colors.yellow;
        break;
      case 2:
        ability = 'Enhanced Shooting (35 damage)';
        icon = Icons.bolt;
        color = Colors.orange;
        break;
      case 3:
        ability = 'Advanced Shooting (50 damage)';
        icon = Icons.electric_bolt;
        color = Colors.red;
        break;
      case 4:
        ability = 'Master Shooting (80 damage)';
        icon = Icons.thunderstorm;
        color = Colors.purple;
        break;
      default:
        ability = 'Agile Flier';
        icon = Icons.air;
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 10),
          Text(
            ability,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}