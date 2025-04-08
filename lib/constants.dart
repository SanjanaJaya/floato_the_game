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
  'Rocket',
  'Speedstar',
  'Pakaya',
  'Ponnaya',
  'Hutta',
];

const List<String> rocketLevelRequirements = [
  'Default',
  'Reach Level 2',
  'Reach Level 3',
  'Reach Level 4',
  'Reach Level 5',
];

// Ground constants
const double groundHeight = 100;
const double groundScrollingSpeed = 100;

// Building constants
const double buildingInterval = 2;
const double buildingGap = 300;
const double minBuildingHeight = 250;
const double maxBuildingHeight = 350;
const double buildingWidth = 90;
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
];
// Base speeds for different plane types
const List<double> enemyPlaneSpeeds = [150, 170, 130, 200];

// Difficulty levels
const Map<int, Map<String, dynamic>> difficultyLevels = {
  0: { // Level 1 (0-49 points)
    'buildingInterval': 3.0,
    'buildingGap': 300.0,
    'enemySpawnInterval': 3.0,
    'groundScrollingSpeed': 100.0,
    'enemySpeedMultiplier': 1.0, // Base speed
    'levelName': 'Level 1',
    'levelRange': '0-50',
  },
  50: { // Level 2 (50-149 points)
    'buildingInterval': 2.75,
    'buildingGap': 280.0,
    'enemySpawnInterval': 2.7,
    'groundScrollingSpeed': 125.0,
    'enemySpeedMultiplier': 1.2, // 20% faster
    'levelName': 'Level 2',
    'levelRange': '50-150',
  },
  150: { // Level 3 (150-249 points)
    'buildingInterval': 2.25,
    'buildingGap': 260.0,
    'enemySpawnInterval': 2.4,
    'groundScrollingSpeed': 150.0,
    'enemySpeedMultiplier': 1.4, // 40% faster
    'levelName': 'Level 3',
    'levelRange': '150-250',
  },
  250: { // Level 4 (250-349 points)
    'buildingInterval': 1.75,
    'buildingGap': 240.0,
    'enemySpawnInterval': 2.1,
    'groundScrollingSpeed': 200.0,
    'enemySpeedMultiplier': 1.6, // 60% faster
    'levelName': 'Level 4',
    'levelRange': '250-350',
  },
  350: { // Level 5 (350-500+ points)
    'buildingInterval': 1,
    'buildingGap': 220.0,
    'enemySpawnInterval': 1.8,
    'groundScrollingSpeed': 225.0,
    'enemySpeedMultiplier': 1.8, // 80% faster
    'levelName': 'Level 5',
    'levelRange': '350-500',
  },
};