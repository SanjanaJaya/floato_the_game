import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  // High score methods
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

  // Level progress methods
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

  // Bird unlock methods - now tracking individual birds
  static Future<List<bool>> getUnlockedBirds() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to first bird unlocked, others locked
    return List.generate(8, (index) => index == 0 ? true : prefs.getBool('bird_$index') ?? false);
  }

  static Future<void> unlockBird(int birdIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bird_$birdIndex', true);
  }

  static Future<int> getUnlockedRocketsCount() async {
    final unlocked = await getUnlockedBirds();
    return unlocked.where((isUnlocked) => isUnlocked).length;
  }

  static Future<int> getSelectedRocket() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('selectedRocket') ?? 0;
  }

  static Future<void> saveSelectedRocket(int rocketIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedRocket', rocketIndex);
  }

  // Coin methods
  static Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('coins') ?? 0;
  }

  static Future<void> saveCoins(int coins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', coins);
  }

  // Tutorial methods
  static Future<bool> hasTutorialBeenSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tutorialSeen') ?? false;
  }

  static Future<void> saveTutorialSeen(bool seen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorialSeen', seen);
  }
}