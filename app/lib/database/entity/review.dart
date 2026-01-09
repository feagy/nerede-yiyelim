import 'package:floor/floor.dart';

@Entity(tableName: 'reviews')
class Review {
  @PrimaryKey()
  final String id;
  final String userId;
  final String placeId;
  final String? placeName;
  final String? placeAddress;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  Review({
    required this.id,
    required this.userId,
    required this.placeId,
    required this.placeName,
    required this.placeAddress,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  static DateTime? _parseFirestoreTimestamp(dynamic v) {
    if (v == null) return null;

    if (v is String) return DateTime.tryParse(v);

    if (v is Map) {
      final seconds = v['_seconds'];
      if (seconds is int) {
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true)
            .toLocal();
      }
    }
    return null;
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      userId: json['userId'] as String,
      placeId: json['placeId'] as String,
      placeName: json['placeName'] as String?,
      placeAddress: json['placeAddress'] as String?,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: _parseFirestoreTimestamp(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseFirestoreTimestamp(json['updatedAt']) ?? DateTime.now(),
    );
  }
}