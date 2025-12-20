import 'package:floor/floor.dart';

import 'entity/place.dart';
import 'dto/place_dto.dart';

// part 'database.g.dart'; // Yapılacak

@Database(version: 1, entities: [Place])
abstract class AppDataBase extends FloorDatabase {
  PlaceDto get placeDto;
}
