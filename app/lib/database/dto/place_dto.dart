import 'package:app/Database/place.dart';
import 'package:floor/floor.dart';

@dao
abstract class PlaceDto {
  @Query("SELECT * FROM Place")
  Future<List<Place>> findAllPlaces();

  @Query("SELECT * FROM Place WHERE placeName = :name")
  Future<Place?> findPlaceByName(String name);

  @insert
  Future<String> insertPlaceInDB(Place place);
}
