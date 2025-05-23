import 'package:flutter/material.dart';
import 'package:floato_the_game/constants.dart';
import 'language_manager.dart';

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
    // Get the translated bird name from LanguageManager
    String birdName = LanguageManager.getText('bird${widget.birdIndex}Name');
    // Set text direction based on current language
    TextDirection textDirection = LanguageManager.getTextDirection();

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
        child: Directionality(
          textDirection: textDirection,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LanguageManager.getText('newBirdUnlocked'),
                style: const TextStyle(
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
                birdName,
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
                child: Text(
                  LanguageManager.getText('awesome'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBirdAbility(int birdIndex) {
    String ability;
    IconData icon;
    Color color;

    // Translate ability descriptions
    switch (birdIndex) {
      case 1:
        ability = LanguageManager.getText('basicShooting');
        icon = Icons.flash_on;
        color = Colors.yellow;
        break;
      case 2:
        ability = LanguageManager.getText('enhancedShooting');
        icon = Icons.bolt;
        color = Colors.orange;
        break;
      case 3:
        ability = LanguageManager.getText('advancedShooting');
        icon = Icons.electric_bolt;
        color = Colors.red;
        break;
      case 4:
        ability = LanguageManager.getText('masterShooting');
        icon = Icons.thunderstorm;
        color = Colors.purple;
        break;
      case 5:
        ability = LanguageManager.getText('powerShooting');
        icon = Icons.thunderstorm;
        color = Colors.purpleAccent;
        break;
      case 6:
        ability = LanguageManager.getText('proShooting');
        icon = Icons.thunderstorm;
        color = Colors.deepPurple;
        break;
      case 7:
        ability = LanguageManager.getText('infiniteShooting');
        icon = Icons.thunderstorm;
        color = Colors.deepPurpleAccent;
        break;
      default: // case 0
        ability = LanguageManager.getText('agileFlier');
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