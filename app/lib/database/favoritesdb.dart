import 'package:floor/floor.dart';
import 'package:app/database/entity/favorites.dart';
import 'package:app/database/dto/favoritesdao.dart';

//part 'favoritesdb.g.dart'; 

@Database(version: 1, entities: [Favorite])
abstract class FavoritesDatabase extends FloorDatabase {
  FavoritesDao get favoritesDao;
}