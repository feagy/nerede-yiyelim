import 'package:app/database/database.dart';
import 'package:app/database/services/localdbservice.dart';
import 'package:app/pages/firebase_options.dart';
import 'package:app/pages/homepage.dart';
import 'package:app/pages/loginpage.dart';
import 'package:app/notification/notification-test.dart';
import 'package:app/pages/mappage.dart';
import 'package:app/pages/signuppage.dart';
import 'package:app/pages/welcomepage.dart';
import 'package:app/services/aisummaryservice.dart';
import 'package:app/services/authservice.dart';
import 'package:app/services/placephotoservice.dart';
import 'package:app/services/placesservice.dart';
import 'package:app/services/favoritesservice.dart';
import 'package:app/services/reviewsservice.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:app/global/universaltheme.dart';
import 'package:app/pages/reviewpage.dart';
import 'package:app/states/MapStateStore.dart';
import 'package:app/states/PlaceStateStore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:app/functions/locationfunc.dart';
import 'package:latlong2/latlong.dart';


final getIt = GetIt.instance;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final db = await LocalServices.getDatabase();

  NotificationTest.initNotification().catchError((e) {
    debugPrint('Bildirim hatası: $e');
  });

  final String apiKey = dotenv.env['MAPTILER_MAPS_API_KEY'] ?? '';

  final mapStateStore = MapStateStore();
  getIt.registerSingleton<MapStateStore>(mapStateStore);
  getIt.registerSingleton<PlaceStateStore>(PlaceStateStore());
  
  getIt.registerSingleton<PlacesService>(PlacesService());
  getIt.registerSingleton<FavoritesService>(FavoritesService());
  getIt.registerSingleton<ReviewsService>(ReviewsService());
  getIt.registerSingleton<PlacePhotoService>(PlacePhotoService());
  getIt.registerSingleton<AISummaryService>(AISummaryService());

  _initializeLocation(mapStateStore);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BottomTabState()),
      ],
      child: MyApp(keyAPI: apiKey, database: db),
    ),
  );
}

void _initializeLocation(MapStateStore mapStateStore) async {
  final locationService = LocationService();
  
  try {
    final pos = await locationService
        .getUserCurrentLocation()
        .timeout(const Duration(seconds: 10));

    if (pos != null) {
      final latLng = LatLng(pos.latitude, pos.longitude);
      mapStateStore.setUserLocation(latLng);
    } else {
      mapStateStore.setUserLocation(const LatLng(41.0082, 28.9784));
    }
  } catch (e) {
    mapStateStore.setUserLocation(const LatLng(41.0082, 28.9784));
  }
}

class MyApp extends StatelessWidget {
  final String keyAPI;
  final AppDataBase database;

  const MyApp({super.key, required this.keyAPI, required this.database});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          theme: themeProvider.themeData,
          initialRoute: "/",
          routes: {
            "/": (context) => WelcomePage(),
            "/login": (context) => LoginPage(),
            "/signup": (context) => SignupPage(),
            "/home": (context) => HomePage(keyAPI: keyAPI),
          },
        );
      },
    );
  }
}