import 'package:app/database/entity/place.dart';
import 'package:app/services/placesservice.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app/pages/mapmarkers.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

//flutter run -t bin/test.dart

Future<void> main(List<String> args) async {
List<Place> mockPlaces = [
    Place(
      id: '1',
      placeName: 'Mock Place 1',
      lat: 40.7128,
      lng: -74.0060,
      distance: 500,
      phone: '123-456-7890',
      address: '123 Mock St, New York, NY',
      googleRating: 4.5,
      googleRatingCount: 150,
      type: 'restaurant',
      photoName: 'mock_photo_1.jpg',
      googleReviewsJson: '[]',
      openingHoursJson: '{}',
    ),
    Place(
      id: '2',
      placeName: 'Mock Place 2',
      lat: 40.7138,
      lng: -74.0070,
      distance: 300,
      phone: '987-654-3210',
      address: '456 Mock Ave, New York, NY',
      googleRating: 4.0,
      googleRatingCount: 200,
      type: 'cafe',
      photoName: 'mock_photo_2.jpg',
      googleReviewsJson: '[]',
      openingHoursJson: '{}',
    ),
  ];

  List<Marker> markers = MapMarkers.getPlaceMarkers<Place>(
    mockPlaces,
    (place) => LatLng(place.lat, place.lng),
    (place) {
      print('Marker tapped: ${place.placeName}, ID: ${place.id}');
    },
  );

  for (var marker in markers) {
    print('Marker at position: (${marker.point.latitude}, ${marker.point.longitude})');




}
}