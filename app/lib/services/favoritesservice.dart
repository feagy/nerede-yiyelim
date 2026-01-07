import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/database/entity/favorites.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Uygulamada Test Edilecek

class FavoritesService {
  FavoritesService._(this.baseUrl);

  static FavoritesService? _instance;
  final String baseUrl;

  factory FavoritesService() {
    final baseUrl = dotenv.env['FAVORITES_URL'];

    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('FAVORITES_URL not found in .env');
    }

    return _instance ??= FavoritesService._(baseUrl);
  }

  Future<void> addFavorite({
    required String placeId,
    required String userId,
    required String placeName,
    required String placeAddress,
    required int rating,
    required String photoUrl,
  }) async {
    final uri = Uri.parse('$baseUrl/addFavorite');
    
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'placeId': placeId,
        'userId': userId,
        'placeName': placeName,
        'placeAddress': placeAddress,
        'rating': rating,
        'photoUrl': photoUrl,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  Future<void> deleteFavorite(String favoriteId) async {
    final uri = Uri.parse('$baseUrl/deleteFavorite/$favoriteId');
    
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

  //read favorites for a user
  Future<List<Favorite>> readFavorites(String userId) async {
    final uri = Uri.parse('$baseUrl/readFavorites')
        .replace(queryParameters: {
          'userId': userId,
        });
    
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final list = (decoded['favorites'] as List<dynamic>? ?? [])
        .map((e) => Favorite.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
  }
}