import 'package:app/pages/firebase_options.dart';
import 'package:app/pages/homepage.dart';
import 'package:app/pages/loginpage.dart';
import 'package:app/notification/notification-test.dart';
import 'package:app/pages/signuppage.dart';
import 'package:app/pages/welcomepage.dart';
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

  // BUNU YAPMIŞIZ AMA TAM GEREKLİ Mİ BİLMİYORUM YAZA YAZA GENE YAPILIYOR..
  // BUNU YAPABİLİRİZ YAPMAYA BİLİRİZ. AMA KALSIN BÜYÜK İHTİMALLE EN İYİ METOT BU.
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
