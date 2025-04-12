import 'package:floato_the_game/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  // Existing methods
  static Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('highScore') ?? 0;
  }

  static Future<void> saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHighScore = prefs.getInt('highScore') ?? 0;
    if (score > currentHighScore) {
      await prefs.setInt('highScore', score);
    }
  }

  static Future<int> getHighestLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('highestLevel') ?? 0;
  }

  static Future<void> saveHighestLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHighestLevel = prefs.getInt('highestLevel') ?? 0;
    if (level > currentHighestLevel) {
      await prefs.setInt('highestLevel', level);
    }
  }

  // Changed from private to public
  static Future<void> updateUnlockedRockets(int coins) async {
    int unlockedCount = 1; // Default has first rocket
    if (coins >= birdUnlockCosts[1]!) unlockedCount = 2;
    if (coins >= birdUnlockCosts[2]!) unlockedCount = 3;
    if (coins >= birdUnlockCosts[3]!) unlockedCount = 4;
    if (coins >= birdUnlockCosts[4]!) unlockedCount = 5;
    final prefs = await SharedPreferences.getInstance();
    final currentUnlocked = prefs.getInt('unlockedRockets') ?? 1;
    if (unlockedCount > currentUnlocked) {
      await prefs.setInt('unlockedRockets', unlockedCount);
      await prefs.setBool('newBirdUnlocked', true);
      await prefs.setInt('newlyUnlockedBird', unlockedCount - 1);
    }
  }

  static Future<int> getUnlockedRocketsCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('unlockedRockets') ?? 1;
  }

  static Future<int> getSelectedRocket() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('selectedRocket') ?? 0;
  }

  static Future<void> saveSelectedRocket(int rocketIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedRocket', rocketIndex);
  }

  static Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('coins') ?? 0;
  }

  static Future<void> saveCoins(int coins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', coins);
  }

  // New methods for tutorial
  static Future<bool> hasTutorialBeenSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tutorialSeen') ?? false;
  }

  static Future<void> saveTutorialSeen(bool seen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorialSeen', seen);
  }

  // Check if there's a new bird unlocked
  static Future<bool> hasNewBirdUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('newBirdUnlocked') ?? false;
  }

  // Get the index of newly unlocked bird
  static Future<int> getNewlyUnlockedBird() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('newlyUnlockedBird') ?? -1;
  }

  // Clear the new bird unlocked flag
  static Future<void> clearNewBirdUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('newBirdUnlocked', false);
  }
}