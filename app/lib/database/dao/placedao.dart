import 'package:app/database/entity/place.dart';
import 'package:floor/floor.dart';

@dao
abstract class PlaceDao {
  @Query('SELECT * FROM places WHERE id = :placeId')
  Future<Place?> getPlaceById(String placeId);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> upsertPlace(Place place);

  @Query('DELETE FROM places WHERE id = :placeId')
  Future<void> deletePlaceById(String placeId);
}
