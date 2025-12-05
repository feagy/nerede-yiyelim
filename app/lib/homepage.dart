import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:app/locationfunc.dart';

class HomePage extends HookWidget {
  final String keyAPI;
  const HomePage({super.key, required this.keyAPI});

  @override
  Widget build(BuildContext context) {
    final mapController = useMemoized(() => MapController());
    final userMarkers = useState<List<Marker>>([]);
    final selectedBottomTab = useState(0);
    final selectedFilter = useState('Filtrele');
    final currentUserLatLng = useState<LatLng?>(null);
    final locationService = useMemoized(() => LocationService());
    final locationStream = useRef<StreamSubscription?>(null);

    useEffect(() {
      Future.microtask(() async {
        final pos = await locationService.getUserCurrentLocation();
        if (pos != null) {
          currentUserLatLng.value = LatLng(pos.latitude, pos.longitude);
          mapController.move(currentUserLatLng.value!, 15.0);
        }
      });
      return () {
        locationStream.value?.cancel();
        mapController.dispose();
      };
    }, []);

    Future<void> _initUserLocation() async {
      final pos = await locationService.getUserCurrentLocation();
      if (pos != null) {
        currentUserLatLng.value = LatLng(pos.latitude, pos.longitude);
        mapController.move(currentUserLatLng.value!, 15.0);
      }
    }

    Future<void> _startTrackingUser() async {
      locationStream.value = await locationService.startUpdateUserCurrentLocation(
        onLocationChanged: (pos) {
          final newLatLng = LatLng(pos.latitude, pos.longitude);
          currentUserLatLng.value = newLatLng;
          mapController.move(newLatLng, mapController.camera.zoom);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Nerede Yiyelim?",
          style: GoogleFonts.lato(
            color: const Color.fromARGB(255, 255, 115, 0),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Please write what you want to eat/drink",
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(41.0082, 28.9784),
                    initialZoom: 11.0,
                    onTap: (tapPosition, point) {
                      userMarkers.value = [
                        ...userMarkers.value,
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
                      ];
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://api.maptiler.com/maps/hybrid/256/{z}/{x}/{y}.jpg?key=$keyAPI",
                      userAgentPackageName: "com.example.app",
                    ),
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: currentUserLatLng.value ??
                              const LatLng(41.0082, 28.9784),
                          color: Colors.amber.withOpacity(0.1),
                          borderColor: Colors.amberAccent,
                          useRadiusInMeter: true,
                          radius: 500,
                        )
                      ],
                    ),
                    if (currentUserLatLng.value != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: currentUserLatLng.value!,
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
                    if (userMarkers.value.isNotEmpty)
                      MarkerLayer(markers: userMarkers.value),
                  ],
                ),
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: _startTrackingUser,
                      icon: const Icon(Icons.gps_fixed),
                      label: const Text("Track Me"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedBottomTab.value,
        onTap: (index) => selectedBottomTab.value = index,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
