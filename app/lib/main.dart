import 'package:app/detailedrestaurantpage.dart';
import 'package:app/firebase_options.dart';
import 'package:app/homepage.dart';
import 'package:app/loginpage.dart';
import 'package:app/mappage.dart';
import 'package:app/notification/notification-test.dart';
import 'package:app/signuppage.dart';
import 'package:app/welcomepage.dart';
//import 'package:app/welcomepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationTest.initNotification();
  await NotificationTest.showNotificationSingle();

  final String apiKey = dotenv.env['MAPTILER_MAPS_API_KEY'] ?? '';

  runApp(MyApp(keyAPI: apiKey));
}

class MyApp extends StatelessWidget {
  final String keyAPI;
  const MyApp({super.key, required this.keyAPI});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      routes: {
        "/": (context) => WelcomePage(),
        "/login": (context) => LoginPage(),
        "/signup": (context) => SignupPage(),
        "/home": (context) => HomePage(keyAPI: keyAPI),
      },
    );
  }
}
