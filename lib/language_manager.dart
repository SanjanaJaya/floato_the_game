import 'package:flutter/material.dart';

class LanguageManager {
  static const String english = 'en';
  static const String sinhala = 'si';

  static String currentLanguage = english;

  static Map<String, Map<String, String>> _localizedValues = {
    english: {
      'gameTitle': 'Floato',
      'highScore': 'HIGH SCORE',
      'highestLevel': 'HIGHEST LEVEL',
      'startGame': 'Start Game',
      'selectBird': 'Select Bird',
      'credits': 'Credits',
      'mainDeveloper': 'Main Developer',
      'Imesh Sanjana': 'Imesh Sanjana',
      'graphicsAndIllustrations': 'Graphics & Illustrations',
      'Nethsara Werasooriya': 'Nethsara Werasooriya',
      'Anjana Herath': 'Anjana Herath',
      'Nethmina Medagedara': 'Nethmina Medagedara',
      'Dinuwara Wijerathne': 'Dinuwara Wijerathne',
      'audioEffectsAndMusic': 'Audio Effects & Music',
      'Kavindu Heshan': 'Kavindu Heshan',
      'back': 'Back',
      'newBirdUnlocked': 'NEW BIRD UNLOCKED!',
      'notEnoughCoins': 'notEnoughCoins',
      'need': 'need',
      'more': 'more',
      'awesome': 'Awesome!',
      'levelReached': 'REACHED!',
      'welcomeTo': 'Welcome to',
      'bird0Name': 'Skye',
      'bird1Name': 'Nyra',
      'bird2Name': 'Seren',
      'bird3Name': 'Elowen',
      'bird4Name': 'Zephyr',
      'tipCollectAbilities': 'Collect abilities for extra power!',
      'tipTapToShoot': 'Tap right side of screen to shoot!',
      'tipWatchHelicopter': 'Watch out for big helicopter dangerous!',
      'tipHigherLevels': 'Higher levels wil unlock differen cities!',
      'tipCollectCoins': 'Collect more coins to unlock more powerful birds!',
      'tipSkyeAbility': 'Skyee can\'t shoot.But he can shoot whith rapid fire ability',
      'tipDifferentMissiles': 'All birds have different power missiles!',
      'loadingGame': 'Loading Game',
      'Score:': 'Score:',
    },
    sinhala: {
      'gameTitle': 'ෆ්ලෝටෝ',
      'highScore': 'ඉහළම ලකුණු',
      'highestLevel': 'ඉහළම මට්ටම',
      'startGame': 'ක්‍රීඩාව අරඹන්න',
      'selectBird': 'පක්ෂියා තෝරන්න',
      'credits': 'කතුවරුන්',
      'mainDeveloper': 'ප්රධාන සංවර්ධකයා',
      'Imesh Sanjana': 'ඉමේෂ් සoජන',
      'graphicsAndIllustrations': 'ග්‍රැෆික්ස් සහ රූප රාමු',
      'Nethsara Werasooriya': 'නෙත්සර වීරසූරිය',
      'Anjana Herath': 'අoජන හේරත්',
      'Nethmina Medagedara': 'නෙත්මින මැදගෙදර',
      'Dinuwara Wijerathne': 'දිනුවර විජේරත්න',
      'audioEffectsAndMusic': 'සංගීතය',
      'Kavindu Heshan': 'කවිදු හෙෂාන්',
      'back': 'ආපසු',
      'newBirdUnlocked': 'නව පක්ෂියා අගුළු හරින ලදි!',
      'notEnoughCoins': 'කාසි ප්‍රමාණවන් නැත',
      'need': 'අවශ්යයි',
      'more': 'තව',
      'awesome': 'අපූරු!',
      'levelReached': 'මට්ටමට ළඟා විය!',
      'welcomeTo': 'සාදරයෙන් පිළිගන්නවා',
      'bird0Name': 'ස්කයි',
      'bird1Name': 'නයිරා',
      'bird2Name': 'සෙරෙන්',
      'bird3Name': 'එලෝවෙන්',
      'bird4Name': 'සෙෆයර්',
      'tipCollectAbilities': 'අතිරේක බලය සඳහා හැකියාවන් එකතු කරන්න!',
      'tipTapToShoot': 'වෙඩි තැබීමට තිරයේ දකුණු පැත්තට තට්ටු කරන්න!',
      'tipWatchHelicopter': 'විශාල හෙලිකොප්ටරය භයානකයි!',
      'tipHigherLevels': 'ඉහළ මට්ටම් විවිධ නගර අගුළු ඇරයවයි!',
      'tipCollectCoins': 'වැඩි බලසම්පන්න පක්ෂීන් අගුළු ඇරීම සඳහා කාසි එකතු කරන්න!',
      'tipSkyeAbility': 'ස්කයිට වෙඩි තැබීමට නොහැක. නමුත් ඔහුට ඉක්මන් වෙඩි තැබීමේ හැකියාව සමඟ වෙඩි තැබිය හැකිය',
      'tipDifferentMissiles': 'සියලුම පක්ෂීන්ට විවිධ බලමය මිසයිල ඇත!',
      'loadingGame': 'ක්‍රීඩාව පූරණය වෙමින් පවතී',
      'Score:': 'ලකුණු:'
    },
  };

  static String getText(String key) {
    return _localizedValues[currentLanguage]![key] ?? key;
  }

  static void changeLanguage(String language) {
    currentLanguage = language;
  }
}