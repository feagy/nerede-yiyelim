import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:app/locationfunc.dart';
class HomePage extends StatefulWidget {
  final String keyAPI;
  const HomePage({super.key, required this.keyAPI});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final MapController _mapController;
  final List<Marker> _userMarkers = [];
  int _selectedBottomTab = 0;
  String _selectedFilter = 'Filtrele';

  final LocationService _locationService = LocationService();
  StreamSubscription? _locationStream;
  LatLng? _currentUserLatLng;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    _initUserLocation();
  }

  Future<void> _initUserLocation() async {
    final pos = await _locationService.getUserCurrentLocation();
    if (pos != null) {
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
                        point: _currentUserLatLng ?? const LatLng(41.0082, 28.9784),
                        color: Colors.amber.withOpacity(0.1),
                        borderStrokeWidth: 2,
                        borderColor: Colors.amberAccent,
                        useRadiusInMeter: true,
                        radius: 500,
                      )
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
                    MarkerLayer(
                      markers: _userMarkers,
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
                        style: GoogleFonts.lato(
                          color: const Color.fromARGB(255, 255, 115, 0),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          shadows: [
                              Shadow(
                                color: const Color.fromARGB(223, 77, 42, 10),
                                blurRadius: 16,
                                offset: Offset(0, 4)
                              )
                            ]
                        ),
                      ),
                    )
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
                      hintText: "Please write what you want to eat/drink",
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color.fromARGB(255, 105, 105, 105),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                        )
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _startTrackingUser();
                      },
                      icon: const Icon(Icons.gps_fixed),
                      label: Text(
                        'Track Me',
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 115, 0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
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

    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _selectedBottomTab,
      onTap: (index) {
        setState(() {
          _selectedBottomTab = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color.fromARGB(255, 255, 115, 0),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border_rounded), label: 'Favorites'),
        BottomNavigationBarItem(icon: Icon(Icons.maps_home_work_rounded), label: 'Place'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
      ],
    ),
  );
}


  Widget _buildFilterChip(String label, IconData? icon, {bool isFirst = false}) {
    final isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
