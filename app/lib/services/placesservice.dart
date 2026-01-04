import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:app/database/entity/place.dart';

// Test Edilecek

class PlacesService {
  final String baseUrl;  
  PlacesService(this.baseUrl);

  Future<List<Place>> fetchPlaces({
    required String textQuery,
    required double lat,
    required double lng,
    required int radius,
    }) async {
      final uri = Uri.parse(baseUrl)
          .replace(queryParameters: {
            'textQuery': textQuery,
            'lat': lat.toString(),
            'lng': lng.toString(),
            'radius': radius.toString(),
          });
      
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
      });

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