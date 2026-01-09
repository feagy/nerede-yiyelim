
import 'package:floor/floor.dart';
import 'package:app/database/entity/favorite.dart';

@dao
abstract class FavoritesDao {
  @Query('SELECT * FROM favorites WHERE userId = :userId LIMIT :limit OFFSET :offset')
  Future<List<Favorite>> getAllFavorites(String userId, int limit, int offset);

  @Query('SELECT EXISTS(SELECT 1 FROM favorites WHERE placeId = :placeId AND userId = :userId)')
  Future<int?> isFavorite(String placeId, String userId);

  @Query('DELETE FROM favorites WHERE id = :favoriteId')
  Future<void> deleteFavorite(String favoriteId); 

  @insert
  Future<void> insertFavorite(Favorite favorite); 
}