import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:floato_the_game/vehicle.dart';
import 'package:floato_the_game/game.dart';
import 'package:floato_the_game/constants.dart';


class VehicleManager extends Component with HasGameRef<floato> {
  // Vehicle spawn timer
  Timer spawnTimer = Timer(0);
  final Random _random = Random();

  // Keep track of how many vehicles are on screen
  int activeVehicles = 0;
  int maxVehicles = 3; // Maximum vehicles on screen at once

  VehicleManager();

  @override
  FutureOr<void> onLoad() {
    // Initialize spawn timer with a random interval
    spawnTimer = Timer(
      _getRandomSpawnInterval(),
      onTick: _spawnVehicle,
      repeat: true,
    );
  }

  @override
  void update(double dt) {
    // Update spawn timer
    if (!gameRef.isGameOver && !gameRef.isPaused) {
      spawnTimer.update(dt);

    }
  }


  double _getRandomSpawnInterval() {
    // Base spawn interval with some randomness
    return vehicleSpawnInterval + _random.nextDouble() * 3.0;
  }

  void _spawnVehicle() {
    // Don't spawn if we've reached maximum vehicles or game is paused/over
    if (activeVehicles >= maxVehicles || gameRef.isGameOver || gameRef.isPaused) {
      return;
    }

    // Get a random vehicle type from the available vehicle types
    final vehicleType = _random.nextInt(vehicleImages.length);

    // Calculate spawn position (right edge of screen, on the ground)
    final spawnX = gameRef.size.x + 50; // Start a bit off-screen
    final spawnY = gameRef.size.y - groundHeight + 20; // Position on ground

    // Create and add the vehicle with constant speed
    final vehicle = Vehicle(
      position: Vector2(spawnX, spawnY),
      speed: vehicleSpeed,
      vehicleType: vehicleType,
    );

    gameRef.add(vehicle);
    activeVehicles++;

    // When a vehicle is removed, decrease the count
    vehicle.removed.then((_) {
      activeVehicles--;
    });

  }
}