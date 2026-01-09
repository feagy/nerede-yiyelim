import 'package:floor/floor.dart';
import 'dart:convert';

@entity
class Place {
  @primaryKey
  final String id;

  final double distance;
  final String placeName;
  final String? phone;
  final String? address;

  final double lat;
  final double lng;

  final double? googleRating;
  final int? googleRatingCount;

  final String? type;

  final String? photoName;
  final String? googleReviewsJson;
  final String? openingHoursJson;


  Place({
    required this.id,
    required this.distance,
    required this.placeName,
    this.phone,
    this.address,
    required this.lat,
    required this.lng,
    this.googleRating,
    this.googleRatingCount,
    this.type,
    this.photoName,
    this.googleReviewsJson,
    this.openingHoursJson,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      placeName: json['name'] as String? ?? 'Ad yok',
      phone: json['phone'] as String?,
      address: (json['address'] as String?) ?? 'Adress yok',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      googleRating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      googleRatingCount: json['userRatingCount'] as int?,
      type: json['type'] as String?,
      photoName: json['photoName'] as String?,
      openingHoursJson: jsonEncode(json['openingHours']),
    );
  }
}
