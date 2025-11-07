import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

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

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Color.fromARGB(255, 29, 29, 29),
          ),
          onPressed: () {},
        ),
        title: Text(
          "Nerede Yiyelim?",
          style: GoogleFonts.lato(
            color: const Color.from(alpha: 1, red: 1, green: 0.451, blue: 0),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Please write what you want to eat/drink",
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color.fromARGB(255, 105, 105, 105),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color.from(alpha: 1, red: 1, green: 0.451, blue: 0),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                // Harita
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
                              color: Color.from(alpha: 1, red: 1, green: 0.451, blue: 0),
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
                          point: const LatLng(41.0082, 28.9784),
                          color: Colors.amber.withOpacity(0.1),
                          borderStrokeWidth: 2,
                          borderColor: Colors.amberAccent,
                          useRadiusInMeter: true,
                          radius: 500,
                        )
                      ],
                    ),
                    if (_userMarkers.isNotEmpty)
                      MarkerLayer(
                        markers: _userMarkers,
                      ),
                  ],
                ),

                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.view_list),
                      label: Text('List View',
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                        ),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:const Color.from(alpha: 1, red: 1, green: 0.451, blue: 0),
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
        selectedItemColor: const Color.from(alpha: 1, red: 1, green: 0.451, blue: 0),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
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