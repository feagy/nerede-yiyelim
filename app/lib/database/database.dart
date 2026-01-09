import 'package:app/database/dao/accountdao.dart';
import 'package:app/database/entity/account.dart';
import 'package:floor/floor.dart';
import 'entity/favorite.dart';
import 'package:app/database/dao/favoritesdao.dart';
import 'entity/review.dart';
import 'dao/reviewsdao.dart';
import 'dart:async'; 
import 'package:sqflite/sqflite.dart' as sqflite;


// part 'database.g.dart'; // Yapılacak

// DENEME İÇİN YAPILDI
part 'database.g.dart';
@Database(version: 1, entities: [Favorite, Review, Account])
abstract class AppDataBase extends FloorDatabase {
  FavoritesDao get favoritesDao;
  ReviewsDao get reviewsDao;
  AccountDao get accountDao;
}