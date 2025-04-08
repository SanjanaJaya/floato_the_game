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

const List<String> rocketLevelRequirements = [
  'Default',
  'Reach Level 2',
  'Reach Level 3',
  'Reach Level 4',
  'Reach Level 5',
];

// Missile constants
const List<double> missileSpeeds = [
  0,    // Rocket 1 doesn't shoot
  300,  // Rocket 2 missile speed
  350,  // Rocket 3 missile speed
  400,  // Rocket 4 missile speed
  450,  // Rocket 5 missile speed
];

const List<int> missileDamages = [
  0,  // Rocket 1 doesn't shoot
  20, // Rocket 2 missile damage
  25, // Rocket 3 missile damage
  30, // Rocket 4 missile damage
  35, // Rocket 5 missile damage
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
];
// Base speeds for different plane types
const List<double> enemyPlaneSpeeds = [150, 170, 130, 200, 100, 75, 85];

// Enemy plane health values
const List<int> enemyPlaneHealths = [30, 40, 50, 60, 70, 90, 60];

// Difficulty levels
const Map<int, Map<String, dynamic>> difficultyLevels = {
  0: { // Level 1 (0-99 points)
    'buildingInterval': 3.0,
    'buildingGap': 300.0,
    'enemySpawnInterval': 3.0,
    'groundScrollingSpeed': 100.0,
    'enemySpeedMultiplier': 1.0, // Base speed
    'levelName': 'Level 1',
    'levelRange': '0-100',
  },
  100: { // Level 2 (100-249 points)
    'buildingInterval': 2.75,
    'buildingGap': 280.0,
    'enemySpawnInterval': 2.7,
    'groundScrollingSpeed': 125.0,
    'enemySpeedMultiplier': 1.2, // 20% faster
    'levelName': 'Level 2',
    'levelRange': '100-250',
  },
  250: { // Level 3 (250-449 points)
    'buildingInterval': 2.25,
    'buildingGap': 260.0,
    'enemySpawnInterval': 2.4,
    'groundScrollingSpeed': 150.0,
    'enemySpeedMultiplier': 1.4, // 40% faster
    'levelName': 'Level 3',
    'levelRange': '250-450',
  },
  450: { // Level 4 (450-699 points)
    'buildingInterval': 1.75,
    'buildingGap': 240.0,
    'enemySpawnInterval': 1.5,
    'groundScrollingSpeed': 200.0,
    'enemySpeedMultiplier': 1.6, // 60% faster
    'levelName': 'Level 4',
    'levelRange': '450-700',
  },
  700: { // Level 5 (700-1000+ points)
    'buildingInterval': 1,
    'buildingGap': 220.0,
    'enemySpawnInterval': 1.2,
    'groundScrollingSpeed': 225.0,
    'enemySpeedMultiplier': 1.8, // 80% faster
    'levelName': 'Level 5',
    'levelRange': '700-1000',
  },
};