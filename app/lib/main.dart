import 'package:app/database/database.dart';
import 'package:app/database/services/localdbservice.dart';
import 'package:app/pages/firebase_options.dart';
import 'package:app/pages/homepage.dart';
import 'package:app/pages/loginpage.dart';
import 'package:app/notification/notification-test.dart';
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

final getIt = GetIt.instance;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final db = await LocalServices.getDatabase();

  await NotificationTest.initNotification();
  await NotificationTest.showNotificationSingle();

  final String apiKey = dotenv.env['MAPTILER_MAPS_API_KEY'] ?? '';

  
  getIt.registerSingleton<MapStateStore>(MapStateStore());
  getIt.registerSingleton<PlacesService>(PlacesService());
  getIt.registerSingleton<FavoritesService>(FavoritesService());
  getIt.registerSingleton<ReviewsService>(ReviewsService());
  getIt.registerSingleton<PlacePhotoService>(PlacePhotoService());
  getIt.registerSingleton<AISummaryService>(AISummaryService());

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(keyAPI: apiKey, database: db),
    ),
  );
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
