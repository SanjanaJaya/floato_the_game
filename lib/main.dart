import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_screen.dart';
import 'audio_manager.dart';
import 'game.dart';
import 'tutorial_screen.dart';
import 'loading_screen.dart';
import 'language_manager.dart';

class AdManager {
  static InterstitialAd? _interstitialAd;
  static bool _isAdLoaded = false;

  // Banner ad ID for loading screen
  static const String bannerAdUnitId = 'ca-app-pub-2235164538831559/9968424124';

  // Interstitial ad ID
  static const String interstitialAdUnitId = 'ca-app-pub-2235164538831559/3346766334';

  static void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          print('Interstitial ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Interstitial ad failed to load: $error');
          _isAdLoaded = false;
        },
      ),
    );
  }

  static void showInterstitialAd() {
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadInterstitialAd(); // Load a new ad after this one is dismissed
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('Failed to show ad: $error');
          ad.dispose();
          loadInterstitialAd();
        },
      );
      _interstitialAd?.show();
      _interstitialAd = null;
      _isAdLoaded = false;
    } else {
      print('Ad not ready yet');
      loadInterstitialAd(); // Try to load another ad if current one isn't ready
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Mobile Ads SDK
  await MobileAds.instance.initialize();

  // Enable test mode for development (remove for production)
  // MobileAds.instance.updateRequestConfiguration(
  //   RequestConfiguration(testDeviceIds: ['YOUR_TEST_DEVICE_ID']),
  // );

  // Load language preference
  final prefs = await SharedPreferences.getInstance();
  final isSinhala = prefs.getBool('isSinhala') ?? false;
  LanguageManager.changeLanguage(isSinhala ? LanguageManager.sinhala : LanguageManager.english);

  // Load the first interstitial ad
  AdManager.loadInterstitialAd();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SafeArea(
        child: SplashScreen(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}