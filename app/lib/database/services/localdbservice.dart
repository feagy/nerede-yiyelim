import 'package:app/database/database.dart';
import 'dart:async';
import 'package:app/database/migrations.dart';

class LocalServices {
  static AppDataBase? _db;

  static Future<AppDataBase> getDatabase() async {
    if (_db != null) return _db!;
    _db = await $FloorAppDataBase
        .databaseBuilder('app_database.db')
        .addMigrations([migration1to2])
        .build();
    return _db!;
  }
}