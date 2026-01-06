import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:app/functions/locationfunc.dart';
import 'package:app/database/entity/place.dart';
import 'package:app/pages/mapmarkers.dart';

class MapPage extends StatefulWidget {
  final String keyAPI;
  const MapPage({super.key, required this.keyAPI});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final MapController _mapController;
  final List<Marker> _userMarkers = [];

  final LocationService _locationService = LocationService();
  StreamSubscription? _locationStream;
  LatLng? _currentUserLatLng;
 
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
  
  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    _initUserLocation();
  }
  
  void _openPlaceSheet(Place p) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: false,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(blurRadius: 20, spreadRadius: 2, offset: Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      p.placeName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Icon(Icons.restaurant),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.star, size: 18, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text("${p.googleRating}"),
                  const SizedBox(width: 6),
                  Text("(${p.googleRatingCount})", style: const TextStyle(color: Colors.black54)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {/* yol tarifi */},
                      icon: const Icon(Icons.directions),
                      label: const Text("Yol Tarifi Al"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () {/* detay */},
                    child: const Text("Detayları Gör"),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Future<void> _initUserLocation() async {
    final pos = await _locationService.getUserCurrentLocation();
    if (pos != null && mounted) {
      setState(() {
        _currentUserLatLng = LatLng(pos.latitude, pos.longitude);
      });
      _mapController.move(_currentUserLatLng!, 15.0);
    }
  }

  Future<void> _startTrackingUser() async {
    _locationStream = await _locationService.startUpdateUserCurrentLocation(
      onLocationChanged: (pos) {
        final newLatLng = LatLng(pos.latitude, pos.longitude);
        setState(() {
          _currentUserLatLng = newLatLng;
        });
        _mapController.move(newLatLng, _mapController.camera.zoom);
      },
    );
  }

  @override
  void dispose() {
    _locationStream?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(41.0082, 28.9784),
                    initialZoom: 11.0,
                    minZoom: 3.0,
                    maxZoom: 18.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    onTap: (tapPosition, point) {
                      setState(() {
                        _userMarkers.add(
                          Marker(
                            point: point,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: Color.fromARGB(255, 255, 115, 0),
                              size: 40,
                            ),
                          ),
                        );
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://api.maptiler.com/maps/hybrid/256/{z}/{x}/{y}.jpg?key=${widget.keyAPI}",
                      userAgentPackageName: "com.example.app",
                      tileProvider: NetworkTileProvider(),
                      maxNativeZoom: 19,
                    ),
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point:
                              _currentUserLatLng ??
                              const LatLng(41.0082, 28.9784),
                          color: Colors.amber.withOpacity(0.1),
                          borderStrokeWidth: 2,
                          borderColor: Colors.amberAccent,
                          useRadiusInMeter: true,
                          radius: 500,
                        ),
                      ],
                    ),
                    if (_currentUserLatLng != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentUserLatLng!,
                            width: 50,
                            height: 50,
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.blueAccent,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    if (_userMarkers.isNotEmpty)
                      MarkerLayer(markers: _userMarkers),
                    MarkerLayer(markers: MapMarkers.getPlaceMarkers<Place>(
                      mockPlaces,
                      (place) => LatLng(place.lat, place.lng),
                      (place) {
                    _openPlaceSheet(place);
                     },
                    )
                  )
                  ],
                ),

                Positioned(
                  top: MediaQuery.of(context).size.height * 0.04,
                  left: MediaQuery.of(context).size.height * 0.01,
                  right: MediaQuery.of(context).size.height * 0.01,
                  child: Center(
                    child: Text(
                      "Nerede Yiyelim?",
                      style: GoogleFonts.lato(
                        color: const Color.fromARGB(255, 255, 115, 0),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: const Color.fromARGB(223, 77, 42, 10),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: MediaQuery.of(context).size.height * 0.12,
                  left: MediaQuery.of(context).size.height * 0.04,
                  right: MediaQuery.of(context).size.height * 0.04,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Ne yemek istediğini gir ya da içmek istediğini",
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color.fromARGB(255, 105, 105, 105),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.04,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _startTrackingUser();
                        },
                        icon: const Icon(Icons.gps_fixed),
                        label: Text(
                          'Beni Bul',
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            255,
                            115,
                            0,
                          ),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
