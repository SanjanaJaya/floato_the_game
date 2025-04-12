import 'dart:math';
import 'package:flame/components.dart';
import 'package:floato_the_game/coin.dart';
import 'package:floato_the_game/constants.dart';
import 'package:floato_the_game/game.dart';

class CoinManager extends Component with HasGameRef<floato> {
  final Random _random = Random();
  double _timeSinceLastSpawn = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    _timeSinceLastSpawn += dt;

    // Spawn new coins periodically
    if (_timeSinceLastSpawn > coinSpawnInterval) {
      _timeSinceLastSpawn = 0.0;
      _spawnCoin();
    }
  }

  void _spawnCoin() {
    if (gameRef.children.whereType<Coin>().length >= 5) return;

    final screenHeight = gameRef.size.y;
    final screenWidth = gameRef.size.x;

    // Spawn coin at random height in the top 2/3 of the screen
    final spawnY = _random.nextDouble() * (screenHeight * 0.66) + (screenHeight * 0.1);
    final spawnX = screenWidth + 50; // Start off screen to the right

    // Determine coin type based on probability
    final coinTypeRoll = _random.nextDouble();
    String coinType;
    if (coinTypeRoll < 0.1) { // 10% chance for gold
      coinType = 'gold';
    } else if (coinTypeRoll < 0.4) { // 30% chance for silver
      coinType = 'silver';
    } else { // 60% chance for bronze
      coinType = 'bronze';
    }

    final coinValue = coinTypes[coinType]!;

    gameRef.add(Coin(
      position: Vector2(spawnX, spawnY),
      onCollected: () {
        gameRef.incrementCoins(coinValue);
      },
      value: coinValue,
      type: coinType,
    ));
  }
}