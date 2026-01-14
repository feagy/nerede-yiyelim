
import 'package:floor/floor.dart';
import 'package:app/database/entity/favorite.dart';

@dao
abstract class FavoritesDao {
  @Query('SELECT * FROM favorites WHERE userId = :userId')
  Future<List<Favorite>> getAllFavorites(String userId );

  @Query('SELECT EXISTS(SELECT 1 FROM favorites WHERE placeId = :placeId AND userId = :userId)')
  Future<int?> isFavorite(String placeId, String userId);

  @Query('DELETE FROM favorites WHERE id = :favoriteId')
  Future<void> deleteFavorite(String favoriteId); 

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertFavorite(Favorite favorite); 
}