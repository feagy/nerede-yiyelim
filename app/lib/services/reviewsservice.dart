import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/database/entity/review.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Uygulamada Test Edilecek

class ReviewsResponse {
  final List<Review> items;
  final String? nextCursor;
  final bool hasMore;

  ReviewsResponse({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });

  factory ReviewsResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List? ?? const []);
    return ReviewsResponse(
      items: rawItems
          .whereType<Map>()
          .map((e) => Review.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      nextCursor: json['nextCursor']?.toString(),
      hasMore: json['hasMore'] == true,
    );
  }
}

class ReviewsSummary {
  final double averageRating;
  final int ratingCount;

  ReviewsSummary({
    required this.averageRating,
    required this.ratingCount,
  });

  factory ReviewsSummary.fromJson(Map<String, dynamic> json) {
    return ReviewsSummary(
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (json['ratingCount'] as int?) ?? 0,
    );
  }
}

class ReviewsService {
  ReviewsService._(this.baseUrl);

  static ReviewsService? _instance;
  final String baseUrl;

  factory ReviewsService() {
    final baseUrl = dotenv.env['REVIEWS_URL'];

    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('REVIEWS_URL not found in .env');
    }

    return _instance ??= ReviewsService._(baseUrl);
  }

  Future<void> addReview({
    required String placeId,
    required String userId,
    required int rating,
    required String comment,
    required String placeName,
    required String placeAddress,
  }) async {
    final uri = Uri.parse('$baseUrl/addReview');
    
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'placeId': placeId,
        'userId': userId,
        'rating': rating,
        'comment': comment,
        'placeName': placeName,
        'placeAddress': placeAddress,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
  
  Future<void> updateReview({
    required String placeId,
    required String userId,
    required int rating,
    required String comment,
  }) async {
    final uri = Uri.parse('$baseUrl/updateReview');
    
    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'placeId': placeId,
        'userId': userId,
        'rating': rating,
        'comment': comment,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
  
  Future<ReviewsResponse> readReviews({
    required String placeId,
    int limit = 20,
    String? cursor,
  }) async {
    final uri = Uri.parse('$baseUrl/readReviews')
        .replace(queryParameters: {
          'placeId': placeId,
          'limit': limit.toString(),
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        });
    
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    return ReviewsResponse.fromJson(decoded);
  }

  Future<ReviewsResponse> readReviewsByUser({
    required String userId,
    int limit = 20,
    String? cursor,
  }) async {
    final uri = Uri.parse('$baseUrl/readReviewsByUser')
        .replace(queryParameters: {
          'userId': userId,
          'limit': limit.toString(),
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        });
    
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    return ReviewsResponse.fromJson(decoded);
  }

  Future<void> deleteReview({
    required String reviewId,
  }) async {
    final uri = Uri.parse('$baseUrl/deleteReview/$reviewId');
    
    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  Future<ReviewsSummary> getReviewSummary({
    required String placeId,
  }) async {
    final uri = Uri.parse('$baseUrl/getReviewSummary')
        .replace(queryParameters: {
          'placeId': placeId,
        });
    
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    return ReviewsSummary.fromJson(decoded);
  }
}
