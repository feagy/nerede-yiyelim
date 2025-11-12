import 'package:app/firebase_options.dart';
import 'package:app/homepage.dart';
import 'package:app/loginpage.dart';
import 'package:app/signuppage.dart';
import 'package:app/welcomepage.dart';
import 'package:app/detailedrestaurantpage.dart';
import 'package:app/locationfunc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final String apiKey = dotenv.env['MAPTILER_MAPS_API_KEY'] ?? '';

  runApp(MyApp(keyAPI: apiKey));
}

class MyApp extends StatelessWidget {
  final String keyAPI;
  const MyApp({super.key, required this.keyAPI});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nerede Yiyelim?',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: MainNavigation(keyAPI: keyAPI),
    );
  }
}

// Ana Navigation Widget
class MainNavigation extends StatefulWidget {
  final String keyAPI;
  const MainNavigation({super.key, required this.keyAPI});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Sayfaların listesi
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      WelcomePage(),
      LoginPage(),
      SignupPage(),
      HomePage(keyAPI: widget.keyAPI),
      DetailedRestaurantPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.waving_hand),
            label: 'Welcome Page',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Login Page',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Signup Page',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home Page',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Details Page',
          ),
        ],
      ),
    );
  }
}