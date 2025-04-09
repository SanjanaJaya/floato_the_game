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

    if (level >= 100) unlockedCount = 2;     // Level 2
    if (level >= 250) unlockedCount = 3;     // Level 3
    if (level >= 450) unlockedCount = 4;     // Level 4
    if (level >= 700) unlockedCount = 5;     // Level 5

    final prefs = await SharedPreferences.getInstance();
    final currentUnlocked = prefs.getInt('unlockedRockets') ?? 1;

    if (unlockedCount > currentUnlocked) {
      await prefs.setInt('unlockedRockets', unlockedCount);
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
}