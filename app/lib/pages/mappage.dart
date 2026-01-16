import 'dart:async';
import 'package:app/global/universaltheme.dart';
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
import 'package:provider/provider.dart';
import 'detailedrestaurantpage.dart';
import 'package:app/states/MapStateStore.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_core/theme.dart';


class MapPage extends StatefulWidget {
  final String keyAPI;
  const MapPage({super.key, required this.keyAPI});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final MapController _mapController;
  final List<Marker> _userMarkers = [];
  late final MapStateStore _mapStateStore;
  final LocationService _locationService = LocationService();
  StreamSubscription? _locationStream;
  LatLng? _currentUserLatLng;

  List<Place> nearbyPlaces = [];

  //Radyüs slider
  int _radius = 1000; // metre
  bool _showRadiusSlider = false;

  //Sliver box için veri
  final List<String> categories = [
    "Pizza",
    "Burger",
    "Kebap",
    "Tatlı",
    "Kahve",
    "Sushi",
    "Döner",
  ];
  int selectedCategoryIndex = 0;
  String get selectedCategory => categories[selectedCategoryIndex];

  @override
  void initState() {
    super.initState();
    _mapStateStore = GetIt.instance<MapStateStore>();
    _mapController = MapController();
    nearbyPlaces = _mapStateStore.nearbyPlaces;
    selectedCategoryIndex = _mapStateStore.selectedCategoryIndex;
    _initUserLocation();
  }

  Future<void> _openPlaceSheet(Place p, BottomTabState bottomTabState) async {
    final sheetWidget = Container(
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
                    backgroundColor: const Color.fromARGB(255, 255, 115, 0),
                    foregroundColor: Colors.white,
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
                  onPressed: () async {
                    Navigator.of(context, rootNavigator: true).pop();
                    await Future.delayed(const Duration(milliseconds: 100));
                    if (mounted) {
                      bottomTabState.setTab(3);
                      bottomTabState.navigatorKey.currentState?.push(
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailedRestaurantPage(place: p),
                        ),
                      );
                    }
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

  Future<Marker> _buildUserMarker() async {
    return Marker(
      point: _currentUserLatLng!,
      width: 50,
      height: 50,
      child: Icon(Icons.emoji_people, color: Color.fromARGB(255, 255, 115, 0), size: MediaQuery.of(context).size.height * 0.05),
    );
  }

  Widget _buildVerticalRadiusSlider() {
    if (!_showRadiusSlider) return const SizedBox();

    return Positioned(
      right: 10,
      bottom: 100,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _showRadiusSlider ? 1.0 : 0.0,
        child: Container(
          height: 250,
          width: 50,
          padding: const EdgeInsetsGeometry.directional(),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.2)),
            ],
          ),
          child: SfSliderTheme(
            data: SfSliderThemeData(
              tooltipBackgroundColor: const Color.fromARGB(255, 255, 115, 0),
              tooltipTextStyle: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.white
              )
            ),
            child: SfSlider.vertical(
              inactiveColor: Colors.white,
              activeColor: const Color.fromARGB(255, 255, 115, 0),
              min: 50,
              max: 5000,
              interval: 9,
              value: _radius.toDouble(),
              enableTooltip: true,
              tooltipTextFormatterCallback: (value, text) {
                return "${(value / 1000).toStringAsFixed(1)} km";
              },
              onChanged: (value) {
                setState(() {
                  _radius = value.toInt();
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadiusToggleButton() {
    return Positioned(
      right: 16,
      bottom: 30,
      child: FloatingActionButton(
        heroTag: "radius_button",
        backgroundColor: const Color.fromARGB(255, 255, 115, 0),
        child: Icon(
          _showRadiusSlider ? Icons.close : Icons.radar,
          color: Colors.white,
        ),
        onPressed: () {
          setState(() {
            _showRadiusSlider = !_showRadiusSlider;
          });
        },
      ),
    );
  }

  //
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
    final bottomTabState = Provider.of<BottomTabState>(context);
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
                    initialCenter: _currentUserLatLng ?? LatLng(41.000, 41.000),
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
                              const LatLng(40.9917, 28.8517),
                          color: Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
                          borderStrokeWidth: 2,
                          borderColor: Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
                          useRadiusInMeter: true,
                          radius: _radius.toDouble(),
                        ),
                      ],
                    ),
                    if (_currentUserLatLng != null)
                      FutureBuilder(
                        future: _buildUserMarker(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color.fromARGB(255, 255, 115, 0)
                              ),
                            );
                          }
                          return MarkerLayer(markers: [snapshot.data!]);
                        },
                      ),
                    if (_userMarkers.isNotEmpty)
                      MarkerLayer(markers: _userMarkers),
                    MarkerLayer(
                      markers: MapMarkers.getPlaceMarkers<Place>(
                        nearbyPlaces,
                        (place) => LatLng(place.lat, place.lng),
                        (place) {
                          _openPlaceSheet(place, bottomTabState);
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
                                color: Colors.black,
                                blurRadius: 12,
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
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 50,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 48,
                      child: Material(
                        type: MaterialType.transparency,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          itemCount: categories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final isSelected = selectedCategoryIndex == index;

                            return ChoiceChip(
                              label: Text(
                                categories[index],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color.fromARGB(255, 255, 115, 0),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              checkmarkColor: Colors.white,
                              selected: isSelected,
                              selectedColor: const Color.fromARGB(
                                255,
                                255,
                                115,
                                0,
                              ),
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: const Color.fromARGB(255, 255, 115, 0),
                                  width: 1,
                                ),
                              ),
                              onSelected: (selected) async {
                                setState(() {
                                  selectedCategoryIndex = index;
                                });
                                _mapStateStore.setSelectedCategoryIndex(index);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: MediaQuery.of(context).size.height * 0.15,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10, bottom: 4),
                    child: Column(
                      children: [
                        _buildVerticalRadiusSlider(),
                        _buildRadiusToggleButton(),
                      ],
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
                            blurRadius: 50,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            spacing: 12,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsetsGeometry.directional(
                                    start: 10,
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _startTrackingUser();
                                    },
                                    icon: const Icon(Icons.gps_fixed),
                                    label: Text(
                                      'Beni Bul',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium
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
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsetsGeometry.directional(
                                    end: 10,
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final results = await _fetchPlaces(
                                        textQuery: selectedCategory,
                                        lat:
                                            40.9917, //_currentUserLatLng?.latitude ?? 40.9917,
                                        lng:
                                            28.8517, //_currentUserLatLng?.longitude ?? 28.8517,
                                        radius: _radius,
                                      );
                                      setState(() {
                                        nearbyPlaces = results;
                                      });
                                      _mapStateStore.setPlaces(results);
                                    },
                                    icon: const Icon(Icons.gps_fixed),
                                    label: Text(
                                      'Mekan Bul',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium
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
                                ),
                              ),
                            ],
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
