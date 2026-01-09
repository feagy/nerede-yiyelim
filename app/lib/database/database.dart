import 'package:floor/floor.dart';
import 'entity/favorite.dart';
import 'dao/favoritesdao.dart';
import 'entity/review.dart';
import 'dao/reviewsdao.dart';

// part 'database.g.dart'; // Yapılacak

@Database(version: 1, entities: [Favorite, Review])
abstract class AppDataBase extends FloorDatabase {
  FavoritesDao get favoritesDao;
  ReviewsDao get reviewsDao;
}