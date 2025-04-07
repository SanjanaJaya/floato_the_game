import 'dart:math';

import 'package:flame/components.dart';
import 'package:floato_the_game/constants.dart';
import 'package:floato_the_game/game.dart';

class BuildingManager extends Component with HasGameRef<floato>{

  double buildingSpawnTimer = 0;

  @override
  void update(double dt){

    buildingSpawnTimer += dt;
    const double buildingInterval = 50;

    if (buildingSpawnTimer > buildingInterval){
      buildingSpawnTimer = 0;
      spawnBuilding();
    }
  }

  void spawnBuilding(){
    final double screenHeight = gameRef.size.y;
    const double buildngGap = 150;
    const double minBuildingHeight = 50;
    const double buildingWidth = 60;

    final double maxBuildingHeight =
        screenHeight- groundHeight - buildngGap - minBuildingHeight;

    final double bottomBuildingHeight =
        minBuildingHeight + Random().nextDouble() * (maxBuildingHeight - minBuildingHeight);

    final double topBuildingHeight =
        screenHeight - groundHeight - bottomBuildingHeight - buildngGap;


    final bottomBuilding = Building(
      
    )


  }

}