const double rocketStartX = 100;
const double rocketStartY = 100;
const double rocketWidth = 40;
const double rocketHeight = 40;
const double gravity = 800;
const double jumpStrength = -300;
const double groundHeight = 200;
const double groundScrollingSpeed = 100;
const double buildingInterval = 2;
const double buildingGap = 300;
const double minBuildingHeight = 75;
const double maxBuildingHeight = 150;
const double buildingWidth = 60;
const double enemyPlaneWidth = 110;
const double enemyPlaneHeight = 65;
const double enemyPlaneSpeed = 150;
const double enemySpawnInterval = 3;
// Add these to your constants
const List<String> enemyPlaneImages = [
  'enemy_plane1.png',
  'enemy_plane2.png',
  'enemy_plane3.png',
  'enemy_plane4.png',
];
const List<double> enemyPlaneSpeeds = [150, 170, 130, 250]; // Different speeds for each plane
// Add this to your constants.dart file
const List<String> buildingImages = [
  'building1.png',
  'building2.png',
  'building3.png',
  'building4.png',
];