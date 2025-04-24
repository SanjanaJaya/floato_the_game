import 'package:flutter/material.dart';
import 'shared_preferences_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'language_manager.dart';
import 'package:video_player/video_player.dart';

class TutorialScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const TutorialScreen({Key? key, required this.onComplete}) : super(key: key);

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int currentPage = 0;
  final int tutorialPages = 6; // Number of tutorial images
  final int totalPages = 7; // Tutorial pages + cutscene
  late VideoPlayerController _cutsceneController;
  bool _isCutscenePlaying = false;
  bool _isCutsceneInitialized = false;

  // Tutorial content - now with support for both English and Sinhala
  final List<TutorialItem> tutorialItems = [
    TutorialItem(
      image: 'assets/images/tutorial/tutorial1.gif',
      titleKey: 'tutorialTitle1',
      descriptionKey: 'tutorialDesc1',
    ),
    TutorialItem(
      image: 'assets/images/tutorial/tutorial2.png',
      titleKey: 'tutorialTitle2',
      descriptionKey: 'tutorialDesc2',
    ),
    TutorialItem(
      image: 'assets/images/tutorial/tutorial3.gif',
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
      image: 'assets/images/tutorial/tutorial6.png',
      titleKey: 'tutorialTitle6',
      descriptionKey: 'tutorialDesc6',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeCutscene();
  }

  Future<void> _initializeCutscene() async {
    final isSinhala = LanguageManager.currentLanguage == LanguageManager.sinhala;
    final videoPath = isSinhala
        ? 'assets/videos/cutscene_sinhala.mp4'
        : 'assets/videos/cutscene_english.mp4';

    _cutsceneController = VideoPlayerController.asset(videoPath)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isCutsceneInitialized = true;
          });
        }
      })
      ..addListener(() {
        if (_cutsceneController.value.isCompleted && _isCutscenePlaying) {
          _completeTutorial();
        }
      });
  }

  void _completeTutorial() {
    PreferencesHelper.saveTutorialSeen(true);
    widget.onComplete();
  }

  @override
  void dispose() {
    _cutsceneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Container(
      color: Colors.black.withOpacity(0.8),
      child: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
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

                if (currentPage < tutorialPages) ...[
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
                ] else ...[
                  // Cutscene content
                  Expanded(
                    child: _isCutsceneInitialized
                        ? AspectRatio(
                      aspectRatio: _cutsceneController.value.aspectRatio,
                      child: VideoPlayer(_cutsceneController),
                    )
                        : Center(
                      child: CircularProgressIndicator(
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ],

                // Navigation buttons
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.06),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Mark tutorial as seen and complete
                          _completeTutorial();
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
                          if (currentPage < tutorialPages - 1) {
                            setState(() {
                              currentPage++;
                            });
                          } else if (currentPage == tutorialPages - 1) {
                            // Last tutorial page, start cutscene
                            setState(() {
                              currentPage++;
                              _isCutscenePlaying = true;
                              _cutsceneController.play();
                            });
                          } else {
                            // Cutscene is playing, skip to game
                            _completeTutorial();
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
                          currentPage < tutorialPages - 1
                              ? LanguageManager.getText('next')
                              : currentPage == tutorialPages - 1
                              ? LanguageManager.getText('watchCutscene')
                              : LanguageManager.getText('play'),
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