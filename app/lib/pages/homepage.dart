import 'dart:async';

import 'package:app/pages/detailedrestaurantpage.dart';
import 'package:app/pages/mappage.dart';
import 'package:app/pages/profilepage.dart';
import 'package:app/pages/settingspage.dart';
import 'package:app/services/authservice.dart';
import 'package:app/pages/signuppage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// BURADA OLAN SAYFALAR SAHTE SADECE AKIŞI DENEMEK İÇİN
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Favorites Page")),
    );
  }
}
// BURADA OLAN SAYFALAR SAHTE SADECE AKIŞI DENEMEK İÇİN
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Settings Page")),
    );
  }
}

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
        key: _navigatorKey,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(builder: (_) => MapPage(keyAPI: widget.keyAPI));
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomTab,
        onTap: (index) async {
          setState(() {
            _selectedBottomTab = index;
          });

          switch(index) {
            case 0:
              _navigatorKey.currentState!.pushReplacement(
                MaterialPageRoute(builder: (_) => MapPage(keyAPI: widget.keyAPI)),
              );
              break;
            case 1:
              final isLoggedIn = await AuthService().currentUser?.isAnonymous == false;
              if(isLoggedIn) {
                  _navigatorKey.currentState!.pushReplacement(
                    MaterialPageRoute(builder: (_) => ProfilePage()),
                  );
              } else {
                Navigator.of(context, rootNavigator: true).pushReplacement( 
                  MaterialPageRoute(builder: (_) => const SignupPage()), 
                  );
              }
              break;
            case 2:
              _navigatorKey.currentState!.pushReplacement(
                MaterialPageRoute(builder: (_) => const FavoritesPage()),
              );
              break;
            case 3:
              _navigatorKey.currentState!.pushReplacement(
                MaterialPageRoute(builder: (_) => DetailedRestaurantPage()),
              );
              break;
            case 4:
              _navigatorKey.currentState!.pushReplacement(
                MaterialPageRoute(builder: (_) => const FontSettingsPage()),
              );
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 255, 115, 0),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border_rounded), label: 'Favoriler'),
          BottomNavigationBarItem(icon: Icon(Icons.maps_home_work_rounded), label: 'Mekan'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_accessibility_rounded), label: 'Ayarlar'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData? icon) {
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
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
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
