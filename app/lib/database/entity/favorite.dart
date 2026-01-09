
import 'package:floor/floor.dart';

@Entity(tableName: 'favorites')
class Favorite {
  @PrimaryKey()
  final String id;
  final String placeId;
  final String userId;
  final String placeName;
  final String placeAddress;
  final double? rating;
  final String? photoUrl;

  Favorite({
    required this.id,
    required this.placeId,
    required this.userId,
    required this.placeName,
    required this.placeAddress,
    this.rating,
    this.photoUrl,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] as String,
      placeId: json['placeId'] as String,
      userId: json['userId'] as String,
      placeName: json['placeName'] as String,
      placeAddress: json['placeAddress'] as String,
      rating: (json['rating'] as num?)?.toDouble(),
      photoUrl: json['photoUrl'] as String?,
    );
  }
}


