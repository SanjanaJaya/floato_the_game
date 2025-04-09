import 'package:flutter/material.dart';
import 'shared_preferences_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class TutorialScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const TutorialScreen({Key? key, required this.onComplete}) : super(key: key);

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int currentPage = 0;
  final int totalPages = 3; // Number of tutorial images

  // Tutorial content - add your actual content here
  final List<TutorialItem> tutorialItems = [
    TutorialItem(
      image: 'assets/images/tutorial/tutorial1.jpg',
      title: 'Welcome to Floato!',
      description: 'Tap and drag on the left side of the screen to move your bird up and down.',
    ),
    TutorialItem(
      image: 'assets/images/tutorial/tutorial2.jpg',
      title: 'Avoid Obstacles',
      description: 'Navigate through buildings and avoid enemy planes to survive longer!',
    ),
    TutorialItem(
      image: 'assets/images/tutorial/tutorial3.jpg',
      title: 'Special Abilities',
      description: 'Tap on the right side to shoot missiles and destroy enemy planes (available with advanced birds)!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: SafeArea(
        child: Column(
          children: [
            // Header with progress indicator
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  for (int i = 0; i < totalPages; i++)
                    Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: i <= currentPage ? Colors.amber : Colors.grey,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Tutorial content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tutorialItems[currentPage].title,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber, width: 2),
                      ),
                      child: Image.asset(
                        tutorialItems[currentPage].image,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      tutorialItems[currentPage].description,
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        color: Colors.white,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      // Mark tutorial as seen and complete
                      PreferencesHelper.saveTutorialSeen(true);
                      widget.onComplete();
                    },
                    style: TextButton.styleFrom(
                      textStyle: GoogleFonts.montserrat(),
                    ),
                    child: Text(
                      'SKIP',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (currentPage < totalPages - 1) {
                        setState(() {
                          currentPage++;
                        });
                      } else {
                        // Last page, mark tutorial as seen and complete
                        PreferencesHelper.saveTutorialSeen(true);
                        widget.onComplete();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: GoogleFonts.montserrat(),
                    ),
                    child: Text(
                      currentPage < totalPages - 1 ? 'NEXT' : 'START',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TutorialItem {
  final String image;
  final String title;
  final String description;

  TutorialItem({
    required this.image,
    required this.title,
    required this.description,
  });
}