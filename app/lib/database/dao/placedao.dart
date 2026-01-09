import 'package:app/database/entity/place.dart';
import 'package:floor/floor.dart';

@dao
abstract class PlaceDao {
  // We can use it as a stream for huge favorite lists
  @Query("SELECT * FROM Place")
  Future<List<Place>> findAllPlaces();

  @Query("SELECT * FROM Place WHERE placeName = :name")
  Future<Place?> findPlaceByName(String name);

  @Query("SELECT COUNT(*) FROM Place")
  Future<int?> countFavorites();

  @delete
  Future<int> removePlace(Place place);

  @Query("DELETE FROM Place")
  Future<void> removeAllPlace();

  @Insert(onConflict: OnConflictStrategy.rollback)
  Future<int> insertPlaceInDB(Place place);
}
