import 'package:app/database/database.dart';
import 'dart:async';

class LocalServices {
  static AppDataBase? _db;

  static Future<AppDataBase> getDatabase() async {
    if (_db != null) return _db!;
    _db = await $FloorAppDataBase
        .databaseBuilder('app_database.db')
        .build();
    return _db!;
  }
}
