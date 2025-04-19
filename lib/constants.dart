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
  'background_level1.jpg',
  'background_level2.jpg',
  'background_level3.jpg',
  'background_level4.jpg',
  'background_level5.jpg',
  'background_level6.jpg',
  'background_level7.jpg',
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

// Added 2 new level names
const List<String> levelNames = [
  'Anuradhapura',
  'Jaffna',
  'Galle',
  'Nuwara Eliya',
  'Sigiriya',
  'Kandy',
  'Colombo',
];

// Building constants
const double buildingInterval = 2;
const double buildingGap = 300;
const double minBuildingHeight = 250;
const double maxBuildingHeight = 350;
const double buildingWidth = 120;
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
    'enemySpawnInterval': 4.5,
    'groundScrollingSpeed': 75.0,
    'enemySpeedMultiplier': 0.7, // Much slower than original
    'levelName': 'Level 1',
    'levelRange': '0-80',
    'backgroundImage': 'background_level1.jpg',
    'groundImage': 'ground_level1.jpg',
    'environmentName': 'Anuradhapura',
  },
  80: {
    // Level 2 (80-199 points) - Easy challenge
    'buildingInterval': 3.2,
    'buildingGap': 325.0,
    'enemySpawnInterval': 4.0,
    'groundScrollingSpeed': 90.0,
    'enemySpeedMultiplier': 0.8, // Slower than original
    'levelName': 'Level 2',
    'levelRange': '80-200',
    'backgroundImage': 'background_level2.jpg',
    'groundImage': 'ground_level2.jpg',
    'environmentName': 'Jaffna',
  },
  200: {
    // Level 3 (200-349 points) - Mild challenge
    'buildingInterval': 3.0,
    'buildingGap': 300.0,
    'enemySpawnInterval': 3.75,
    'groundScrollingSpeed': 105.0,
    'enemySpeedMultiplier': 0.9, // Slightly slower
    'levelName': 'Level 3',
    'levelRange': '200-350',
    'backgroundImage': 'background_level3.jpg',
    'groundImage': 'ground_level3.jpg',
    'environmentName': 'Galle',
  },
  350: {
    // Level 4 (350-599 points) - Moderate challenge
    'buildingInterval': 2.6,
    'buildingGap': 285.0,
    'enemySpawnInterval': 3.5,
    'groundScrollingSpeed': 120.0,
    'enemySpeedMultiplier': 1.0, // Base speed
    'levelName': 'Level 4',
    'levelRange': '350-600',
    'backgroundImage': 'background_level4.jpg',
    'groundImage': 'ground_level4.jpg',
    'environmentName': 'Nuwara Eliya',
  },
  600: {
    // Level 5 (600-999 points) - Challenging but manageable
    'buildingInterval': 2.4,
    'buildingGap': 270.0,
    'enemySpawnInterval': 3.0,
    'groundScrollingSpeed': 135.0,
    'enemySpeedMultiplier': 1.1, // 10% faster than base
    'levelName': 'Level 5',
    'levelRange': '600-1000',
    'backgroundImage': 'background_level5.jpg',
    'groundImage': 'ground_level5.jpg',
    'environmentName': 'Sigiriya',
  },
  1000: {
    // Level 6 (1000-1499 points) - Hard challenge
    'buildingInterval': 2.2,
    'buildingGap': 250.0,
    'enemySpawnInterval': 2.5,
    'groundScrollingSpeed': 150.0,
    'enemySpeedMultiplier': 1.2, // 20% faster than base
    'levelName': 'Level 6',
    'levelRange': '1000-1500',
    'backgroundImage': 'background_level6.jpg',
    'groundImage': 'ground_level6.jpg',
    'environmentName': 'Kandy',
  },
  1500: {
    // Level 7 (1500-1999 points) - Expert challenge
    'buildingInterval': 2.0,
    'buildingGap': 230.0,
    'enemySpawnInterval': 2.0,
    'groundScrollingSpeed': 165.0,
    'enemySpeedMultiplier': 1.5, // 30% faster than base
    'levelName': 'Level 7',
    'levelRange': '1500-2000',
    'backgroundImage': 'background_level7.jpg',
    'groundImage': 'ground_level7.jpg',
    'environmentName': 'Colombo',
  },
  2000: {
    // Master level (2000+ points) - Extreme challenge for advanced players
    'buildingInterval': 1.8,
    'buildingGap': 220.0,
    'enemySpawnInterval': 1.8,
    'groundScrollingSpeed': 180.0,
    'enemySpeedMultiplier': 1.8, // 40% faster than base
    'levelName': 'Master Level',
    'levelRange': '2000+',
    'backgroundImage': 'background_level7.jpg', // Reuse Colombo background
    'groundImage': 'ground_level7.jpg', // Reuse Colombo ground
    'environmentName': 'Colombo Elite',
  },
};

// Coin constants
const double coinSize = 30;
const double coinSpawnInterval = 2.0; // Spawn a coin every 2 seconds on average
const Map<String, int> coinTypes = {'bronze': 2, 'silver': 4, 'gold': 6};

// Updated bird unlock costs with balanced progression
const Map<int, int> birdUnlockCosts = {
  0: 0, // First bird is free
  1: 250, // Second bird costs 250 coins
  2: 1500, // Third bird costs 1500 coins
  3: 2500, // Fourth bird costs 2500 coins
  4: 7500, // Fifth bird costs 7500 coins
  5: 10000, // Sixth bird costs 10000 coins
  6: 12500, // Seventh bird costs 12500 coins
  7: 15000, // Eighth bird costs 15000 coins
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

// Function to get difficulty settings beyond defined thresholds
// Add this function to handle scores above 2000
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

  // For scores beyond 2000, scale difficulty gradually
  if (score > 2000) {
    // Calculate scaling factor - increases as score grows, but at a diminishing rate
    double scalingFactor =
        1.0 + (score - 2000) / 4000; // Caps at 1.5x at 6000 points

    // Apply scaling to difficulty parameters (limit to reasonable values)
    settings['buildingInterval'] = max(
      1.5,
      settings['buildingInterval'] / scalingFactor,
    );
    settings['buildingGap'] = max(
      180.0,
      settings['buildingGap'] / scalingFactor,
    );
    settings['enemySpawnInterval'] = max(
      0.8,
      settings['enemySpawnInterval'] / scalingFactor,
    );
    settings['groundScrollingSpeed'] = min(
      250.0,
      settings['groundScrollingSpeed'] * scalingFactor,
    );
    settings['enemySpeedMultiplier'] = min(
      1.8,
      settings['enemySpeedMultiplier'] * sqrt(scalingFactor),
    );

    // Update level info
    settings['levelName'] = 'Master Level';
    settings['levelRange'] = '${2000}+';
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
