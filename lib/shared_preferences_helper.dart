import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String highScoreKey = 'highScore';
  static const String highestLevelKey = 'highestLevel';
  static const String unlockedRocketsKey = 'unlockedRockets';
  static const String selectedRocketKey = 'selectedRocket';

  // Save high score
  static Future<void> saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHighScore = prefs.getInt(highScoreKey) ?? 0;

    if (score > currentHighScore) {
      await prefs.setInt(highScoreKey, score);
    }
  }

  // Get high score
  static Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(highScoreKey) ?? 0;
  }

  // Save highest level reached
  static Future<void> saveHighestLevel(int levelThreshold) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHighestLevel = prefs.getInt(highestLevelKey) ?? 0;

    if (levelThreshold > currentHighestLevel) {
      await prefs.setInt(highestLevelKey, levelThreshold);

      // Update unlocked rockets based on level
      await updateUnlockedRockets(levelThreshold);
    }
  }

  // Get highest level
  static Future<int> getHighestLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(highestLevelKey) ?? 0;
  }

  // Update unlocked rockets based on level
  static Future<void> updateUnlockedRockets(int levelThreshold) async {
    final prefs = await SharedPreferences.getInstance();

    // Calculate how many rockets should be unlocked
    // Level 1 (0): 1 rocket, Level 2 (50): 2 rockets, etc.
    int unlockCount = 1; // Default: 1 rocket always unlocked

    if (levelThreshold >= 350) {
      unlockCount = 5; // Level 5: All 5 rockets
    } else if (levelThreshold >= 250) {
      unlockCount = 4; // Level 4: 4 rockets
    } else if (levelThreshold >= 150) {
      unlockCount = 3; // Level 3: 3 rockets
    } else if (levelThreshold >= 50) {
      unlockCount = 2; // Level 2: 2 rockets
    }

    await prefs.setInt(unlockedRocketsKey, unlockCount);
  }

  // Get number of unlocked rockets
  static Future<int> getUnlockedRocketsCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(unlockedRocketsKey) ?? 1; // Default: 1 rocket always unlocked
  }

  // Save selected rocket
  static Future<void> saveSelectedRocket(int rocketIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(selectedRocketKey, rocketIndex);
  }

  // Get selected rocket
  static Future<int> getSelectedRocket() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(selectedRocketKey) ?? 0; // Default: first rocket
  }
}