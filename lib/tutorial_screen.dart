import 'package:flutter/material.dart';
import 'shared_preferences_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'language_manager.dart';

class TutorialScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const TutorialScreen({Key? key, required this.onComplete}) : super(key: key);

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int currentPage = 0;
  final int totalPages = 6; // Number of tutorial images

  // Tutorial content - now with support for both English and Sinhala
  final List<TutorialItem> tutorialItems = [
    TutorialItem(
      image: 'assets/images/tutorial/tutorial1.png',
      titleKey: 'tutorialTitle1',
      descriptionKey: 'tutorialDesc1',
    ),
    TutorialItem(
      image: 'assets/images/tutorial/tutorial2.png',
      titleKey: 'tutorialTitle2',
      descriptionKey: 'tutorialDesc2',
    ),
    TutorialItem(
      image: 'assets/images/tutorial/tutorial3.png',
      titleKey: 'tutorialTitle3',
      descriptionKey: 'tutorialDesc3',
    ),
    TutorialItem(
      image: 'assets/images/tutorial/tutorial4.png',
      titleKey: 'tutorialTitle4',
      descriptionKey: 'tutorialDesc4',
    ),
    TutorialItem(
      image: 'assets/images/tutorial/tutorial5.png',
      titleKey: 'tutorialTitle5',
      descriptionKey: 'tutorialDesc5',
    ),
    TutorialItem(
      image: 'assets/images/tutorial/tutorial5.png',
      titleKey: 'tutorialTitle6',
      descriptionKey: 'tutorialDesc6',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Container(
      color: Colors.black.withOpacity(0.8),
      child: SafeArea(
        child: Column(
          children: [
            // Header with progress indicator
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Row(
                children: [
                  for (int i = 0; i < totalPages; i++)
                    Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
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
                padding: EdgeInsets.all(screenWidth * 0.06),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      LanguageManager.getText(tutorialItems[currentPage].titleKey),
                      style: GoogleFonts.poppins(
                        fontSize: isPortrait ? screenWidth * 0.07 : screenHeight * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Container(
                      height: isPortrait ? screenHeight * 0.4 : screenWidth * 0.4,
                      width: isPortrait ? screenWidth * 0.8 : screenHeight * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber, width: 2),
                      ),
                      child: Image.asset(
                        tutorialItems[currentPage].image,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      child: Text(
                        LanguageManager.getText(tutorialItems[currentPage].descriptionKey),
                        style: GoogleFonts.roboto(
                          fontSize: isPortrait ? screenWidth * 0.045 : screenHeight * 0.045,
                          color: Colors.white,
                          height: 1.5,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: LanguageManager.currentLanguage == LanguageManager.sinhala
                            ? TextAlign.right
                            : TextAlign.center,
                        textDirection: LanguageManager.getTextDirection(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.06),
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
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      splashFactory: NoSplash.splashFactory,
                    ),
                    child: Text(
                      LanguageManager.getText('skip'),
                      style: GoogleFonts.montserrat(
                        fontSize: isPortrait ? screenWidth * 0.045 : screenHeight * 0.045,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
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
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.08,
                        vertical: screenHeight * 0.015,
                      ),
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: GoogleFonts.montserrat(),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: Text(
                      currentPage < totalPages - 1
                          ? LanguageManager.getText('next')
                          : LanguageManager.getText('start'),
                      style: GoogleFonts.montserrat(
                        fontSize: isPortrait ? screenWidth * 0.045 : screenHeight * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        decoration: TextDecoration.none,
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
  final String titleKey;
  final String descriptionKey;

  TutorialItem({
    required this.image,
    required this.titleKey,
    required this.descriptionKey,
  });
}