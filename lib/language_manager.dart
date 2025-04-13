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
    },
  };

  static String getText(String key) {
    return _localizedValues[currentLanguage]![key] ?? key;
  }

  static void changeLanguage(String language) {
    currentLanguage = language;
  }
}