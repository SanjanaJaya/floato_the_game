// Add this at the top of constants.dart
import 'package:flame/flame.dart';
import 'package:floato_the_game/audio_manager.dart';

final List<String> allAssetPaths = [
  // Rocket images
  ...rocketImages.map((img) => 'assets/images/bird/$img'),
  // Background images
  ...backgroundImages.map((img) => 'assets/images/$img'),
  // Ground images
  ...groundImages.map((img) => 'assets/images/$img'),
  // Building images
  ...buildingImages.map((img) => 'assets/images/$img'),
  // Enemy plane images
  ...enemyPlaneImages.map((img) => 'assets/images/$img'),
  // Vehicle images
  ...vehicleImages.map((img) => 'assets/images/$img'),
  // Ability images
  'assets/images/abilities/double_score.png',
  'assets/images/abilities/invincibility.png',
  'assets/images/abilities/slow_motion.png',
  'assets/images/abilities/rapid_fire.png',
  // Coin images
  'assets/images/coins/bronze.png',
  'assets/images/coins/silver.png',
  'assets/images/coins/gold.png',
  // Explosion images
  'assets/images/explosion/explosion1.png',
  'assets/images/explosion/explosion2.png',
  'assets/images/explosion/explosion3.png',
  // Missile images
  'assets/images/bird/missile1.png',
  'assets/images/bird/missile2.png',
  'assets/images/bird/missile3.png',
  'assets/images/bird/missile4.png',
  'assets/images/bird/missile5.png',
  'assets/images/bird/missile6.png',
  'assets/images/bird/missile7.png',
  'assets/images/bird/missile8.png',
];

// Add this function to check if all assets are loaded
Future<void> preloadAllAssets() async {
  final images = await Flame.images.loadAll(allAssetPaths);
  final audio = AudioManager();
  await audio.init(); // Preload audio files
}
// Rocket constants
const double rocketStartX = 100;
const double rocketStartY = 100;
const double rocketWidth = 55;
const double rocketHeight = 55;
const double gravity = 400;
const double jumpStrength = -300;

// Rocket data
const List<String> rocketImages = [
  'rocket1.png',
  'rocket2.png',
  'rocket3.png',
  'rocket4.png',
  'rocket5.png',
  'rocket6.png',
  'rocket7.png',
  'rocket8.png',
];

const List<String> rocketNames = ['Skye', 'Nyra', 'Seren', 'Elowen', 'Zephyr', 'Maelis ', 'Alarien', 'Virel'];


// Updated missile capabilities to be more distinctive
const List<double> missileSpeeds = [
  0,
  300,
  400,
  450,
  500,
  600,
  700,
  800,
];

const List<int> missileDamages = [
  0, // Rocket 1 doesn't shoot
  25, // Rocket 2 missile damage - decreased from 30
  35, // Rocket 3 missile damage - decreased from 40
  50, // Rocket 4 missile damage - unchanged
  80, // Rocket 5 missile damage - increased from 75
  95,
  105,
  120,
];

// Ground constants
const double groundHeight = 100;
const double groundScrollingSpeed = 100;

// Background and ground images for each level - added 2 new levels
const List<String> backgroundImages = [
  'background_level1.png',
  'background_level2.png',
  'background_level3.png',
  'background_level4.png',
  'background_level5.png',
  'background_level6.png',
  'background_level7.png',
  'background_level8.png',
  'background_level9.png',
  'background_level10.png',
  'background_level11.png',
  'background_level12.png',
  'background_level13.png',
  'background_level14.png',
  'background_level15.png',
  'background_level16.png',
  'background_level17.png',
  'background_level18.png',
  'background_level19.png',
  'background_level20.png',
  'background_level21.png',
  'background_level22.png',
  'background_level23.png',
  'background_level24.png',
];

const List<String> groundImages = [
  'ground_level1.jpg',
  'ground_level2.jpg',
  'ground_level3.jpg',
  'ground_level4.jpg',
  'ground_level5.jpg',
  'ground_level6.jpg',
  'ground_level7.jpg',
];

const List<String> levelNames = [
  'Anuradhapura',
  'Galle',
  'Nuwara Eliya',
  'Matale',
  'Kandy',
  'Trincomalee',
  'Jaffna',
  'Gampaha',
  'Batticaloa',
  'Matara',
  'Ratnapura',
  'Kalutara',
  'Badulla',
  'Kurunegala',
  'Polonnaruwa',
  'Hambantota',
  'Ampara',
  'Mannar',
  'Vavuniya',
  'Puttalam',
  'Monaragala',
  'Kilinochchi'
  'Kegalle',
  'Mullaitivu',
  'Colombo',
];

// Building constants
const double buildingInterval = 3;
const double buildingGap = 350;
const double minBuildingHeight = 200;
const double maxBuildingHeight = 300;
const double buildingWidth = 160;
const List<String> buildingImages = [
  'building1.png',
  'building2.png',
  'building3.png',
  'building4.png',
  'building5.png',
  'building6.png',
  'building7.png',
  'building8.png',
  'building9.png',
  'building10.png',
  'building11.png',
  'building12.png',
  'building13.png',
  'building14.png',
  'building15.png',
  'building16.png',
  'building17.png',
  'building18.png',
  'building19.png',
  'building20.png',
  'building21.png',
  'building22.png',
  'building23.png',
  'building24.png',
  'building25.png',
  'building26.png',
  'building27.png',
  'building28.png',
  'building29.png',
  'building30.png',
  'building31.png',
  'building32.png',
  'building33.png',
  'building34.png',
  'building35.png',
  'building36.png',
  'building37.png',
  'building38.png',
  'building39.png',
  'building40.png',
  'building41.png',
  'building42.png',
];

// Enemy plane constants
const double enemyPlaneWidth = 90;
const double enemyPlaneHeight = 45;
const double enemyPlaneSpeed = 150; // Base speed, will be modified by level
const double enemySpawnInterval = 3;
const List<String> enemyPlaneImages = [
  'enemy_plane1.png',
  'enemy_plane2.png',
  'enemy_plane3.png',
  'enemy_plane4.png',
  'enemy_plane5.png',
  'enemy_plane6.png',
  'enemy_plane7.png',
  'enemy_plane8.png',
  'enemy_plane9.png',
  'enemy_plane10.png',
  'enemy_plane11.png',
  'enemy_plane12.png',
];

// Adjusted base speeds for different plane types to be more balanced
const List<double> enemyPlaneSpeeds = [
  130,
  150,
  120,
  170,
  100,
  80,
  90,
  110,
  100,
  140,
  200,
  160,
];

// Adjusted health values to create better balance with new missile damages
const List<int> enemyPlaneHealths = [
  175,
  185,
  195,
  200,
  245,
  260,
  300,
  320,
  250,
  320,
  350,
  325
];

// Optimized difficulty levels with smoother progression and two new levels
// Plus a mechanism for handling scores beyond 2000
const Map<int, Map<String, dynamic>> difficultyLevels = {
  0: {
    // Level 1 (0-79 points) - Very beginner friendly
    'buildingInterval': 4.0,
    'buildingGap': 350.0,
    'enemySpawnInterval': 4.0,
    'groundScrollingSpeed': 75.0,
    'enemySpeedMultiplier': 0.7,
    'levelName': 'Level 1',
    'levelRange': '0-80',
    'backgroundImage': 'background_level1.png',
    'groundImage': 'ground_level1.jpg',
    'environmentName': 'Anuradhapura',
  },
  80: {
    // Level 2 (80-199 points) - Easy challenge
    'buildingInterval': 3.5,
    'buildingGap': 340.0,
    'enemySpawnInterval': 3.5,
    'groundScrollingSpeed': 85.0,
    'enemySpeedMultiplier': 0.4,
    'levelName': 'Level 2',
    'levelRange': '80-200',
    'backgroundImage': 'background_level2.png',
    'groundImage': 'ground_level2.jpg',
    'environmentName': 'Galle',
  },
  200: {
    // Level 3 (200-349 points) - Mild challenge
    'buildingInterval': 3.2,
    'buildingGap': 330.0,
    'enemySpawnInterval': 3.2,
    'groundScrollingSpeed': 95.0,
    'enemySpeedMultiplier': 0.5,
    'levelName': 'Level 3',
    'levelRange': '200-350',
    'backgroundImage': 'background_level3.png',
    'groundImage': 'ground_level3.jpg',
    'environmentName': 'Nuwara Eliya',
  },
  350: {
    // Level 4 (350-599 points) - Moderate challenge
    'buildingInterval': 3.0,
    'buildingGap': 320.0,
    'enemySpawnInterval': 3.0,
    'groundScrollingSpeed': 105.0,
    'enemySpeedMultiplier': 0.6,
    'levelName': 'Level 4',
    'levelRange': '350-600',
    'backgroundImage': 'background_level4.png',
    'groundImage': 'ground_level4.jpg',
    'environmentName': 'Matale',
  },
  600: {
    // Level 5 (600-999 points) - Challenging but manageable
    'buildingInterval': 2.8,
    'buildingGap': 310.0,
    'enemySpawnInterval': 2.8,
    'groundScrollingSpeed': 115.0,
    'enemySpeedMultiplier': 0.7,
    'levelName': 'Level 5',
    'levelRange': '600-1000',
    'backgroundImage': 'background_level5.png',
    'groundImage': 'ground_level5.jpg',
    'environmentName': 'Kandy',
  },
  1000: {
    // Level 6 (1000-1499 points) - Hard challenge
    'buildingInterval': 2.6,
    'buildingGap': 300.0,
    'enemySpawnInterval': 2.6,
    'groundScrollingSpeed': 125.0,
    'enemySpeedMultiplier': 0.8,
    'levelName': 'Level 6',
    'levelRange': '1000-1500',
    'backgroundImage': 'background_level6.png',
    'groundImage': 'ground_level6.jpg',
    'environmentName': 'Trincomalee',
  },
  1500: {
    // Level 7 (1500-1999 points) - Expert challenge
    'buildingInterval': 2.4,
    'buildingGap': 290.0,
    'enemySpawnInterval': 2.4,
    'groundScrollingSpeed': 135.0,
    'enemySpeedMultiplier': 0.9,
    'levelName': 'Level 7',
    'levelRange': '1500-2000',
    'backgroundImage': 'background_level7.png',
    'groundImage': 'ground_level7.jpg',
    'environmentName': 'Jaffna',
  },
  2000: {
    // Level 8 (2000-2499 points)
    'buildingInterval': 2.2,
    'buildingGap': 280.0,
    'enemySpawnInterval': 2.2,
    'groundScrollingSpeed': 145.0,
    'enemySpeedMultiplier': 1.0,
    'levelName': 'Level 8',
    'levelRange': '2000-2500',
    'backgroundImage': 'background_level8.png',
    'groundImage': 'ground_level5.jpg',
    'environmentName': 'Gampaha',
  },
  2500: {
    // Level 9 (2500-2999 points)
    'buildingInterval': 2.0,
    'buildingGap': 270.0,
    'enemySpawnInterval': 2.0,
    'groundScrollingSpeed': 155.0,
    'enemySpeedMultiplier': 1.1,
    'levelName': 'Level 9',
    'levelRange': '2500-3000',
    'backgroundImage': 'background_level9.png',
    'groundImage': 'ground_level3.jpg',
    'environmentName': 'Batticaloa',
  },
  3000: {
    // Level 10 (3000-3499 points)
    'buildingInterval': 1.9,
    'buildingGap': 260.0,
    'enemySpawnInterval': 1.9,
    'groundScrollingSpeed': 165.0,
    'enemySpeedMultiplier': 1.2,
    'levelName': 'Level 10',
    'levelRange': '3000-3500',
    'backgroundImage': 'background_level10.png',
    'groundImage': 'ground_level2.jpg',
    'environmentName': 'Matara',
  },
  3500: {
    // Level 11 (3500-3999 points)
    'buildingInterval': 1.8,
    'buildingGap': 250.0,
    'enemySpawnInterval': 1.8,
    'groundScrollingSpeed': 175.0,
    'enemySpeedMultiplier': 1.3,
    'levelName': 'Level 11',
    'levelRange': '3500-4000',
    'backgroundImage': 'background_level11.png',
    'groundImage': 'ground_level1.jpg',
    'environmentName': 'Ratnapura',
  },
  4000: {
    // Level 12 (4000-4499 points)
    'buildingInterval': 1.7,
    'buildingGap': 240.0,
    'enemySpawnInterval': 1.7,
    'groundScrollingSpeed': 185.0,
    'enemySpeedMultiplier': 1.4,
    'levelName': 'Level 12',
    'levelRange': '4000-4500',
    'backgroundImage': 'background_level12.png',
    'groundImage': 'ground_level16.jpg',
    'environmentName': 'Kalutara',
  },
  4500: {
    // Level 13 (4500-4999 points)
    'buildingInterval': 1.6,
    'buildingGap': 230.0,
    'enemySpawnInterval': 1.6,
    'groundScrollingSpeed': 195.0,
    'enemySpeedMultiplier': 1.5,
    'levelName': 'Level 13',
    'levelRange': '4500-5000',
    'backgroundImage': 'background_level13.png',
    'groundImage': 'ground_level7.jpg',
    'environmentName': 'Badulla',
  },
  5000: {
    // Level 14 (5000-5499 points)
    'buildingInterval': 1.5,
    'buildingGap': 220.0,
    'enemySpawnInterval': 1.5,
    'groundScrollingSpeed': 205.0,
    'enemySpeedMultiplier': 1.6,
    'levelName': 'Level 14',
    'levelRange': '5000-5500',
    'backgroundImage': 'background_level14.png',
    'groundImage': 'ground_level3.jpg',
    'environmentName': 'Kurunegala',
  },
  5500: {
    // Level 15 (5500-5999 points)
    'buildingInterval': 1.4,
    'buildingGap': 210.0,
    'enemySpawnInterval': 1.4,
    'groundScrollingSpeed': 215.0,
    'enemySpeedMultiplier': 1.7,
    'levelName': 'Level 15',
    'levelRange': '5500-6000',
    'backgroundImage': 'background_level15.png',
    'groundImage': 'ground_level5.jpg',
    'environmentName': 'Polonnaruwa',
  },
  6000: {
    // Level 16 (6000-6499 points)
    'buildingInterval': 1.3,
    'buildingGap': 200.0,
    'enemySpawnInterval': 1.3,
    'groundScrollingSpeed': 225.0,
    'enemySpeedMultiplier': 1.8,
    'levelName': 'Level 16',
    'levelRange': '6000-6500',
    'backgroundImage': 'background_level16.png',
    'groundImage': 'ground_level6.jpg',
    'environmentName': 'Hambantota',
  },
  6500: {
    // Level 17 (6500-6999 points)
    'buildingInterval': 1.2,
    'buildingGap': 190.0,
    'enemySpawnInterval': 1.2,
    'groundScrollingSpeed': 235.0,
    'enemySpeedMultiplier': 1.9,
    'levelName': 'Level 17',
    'levelRange': '6500-7000',
    'backgroundImage': 'background_level17.png',
    'groundImage': 'ground_level2.jpg',
    'environmentName': 'Ampara',
  },
  7000: {
    // Level 18 (7000-7499 points)
    'buildingInterval': 1.1,
    'buildingGap': 180.0,
    'enemySpawnInterval': 1.1,
    'groundScrollingSpeed': 245.0,
    'enemySpeedMultiplier': 2.0,
    'levelName': 'Level 18',
    'levelRange': '7000-7500',
    'backgroundImage': 'background_level18.png',
    'groundImage': 'ground_level1.jpg',
    'environmentName': 'Mannar',
  },
  7500: {
    // Level 19 (7500-7999 points)
    'buildingInterval': 1.0,
    'buildingGap': 170.0,
    'enemySpawnInterval': 1.0,
    'groundScrollingSpeed': 255.0,
    'enemySpeedMultiplier': 2.1,
    'levelName': 'Level 19',
    'levelRange': '7500-8000',
    'backgroundImage': 'background_level19.png',
    'groundImage': 'ground_level6.jpg',
    'environmentName': 'Vavuniya',
  },
  8000: {
    // Level 20 (8000-8499 points)
    'buildingInterval': 0.9,
    'buildingGap': 160.0,
    'enemySpawnInterval': 0.9,
    'groundScrollingSpeed': 265.0,
    'enemySpeedMultiplier': 2.2,
    'levelName': 'Level 20',
    'levelRange': '8000-8500',
    'backgroundImage': 'background_level20.png',
    'groundImage': 'ground_level7.jpg',
    'environmentName': 'Puttalam',
  },
  8500: {
    // Level 21 (8500-8999 points)
    'buildingInterval': 0.8,
    'buildingGap': 150.0,
    'enemySpawnInterval': 0.8,
    'groundScrollingSpeed': 275.0,
    'enemySpeedMultiplier': 2.3,
    'levelName': 'Level 21',
    'levelRange': '8500-9000',
    'backgroundImage': 'background_level21.png',
    'groundImage': 'ground_level3.jpg',
    'environmentName': 'Monaragala',
  },
  9000: {
    // Level 22 (9000-9499 points)
    'buildingInterval': 0.7,
    'buildingGap': 140.0,
    'enemySpawnInterval': 0.7,
    'groundScrollingSpeed': 285.0,
    'enemySpeedMultiplier': 2.4,
    'levelName': 'Level 22',
    'levelRange': '9000-9500',
    'backgroundImage': 'background_level22.png',
    'groundImage': 'ground_level4.jpg',
    'environmentName': 'Kilinochchi',
  },
  9500: {
    // Level 23 (9500-9999 points)
    'buildingInterval': 0.6,
    'buildingGap': 130.0,
    'enemySpawnInterval': 0.6,
    'groundScrollingSpeed': 295.0,
    'enemySpeedMultiplier': 2.5,
    'levelName': 'Level 23',
    'levelRange': '9500-10000',
    'backgroundImage': 'background_level23.png',
    'groundImage': 'ground_level1.jpg',
    'environmentName': 'Kegalle',
  },
  10000: {
    // Level 24 (10000+ points) - Ultimate challenge
    'buildingInterval': 0.5,
    'buildingGap': 120.0,
    'enemySpawnInterval': 0.5,
    'groundScrollingSpeed': 300.0,
    'enemySpeedMultiplier': 2.6,
    'levelName': 'Master Level',
    'levelRange': '10000+',
    'backgroundImage': 'background_level24.png',
    'groundImage': 'ground_level6.jpg',
    'environmentName': 'Colombo',
  },
};

// Function to get difficulty settings beyond defined thresholds
Map<String, dynamic> getDifficultyForScore(int score) {
  // Find the appropriate difficulty level based on score
  int thresholdKey = 0;

  for (int threshold in difficultyLevels.keys) {
    if (score >= threshold) {
      thresholdKey = threshold;
    } else {
      break;
    }
  }

  // Get the base difficulty settings
  Map<String, dynamic> settings = Map.from(difficultyLevels[thresholdKey]!);

  // For scores beyond 10000, scale difficulty gradually
  if (score > 10000) {
    // Calculate scaling factor - increases as score grows, but at a diminishing rate
    double scalingFactor = 1.0 + (score - 10000) / 5000; // Caps at 3x at 20000 points

    // Apply scaling to difficulty parameters (limit to reasonable values)
    settings['buildingInterval'] = max(
      0.3,
      settings['buildingInterval'] / scalingFactor,
    );
    settings['buildingGap'] = max(
      100.0,
      settings['buildingGap'] / scalingFactor,
    );
    settings['enemySpawnInterval'] = max(
      0.3,
      settings['enemySpawnInterval'] / scalingFactor,
    );
    settings['groundScrollingSpeed'] = min(
      350.0,
      settings['groundScrollingSpeed'] * scalingFactor,
    );
    settings['enemySpeedMultiplier'] = min(
      4.0,
      settings['enemySpeedMultiplier'] * sqrt(scalingFactor),
    );

    // Update level info
    settings['levelName'] = 'Master Level';
    settings['levelRange'] = '${10000}+';
    settings['environmentName'] = 'Colombo Elite';
  }

  return settings;
}

// Helper function for getDifficultyForScore
double max(double a, double b) {
  return a > b ? a : b;
}

// Helper function for getDifficultyForScore
double min(double a, double b) {
  return a < b ? a : b;
}

// Helper function for getDifficultyForScore
double sqrt(double x) {
  return x * 0.5 + 0.5; // Simple approximation of square root curve
}

// Coin constants
const double coinSize = 30;
const double coinSpawnInterval = 2.0; // Spawn a coin every 2 seconds on average
const Map<String, int> coinTypes = {'bronze': 2, 'silver': 4, 'gold': 6};

// Updated bird unlock costs with balanced progression
const Map<int, int> birdUnlockCosts = {
  0: 0, // First bird is free
  1: 250, // Second bird costs 250 coins
  2: 2500, // Third bird costs 1500 coins
  3: 7500, // Fourth bird costs 2500 coins
  4: 15000, // Fifth bird costs 7500 coins
  5: 35000, // Sixth bird costs 10000 coins
  6: 50000, // Seventh bird costs 12500 coins
  7: 75000, // Eighth bird costs 15000 coins
};

// Vehicle constants
const double vehicleWidth = 250;
const double vehicleHeight = 100;
const double vehicleSpeed = 150; // Constant speed for all vehicles
const double vehicleSpawnInterval = 6.0; // Base spawn interval in seconds

// Add this to your constants for vehicle images
// You can expand this list in the future without changing the code
const List<String> vehicleImages = [
  'vehicle1.png',
  'vehicle2.png',
  'vehicle3.png',
  'vehicle4.png',
  'vehicle5.png',
  'vehicle6.png',
  'vehicle7.png',
  'vehicle8.png',
  'vehicle9.png',
];
