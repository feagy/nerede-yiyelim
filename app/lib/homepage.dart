import 'dart:async';

import 'package:app/detailedrestaurantpage.dart';
import 'package:app/functions/additionalfunc.dart';
import 'package:app/mappage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:app/functions/locationfunc.dart';

class HomePage extends StatefulWidget {
  final String keyAPI;
  const HomePage({super.key, required this.keyAPI});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedBottomTab = 0;
  String _selectedFilter = 'Filtrele';

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        // NavigatorState üzerinden sayfalar arası geçisi sağlamak.
        // Burada olay şu bunu böyle yapınca routes'a ekleme yapmaya gerek kalmıyor.
        // Böyle olunca daha mantıklı yoksa akışı yapmam lazım.
        key: _navigatorKey,
        // Buradakinin amacı ayarları tutmak.
        onGenerateRoute: (settings) {
          return MaterialPageRoute(builder: (_) => MapPage(keyAPI: widget.keyAPI));
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomTab,
        onTap: (index) {
          setState(() {
            _selectedBottomTab = index;
          });

          Additionalfunc.changePage(index, _navigatorKey, widget.keyAPI);
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


  Widget _buildFilterChip(
    String label,
    IconData? icon) {
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
              style: GoogleFonts.lato(
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
