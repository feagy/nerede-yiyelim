import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

final Migration migration1to2 = Migration(1, 2, (sqflite.Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS `places` (
      `id` TEXT NOT NULL,
      `distance` REAL NOT NULL,
      `placeName` TEXT NOT NULL,
      `phone` TEXT,
      `address` TEXT,
      `lat` REAL NOT NULL,
      `lng` REAL NOT NULL,
      `googleRating` REAL,
      `googleRatingCount` INTEGER,
      `type` TEXT,
      `googleMapsUri` TEXT,
      `photoName` TEXT,
      `openingHoursJson` TEXT,
      PRIMARY KEY (`id`)
    )
  ''');
});