// Rocket constants
const double rocketStartX = 100;
const double rocketStartY = 100;
const double rocketWidth = 40;
const double rocketHeight = 40;
const double gravity = 800;
const double jumpStrength = -300;

// Rocket data
const List<String> rocketImages = [
  'rocket1.png',
  'rocket2.png',
  'rocket3.png',
  'rocket4.png',
  'rocket5.png',
];

const List<String> rocketNames = [
  'Skye',
  'Nyra',
  'Seren',
  'Elowen',
  'Zephyr',
];

// Updated requirements with more meaningful descriptions
const List<String> rocketLevelRequirements = [
  'Default',
  'Score 80+ (Level 1)',
  'Score 200+ (Level 2)',
  'Score 350+ (Level 3)',
  'Score 600+ (Level 4)',
];

// Updated missile capabilities to be more distinctive
const List<double> missileSpeeds = [
  0,    // Rocket 1 doesn't shoot
  300,  // Rocket 2 missile speed
  400,  // Rocket 3 missile speed - increased from 350
  450,  // Rocket 4 missile speed - increased from 400
  500,  // Rocket 5 missile speed - increased from 450
];

const List<int> missileDamages = [
  0,  // Rocket 1 doesn't shoot
  25, // Rocket 2 missile damage - decreased from 30
  35, // Rocket 3 missile damage - decreased from 40
  50, // Rocket 4 missile damage - unchanged
  80, // Rocket 5 missile damage - increased from 75
];

// Ground constants
const double groundHeight = 100;
const double groundScrollingSpeed = 100;

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
];

// Adjusted base speeds for different plane types to be more balanced
const List<double> enemyPlaneSpeeds = [130, 150, 120, 170, 100, 80, 90, 110];

// Adjusted health values to create better balance with new missile damages
const List<int> enemyPlaneHealths = [25, 35, 45, 55, 65, 80, 50, 40];

// Optimized difficulty levels with smoother progression and better performance scaling
const Map<int, Map<String, dynamic>> difficultyLevels = {
  0: { // Level 1 (0-79 points) - Beginner friendly
    'buildingInterval': 3.25,
    'buildingGap': 320.0,
    'enemySpawnInterval': 3.5,
    'groundScrollingSpeed': 90.0,
    'enemySpeedMultiplier': 0.9, // Slightly slower than original
    'levelName': 'Level 1',
    'levelRange': '0-80',
  },
  80: { // Level 2 (80-199 points) - Gentle introduction to challenge
    'buildingInterval': 2.75,
    'buildingGap': 300.0,
    'enemySpawnInterval': 2.8,
    'groundScrollingSpeed': 110.0,
    'enemySpeedMultiplier': 1.0, // Base speed
    'levelName': 'Level 2',
    'levelRange': '80-200',
  },
  200: { // Level 3 (200-349 points) - Moderate challenge
    'buildingInterval': 2.4,
    'buildingGap': 280.0,
    'enemySpawnInterval': 2.5,
    'groundScrollingSpeed': 130.0,
    'enemySpeedMultiplier': 1.2, // 20% faster
    'levelName': 'Level 3',
    'levelRange': '200-350',
  },
  350: { // Level 4 (350-599 points) - Advanced challenge
    'buildingInterval': 2.0,
    'buildingGap': 260.0,
    'enemySpawnInterval': 2.0,
    'groundScrollingSpeed': 160.0,
    'enemySpeedMultiplier': 1.4, // 40% faster
    'levelName': 'Level 4',
    'levelRange': '350-600',
  },
  600: { // Level 5 (600+ points) - Expert level with performance optimizations
    'buildingInterval': 1.75, // Increased from 1.5 to reduce CPU load
    'buildingGap': 240.0,
    'enemySpawnInterval': 1.8, // Increased from 1.5 to reduce enemy count
    'groundScrollingSpeed': 180.0, // Reduced to keep the game playable
    'enemySpeedMultiplier': 1.6, // Reduced from 1.7 for better playability
    'levelName': 'Level 5',
    'levelRange': '600+',
  },
};