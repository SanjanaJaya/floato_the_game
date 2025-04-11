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

      // Update unlocked rockets based on level
      await _updateUnlockedRockets(level);
    }
  }

  static Future<void> _updateUnlockedRockets(int level) async {
    int unlockedCount = 1; // Default has first rocket

    // Updated unlock thresholds to match new difficulty levels
    if (level >= 80) unlockedCount = 2;      // Level 2
    if (level >= 200) unlockedCount = 3;     // Level 3
    if (level >= 350) unlockedCount = 4;     // Level 4
    if (level >= 600) unlockedCount = 5;     // Level 5

    final prefs = await SharedPreferences.getInstance();
    final currentUnlocked = prefs.getInt('unlockedRockets') ?? 1;

    if (unlockedCount > currentUnlocked) {
      await prefs.setInt('unlockedRockets', unlockedCount);

      // Add a flag to show "new bird unlocked" notification
      if (unlockedCount > currentUnlocked) {
        await prefs.setBool('newBirdUnlocked', true);
        await prefs.setInt('newlyUnlockedBird', unlockedCount - 1); // Store index of newly unlocked bird
      }
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