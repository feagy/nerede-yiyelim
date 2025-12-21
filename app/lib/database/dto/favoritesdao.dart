
import 'package:floor/floor.dart';
import 'package:app/database/entity/favorites.dart';

@dao
abstract class FavoritesDao {
  @Query('SELECT * FROM favorites WHERE userId = :userId')
  Future<List<Favorite>> getAllFavorites(String userId);

  @Query('SELECT EXISTS(SELECT 1 FROM favorites WHERE placeId = :placeId AND userId = :userId)')
    Future<int?> isFavorite(String placeId, String userId);

  @Query('DELETE FROM favorites WHERE placeId = :placeId AND userId = :userId')
  Future<void> deleteFavorite(String placeId, String userId); 

  @insert
  Future<void> insertFavorite(Favorite favorite); 
}