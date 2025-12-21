
import 'package:floor/floor.dart';

@Entity(tableName: 'favorites')
class Favorite {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String placeId;
  final String userId;
  final String placeName;
  final String placeAddress;
  final double? rating;
  final String? photoUrl;

  Favorite({
    this.id,
    required this.placeId,
    required this.userId,
    required this.placeName,
    required this.placeAddress,
    this.rating,
    this.photoUrl,
  });

}


