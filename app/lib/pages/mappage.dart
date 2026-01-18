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
  
  List<Place> nearbyPlaces = [];
  bool _isInitializing = true;

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

    if (_mapStateStore.userLocation != null) {
      _isInitializing = false;
      _mapStateStore.startTracking(_locationService);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        
        if (mounted && _mapStateStore.userLocation != null) {
          _mapController.move(_mapStateStore.userLocation!, 15);
        }
      });
    } else {
      _waitForLocation();
    }
  }
  
  Future<void> _waitForLocation() async {
    int waitCount = 0;
    while (_mapStateStore.userLocation == null && waitCount < 40 && mounted) {
      await Future.delayed(const Duration(milliseconds: 250));
      waitCount++;
    }
    
    if (_mapStateStore.userLocation == null && mounted) {
      _mapStateStore.setUserLocation(const LatLng(41.0082, 28.9784));
    }
    
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
      _mapStateStore.startTracking(_locationService);
      if (_mapStateStore.userLocation != null) {
        _mapController.move(_mapStateStore.userLocation!, 15);
      }
    }
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

  Widget _buildRadiusToggleButton() {
    return FloatingActionButton(
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
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomTabState = Provider.of<BottomTabState>(context);
    
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  color: Color(0xFFFF7300),
                  strokeWidth: 4,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Konumunuz alınıyor...",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Lütfen bekleyiniz",
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final displayLocation = _mapStateStore.userLocation ?? const LatLng(41.0082, 28.9784);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                onMapReady: () {
                  if (_mapStateStore.userLocation != null) {
                    _mapController.move(_mapStateStore.userLocation!, 15);
                  }
                },
                initialCenter: displayLocation,
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
                  maxNativeZoom: 19,
                  tileProvider: NetworkTileProvider(),
                ),
                CircleLayer(
                  circles: [
                    if(_mapStateStore.userLocation != null)
                      CircleMarker(
                        point: _mapStateStore.userLocation!,
                        color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
                        borderStrokeWidth: 2,
                        borderColor: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
                        useRadiusInMeter: true,
                        radius: _radius.toDouble(),
                      ),
                  ],
                ),
                if (_mapStateStore.userLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _mapStateStore.userLocation!,
                        width: 50,
                        height: 50,
                        child: Icon(
                          Icons.emoji_people,
                          color: const Color.fromARGB(255, 255, 115, 0),
                          size: MediaQuery.of(context).size.height * 0.05,
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
                      _openPlaceSheet(place, bottomTabState);
                    },
                    context,
                  ),
                ),
              ],
            ),
          ),
      
          // Başlık
          Positioned(
            top: MediaQuery.of(context).size.height * 0.04,
            left: MediaQuery.of(context).size.height * 0.01,
            right: MediaQuery.of(context).size.height * 0.01,
            child: Center(
              child: Text(
                "Nerede Yiyelim?",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 255, 115, 0),
                  shadows: const [
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
                boxShadow: const [
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
                        selectedColor: const Color.fromARGB(255, 255, 115, 0),
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(
                            color: Color.fromARGB(255, 255, 115, 0),
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
            right: 16,
            bottom: MediaQuery.of(context).size.height * 0.15,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_showRadiusSlider)
                  Container(
                    height: 250,
                    width: 50,
                    margin: const EdgeInsets.only(bottom: 16),
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
                _buildRadiusToggleButton(),
              ],
            ),
          ),
          
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.04,
            left: 10,
            right: 10,
            child: Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 50,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _mapStateStore.startTracking(_locationService);
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
                        backgroundColor: const Color.fromARGB(255, 255, 115, 0),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _mapStateStore.userLocation == null ? null : () async {
                        final results = await _fetchPlaces(
                          textQuery: selectedCategory,
                          lat: _mapStateStore.userLocation!.latitude,
                          lng: _mapStateStore.userLocation!.longitude,
                          radius: _radius,
                        );
                        setState(() {
                          nearbyPlaces = results;
                        });
                        _mapStateStore.setPlaces(results);
                      },
                      icon: const Icon(Icons.search),
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
                        backgroundColor: const Color.fromARGB(255, 255, 115, 0),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}