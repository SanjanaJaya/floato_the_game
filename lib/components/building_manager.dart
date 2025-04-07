import 'dart:math';
import 'package:flame/components.dart';
import 'package:floato_the_game/components/buildinng.dart';
import 'package:floato_the_game/constants.dart';
import 'package:floato_the_game/game.dart';

class BuildingManager extends Component with HasGameRef<floato>{

  double buildingSpawnTimer = 0;

  @override
  void update(double dt){

    buildingSpawnTimer += dt;


    if (buildingSpawnTimer > buildingInterval){
      buildingSpawnTimer = 0;
      spawnBuilding();
    }
  }

  void spawnBuilding(){
    final double screenHeight = gameRef.size.y;


    final double maxBuildingHeight =
        screenHeight- groundHeight - buildingGap - minBuildingHeight;

    final double bottomBuildingHeight =
        minBuildingHeight + Random().nextDouble() * (maxBuildingHeight - minBuildingHeight);

    final double topBuildingHeight =
        screenHeight - groundHeight - bottomBuildingHeight - buildingGap;


    final bottomBuilding = Building(
      Vector2(gameRef.size.x, screenHeight - groundHeight - bottomBuildingHeight),
      Vector2(buildingWidth,bottomBuildingHeight),
      isTopBuilding: false,
    );

    final topBuilding = Building(
      Vector2(gameRef.size.x,0),
      Vector2(buildingWidth,topBuildingHeight),
      isTopBuilding: true,
    );

    gameRef.add(bottomBuilding);
    gameRef.add(topBuilding);


  }

}