import 'package:app/services/placesservice.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

//flutter run -t bin/test.dart

Future<void> main(List<String> args) async {
  print("Starting PlacesService test...");
  
  await dotenv.load(fileName: ".env");

  final String placesUrl = dotenv.env['PLACES_URL'] ?? '';
  if (placesUrl.isEmpty) {
    throw Exception('PLACES_URL bulunamadı (.env)');
  }

  final placesService = PlacesService(placesUrl);

  try {
    final places = await placesService.fetchPlaces(
      textQuery: 'restaurant',
      lat: 40.7128,
      lng: -74.0060,
      radius: 1000,
    );

    for (var place in places) {
      print('  Place: ${place.placeName}, Location: (${place.lat}, ${place.lng})');
      print('  ID: ${place.id}');
      print('  Distance: ${place.distance}');
      print('  Phone: ${place.phone}');
      print('  Address: ${place.address}');
      print('  Google Rating: ${place.googleRating}');
      print('  Google Rating Count: ${place.googleRatingCount}');
      print('  Type: ${place.type}');
      print('  Photo Name: ${place.photoName}');
      print('  Google Reviews JSON: ${place.googleReviewsJson}');
      print('  Opening Hours JSON: ${place.openingHoursJson}');
      print('-----------------------------');
    }

    if (places.isEmpty) {
      print('No places found for the given query.');
    } else {
      print('Total places found: ${places.length}');
    }
    
  } catch (e) {
    print('Error fetching places: $e');
  }
  
}
