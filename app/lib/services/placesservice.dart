import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/database/entity/place.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlacesService {
  PlacesService._(this.baseUrl);

  static PlacesService? _instance;
  final String baseUrl;

  factory PlacesService() {
    final baseUrl = dotenv.env['PLACES_URL'];

    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('PLACES_URL not found in .env');
    }

    return _instance ??= PlacesService._(baseUrl);
  }

  Future<List<Place>> fetchPlaces({
    required String textQuery,
    required double lat,
    required double lng,
    required int radius,
  }) async {
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        'textQuery': textQuery,
        'lat': lat.toString(),
        'lng': lng.toString(),
        'radius': radius.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      // Cloud Function hata mesajını da görmek için:
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final list = (decoded['places'] as List<dynamic>? ?? [])
        .map((e) => Place.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
  }
}
