import 'package:flutter/material.dart';
import 'dart:ui' as ui;

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
      'developers': 'Developers',
      'Imesh Sanjana': 'Imesh Sanjana',
      'Nethsara Werasooriya': 'Nethsara Werasooriya',
      'Anjana Herath': 'Anjana Herath',
      'Nethmina Medagedara': 'Nethmina Medagedara',
      'Dinuwara Wijerathne': 'Dinuwara Wijerathne',
      'Kavindu Heshan': 'Kavindu Heshan',
      'back': 'Back',
      'newBirdUnlocked': 'NEW BIRD UNLOCKED!',
      'notEnoughCoins': 'Not Enough Coins',
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
      'bird5Name': 'Maelis',
      'bird6Name': 'Alarien',
      'bird7Name': 'Virel',
      'tipCollectAbilities': 'Collect abilities for extra power!',
      'tipTapToShoot': 'Tap right side of screen to shoot!',
      'tipWatchHelicopter': 'Watch out for big helicopter dangerous!',
      'tipHigherLevels': 'Higher levels will unlock different cities!',
      'tipCollectCoins': 'Collect more coins to unlock more powerful birds!',
      'tipSkyeAbility': 'Skye can\'t shoot. But he can shoot with rapid fire ability',
      'tipDifferentMissiles': 'All birds have different power missiles!',
      'loadingGame': 'Loading Game',
      'Score:': 'Score:',
      'level1': 'Level 1',
      'level2': 'Level 2',
      'level3': 'Level 3',
      'level4': 'Level 4',
      'level5': 'Level 5',
      'level6': 'Level 6',
      'level7': 'Level 7',
      'masterLevel': 'Master Level',
      'coins': 'coins',
      'paused': 'Paused',
      'resume': 'Resume',
      'quit': 'Quit',
      // Environment names
      'Anuradhapura': 'Anuradhapura',
      'Jaffna': 'Jaffna',
      'Galle': 'Galle',
      'Nuwara Eliya': 'Nuwara Eliya',
      'Sigiriya': 'Sigiriya',
      'Kandy': 'Kandy',
      'Colombo': 'Colombo',
      'Colombo Elite': 'Colombo Elite',
      'basicShooting': 'Basic Shooting (25 Damage)',
      'enhancedShooting': 'Enhanced Shooting (35 Damage)',
      'advancedShooting': 'Advanced Shooting (50 Damage)',
      'masterShooting': 'Master Shooting (80 Damage)',
      'powerShooting': 'Power Shooting (90 Damage)',
      'proShooting': 'Pro Shooting (105 Damage)',
      'infiniteShooting': 'Infinite Shooting (120 Damage)',
      'agileFlier': 'Agile Flier',
      'tutorialTitle1': 'Welcome to Floato!',
      'tutorialDesc1': 'Tap And Drag On The Left Side Of The Screen To Move Your Bird Up And Down.',
      'tutorialTitle2': 'Avoid Obstacles',
      'tutorialDesc2': 'Navigate Through Buildings And Avoid Enemy Planes To Survive Longer!',
      'tutorialTitle3': 'Special Abilities',
      'tutorialDesc3': 'Tap On The Right Side To Shoot Missiles And Destroy Enemy Planes (Available With Advanced Birds.Not Available With Skyee.)',
      'tutorialTitle4': 'Collect Special Abilities',
      'tutorialDesc4': 'Each Ability Has Different Powers.',
      'tutorialTitle5': 'Unlock Cities',
      'tutorialDesc5': 'Earn More Points To Unlock More Cities.',
      'tutorialTitle6': 'Different Point Values',
      'tutorialDesc6': 'Each Plane Has Different Point Values.',
      'skip': 'SKIP',
      'next': 'NEXT',
      'start': 'START',
      'gameOver': 'Game Over',
      'environment': 'Environment',
      'coinsCollected': 'Coins collected',
      'playAgain': 'Play Again',
    },
    sinhala: {
      'gameTitle': 'ෆ්ලෝටෝ',
      'highScore': 'ඉහළම ලකුණු',
      'highestLevel': 'ඉහළම මට්ටම',
      'startGame': 'ක්‍රීඩාව අරඹන්න',
      'selectBird': 'පක්ෂියා තෝරන්න',
      'developers': 'නිෂ්පාදකයන්',
      'Imesh Sanjana': 'ඉමේෂ් සංජන',
      'Nethsara Werasooriya': 'නෙත්සර වීරසූරිය',
      'Anjana Herath': 'අංජන හේරත්',
      'Nethmina Medagedara': 'නෙත්මිණ මැදගෙදර',
      'Dinuwara Wijerathne': 'දිනුවර විජේරත්න',
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
      'bird5Name': 'මේලිස්',
      'bird6Name': 'එලරින්',
      'bird7Name': 'වීරල්',
      'tipCollectAbilities': 'අතිරේක බලය සඳහා හැකියාවන් එකතු කරන්න!',
      'tipTapToShoot': 'වෙඩි තැබීමට තිරයේ දකුණු පැත්තට තට්ටු කරන්න!',
      'tipWatchHelicopter': 'විශාල හෙලිකොප්ටරය භයානකයි!',
      'tipHigherLevels': 'ඉහළ මට්ටම් විවිධ නගර අගුළු ඇරයවයි!',
      'tipCollectCoins': 'වැඩි බලසම්පන්න පක්ෂීන් අගුළු ඇරීම සඳහා කාසි එකතු කරන්න!',
      'tipSkyeAbility': 'ස්කයිට වෙඩි තැබීමට නොහැක. නමුත් ඔහුට ඉක්මන් වෙඩි තැබීමේ හැකියාව සමඟ වෙඩි තැබිය හැකිය',
      'tipDifferentMissiles': 'සියලුම පක්ෂීන්ට විවිධ බලමය මිසයිල ඇත!',
      'loadingGame': 'ක්‍රීඩාව පූරණය වෙමින් පවතී',
      'Score:': 'ලකුණු:',
      'level1': 'මට්ටම 1',
      'level2': 'මට්ටම 2',
      'level3': 'මට්ටම 3',
      'level4': 'මට්ටම 4',
      'level5': 'මට්ටම 5',
      'level6': 'මට්ටම 6',
      'level7': 'මට්ටම 7',
      'masterLevel': 'ප්‍රවීණ මට්ටම',
      'coins': 'කාසි',
      'paused': 'තාවකාලිකව නවතා ඇත',
      'resume': 'දිගටම යන්න',
      'quit': 'ඉවත්වන්න',
      // Environment names in Sinhala
      'Anuradhapura': 'අනුරාධපුර',
      'Jaffna': 'යාපනය',
      'Galle': 'ගාල්ල',
      'Nuwara Eliya': 'නුවරඑළිය',
      'Sigiriya': 'සීගිරිය',
      'Kandy': 'මහනුවර',
      'Colombo': 'කොළඹ',
      'Colombo Elite': 'කොළඹ ප්‍රධාන',
      'basicShooting': 'මූලික වෙඩි තැබීම (හානිය 25)',
      'enhancedShooting': 'වැඩිදියුණු වෙඩි තැබීම (හානිය 35)',
      'advancedShooting': 'උසස් වෙඩි තැබීම (හානිය 50)',
      'masterShooting': 'ප්‍රවීණ වෙඩි තැබීම (හානිය 80)',
      'powerShooting': 'බලවත් වෙඩි තැබීම (හානිය 90)',
      'proShooting': 'ප්‍රහාරක වෙඩි තැබීම (හානිය 105)',
      'infiniteShooting': 'අසීමිත වෙඩි තැබීම (හානිය 120)',
      'agileFlier': 'චපල පියාසැරිය',
      'tutorialTitle1': 'ෆ්ලෝටෝ වෙත සාදරයෙන් පිළිගන්නවා!',
      'tutorialDesc1': 'පක්ෂියා ඉහළට හෝ පහළට ගෙන යාමට තිරයේ වම් පැත්තට තට්ටු කර ඇදීම් කරන්න.',
      'tutorialTitle2': 'බාධක වලකන්න',
      'tutorialDesc2': 'ගොඩනැගිලි හරහා සැරිසරන්න සහ බොහෝ කල් ජීවත් වීමට සතුරු ගුවන්යානා වලකන්න!',
      'tutorialTitle3': 'විශේෂ හැකියාවන්',
      'tutorialDesc3': 'සතුරු ගුවන්යානා විනාශ කිරීමට මිසයිල වෙඩි තැබීමට තිරයේ දකුණු පැත්තට තට්ටු කරන්න (උසස් පක්ෂීන් සමඟ ලබා ගත හැකිය. ස්කයි සමඟ ලබා ගත නොහැක.)',
      'tutorialTitle4': 'විශේෂ හැකියාවන් එකතු කරන්න',
      'tutorialDesc4': 'එක් එක් හැකියාවට විවිධ බලයන් ඇත.',
      'tutorialTitle5': 'නගර අගුළු ඇරීම',
      'tutorialDesc5': 'වැඩි නගර අගුළු ඇරීම සඳහා වැඩි ලකුණු ලබා ගන්න.',
      'tutorialTitle6': 'විවිධ ලකුණු අගයන්',
      'tutorialDesc6': 'එක් එක් ගුවන්යානාවට විවිධ ලකුණු අගයන් ඇත.',
      'skip': 'ඉවත්වන්න',
      'next': 'ඊළඟ',
      'start': 'අරඹන්න',
      'gameOver': 'ක්‍රීඩාව අවසන්',
      'environment': 'පරිසරය',
      'coinsCollected': 'එකතු කළ කාසි',
      'playAgain': 'නැවත සෙල්ලම් කරන්න',
    },
  };

  // Get translated text for the given key
  static String getText(String key) {
    return _localizedValues[currentLanguage]?[key] ?? key;
  }

  // Change current language
  static void changeLanguage(String language) {
    if (_localizedValues.containsKey(language)) {
      currentLanguage = language;
    }
  }

  // Get current text direction based on language
  static TextDirection getTextDirection() {
    return currentLanguage == sinhala ? TextDirection.rtl : TextDirection.ltr;
  }

  // Get a translated level name by level number
  static String getLevelName(int levelNumber) {
    if (levelNumber > 7) {
      return getText('masterLevel');
    } else {
      return getText('level$levelNumber');
    }
  }

  // Get translated environment name
  static String getEnvironmentName(String englishName) {
    return getText(englishName);
  }

  // Measure text width for layout adjustments
  static double getTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: getTextDirection(),
    )..layout();
    return textPainter.width;
  }
}