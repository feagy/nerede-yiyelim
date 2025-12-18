import 'package:floor/floor.dart';

@entity
class Place {
  @primaryKey
  final String id;

  final String placeName;

  final String placeLocation;

  Place(this.id, this.placeName, this.placeLocation);
}
