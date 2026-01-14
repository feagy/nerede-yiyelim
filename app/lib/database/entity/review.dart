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
  // DateTime desteklenmiyor sadece double, int, string, bool desteknliyor.
  final int createdAt; // millisecondsSinceEpoch 
  final int updatedAt;

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
      // Bunun dönüşüm böyle oluyor. Eğer değiştriecekeniz değiştirin daha iyisi varsa.
      createdAt: _parseFirestoreTimestamp(json['createdAt'])?.millisecondsSinceEpoch 
           ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt: _parseFirestoreTimestamp(json['updatedAt'])?.millisecondsSinceEpoch 
           ?? DateTime.now().millisecondsSinceEpoch,

    );
  }

    Review copyWith({
      String? id,
      String? userId,
      String? placeId,
      String? placeName,
      String? placeAddress,
      int? rating,
      String? comment,
      int? createdAt,
      int? updatedAt,
    }) {
      return Review(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        placeId: placeId ?? this.placeId,
        placeName: placeName ?? this.placeName,
        placeAddress: placeAddress ?? this.placeAddress,
        rating: rating ?? this.rating,
        comment: comment ?? this.comment,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
    }
}
