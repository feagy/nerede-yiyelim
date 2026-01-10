import 'dart:async';
import 'package:app/services/placesservice.dart';
import 'package:app/services/reviewsservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:app/functions/locationfunc.dart';
import 'package:app/database/entity/place.dart';
import 'package:app/pages/mapmarkers.dart';
import 'detailedrestaurantpage.dart';

class MapPage extends StatefulWidget {
  final String keyAPI;
  const MapPage({super.key, required this.keyAPI});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final MapController _mapController;
  final TextEditingController _queryController = TextEditingController();
  final List<Marker> _userMarkers = [];

  final LocationService _locationService = LocationService();
  StreamSubscription? _locationStream;
  LatLng? _currentUserLatLng;

  List<Place> nearbyPlaces = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    _initUserLocation();
  }

  Future<void> _openPlaceSheet(Place p) async {
    final sheetWidget = Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, // arka plan beyaz
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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (p.type == 'restaurant')
                const Icon(
                  Icons.restaurant,
                  color: Color.fromARGB(255, 255, 115, 0),
                ),
              if (p.type == 'cafe')
                const Icon(
                  Icons.local_cafe,
                  color: Color.fromARGB(255, 255, 115, 0),
                ),
              if (p.type == 'pub')
                const Icon(
                  Icons.local_bar,
                  color: Color.fromARGB(255, 255, 115, 0),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.star,
                size: 18,
                color: Color.fromARGB(255, 255, 115, 0),
              ),
              const SizedBox(width: 4),
              Text("${p.googleRating}"),
              const SizedBox(width: 6),
              Text(
                "(${p.googleRatingCount})",
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                      255,
                      255,
                      115,
                      0,
                    ), // turuncu
                    foregroundColor: Colors.white, // ikon ve yazı beyaz
                    textStyle: Theme.of(
                      context,
                    ).textTheme.displaySmall?.copyWith(color: Colors.white),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.directions),
                  label: const Text("Yol Tarifi Al"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 115, 0),
                    foregroundColor: Colors.white,
                    textStyle: Theme.of(
                      context,
                    ).textTheme.displaySmall?.copyWith(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DetailedRestaurantPage(place: p),
                      ),
                    );
                  },
                  child: const Text("Detayları Gör"),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    showDialog(
      context: context,
      builder: (_) =>
          Dialog(backgroundColor: Colors.transparent, child: sheetWidget),
    );
  }

  Future<List<Place>> _fetchPlaces({
    required String textQuery,
    required double lat,
    required double lng,
    required int radius,
  }) async {
    final placesService = GetIt.I<PlacesService>();
    return placesService.fetchPlaces(
      textQuery: textQuery,
      lat: lat,
      lng: lng,
      radius: radius,
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
                    MarkerLayer(
                      markers: MapMarkers.getPlaceMarkers<Place>(
                        nearbyPlaces,
                        (place) => LatLng(place.lat, place.lng),
                        (place) {
                          _openPlaceSheet(place);
                        },
                        context,
                      ),
                    ),
                  ],
                ),

                Positioned(
                  top: MediaQuery.of(context).size.height * 0.04,
                  left: MediaQuery.of(context).size.height * 0.01,
                  right: MediaQuery.of(context).size.height * 0.01,
                  child: Center(
                    child: Text(
                      "Nerede Yiyelim?",
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 255, 115, 0),
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
                      controller: _queryController,
                      decoration: InputDecoration(
                        hintText:
                            "Ne yemek istediğini gir ya da içmek istediğini",
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              _startTrackingUser();
                            },
                            icon: const Icon(Icons.gps_fixed),
                            label: Text(
                              'Beni Bul',
                              style: Theme.of(context).textTheme.displayMedium
                                  ?.copyWith(
                                    color: Colors.white,
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
                          ElevatedButton.icon(
                            onPressed: () async {
                              nearbyPlaces = await _fetchPlaces(
                                textQuery: _queryController.text,
                                lat: 40.9917, //_currentUserLatLng?.latitude ??,
                                lng:
                                    28.8517, //_currentUserLatLng?.longitude ??,
                                radius: 5000,
                              );
                              setState(() {
                                nearbyPlaces = nearbyPlaces;
                              });
                            },
                            icon: const Icon(Icons.gps_fixed),
                            label: Text(
                              'Mekan Bul',
                              style: Theme.of(context).textTheme.displayMedium
                                  ?.copyWith(
                                    color: Colors.white,
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
                        ],
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
