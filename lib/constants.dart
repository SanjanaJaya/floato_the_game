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
const double minBuildingHeight = 125;  // Changed from 50 to 25
const double maxBuildingHeight = 250;  // New constant added
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