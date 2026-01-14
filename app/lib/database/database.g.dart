// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDataBaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDataBaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDataBaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDataBase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDataBase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDataBaseBuilderContract databaseBuilder(String name) =>
      _$AppDataBaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDataBaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDataBaseBuilder(null);
}

class _$AppDataBaseBuilder implements $AppDataBaseBuilderContract {
  _$AppDataBaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDataBaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDataBaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDataBase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDataBase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDataBase extends AppDataBase {
  _$AppDataBase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  FavoritesDao? _favoritesDaoInstance;

  ReviewsDao? _reviewsDaoInstance;

  AccountDao? _accountDaoInstance;

  PlaceDao? _placeDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 2,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `favorites` (`id` TEXT NOT NULL, `placeId` TEXT NOT NULL, `userId` TEXT NOT NULL, `placeName` TEXT NOT NULL, `placeAddress` TEXT NOT NULL, `rating` REAL, `photoUrl` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `reviews` (`id` TEXT NOT NULL, `userId` TEXT NOT NULL, `placeId` TEXT NOT NULL, `placeName` TEXT, `placeAddress` TEXT, `rating` INTEGER NOT NULL, `comment` TEXT, `createdAt` INTEGER NOT NULL, `updatedAt` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Account` (`id` TEXT NOT NULL, `email` TEXT NOT NULL, `userName` TEXT NOT NULL, `password` TEXT NOT NULL, `photo` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `places` (`id` TEXT NOT NULL, `distance` REAL NOT NULL, `placeName` TEXT NOT NULL, `phone` TEXT, `address` TEXT, `lat` REAL NOT NULL, `lng` REAL NOT NULL, `googleRating` REAL, `googleRatingCount` INTEGER, `type` TEXT, `googleMapsUri` TEXT, `photoName` TEXT, `openingHoursJson` TEXT, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  FavoritesDao get favoritesDao {
    return _favoritesDaoInstance ??= _$FavoritesDao(database, changeListener);
  }

  @override
  ReviewsDao get reviewsDao {
    return _reviewsDaoInstance ??= _$ReviewsDao(database, changeListener);
  }

  @override
  AccountDao get accountDao {
    return _accountDaoInstance ??= _$AccountDao(database, changeListener);
  }

  @override
  PlaceDao get placeDao {
    return _placeDaoInstance ??= _$PlaceDao(database, changeListener);
  }
}

class _$FavoritesDao extends FavoritesDao {
  _$FavoritesDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _favoriteInsertionAdapter = InsertionAdapter(
            database,
            'favorites',
            (Favorite item) => <String, Object?>{
                  'id': item.id,
                  'placeId': item.placeId,
                  'userId': item.userId,
                  'placeName': item.placeName,
                  'placeAddress': item.placeAddress,
                  'rating': item.rating,
                  'photoUrl': item.photoUrl
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Favorite> _favoriteInsertionAdapter;

  @override
  Future<List<Favorite>> getAllFavorites(String userId) async {
    return _queryAdapter.queryList('SELECT * FROM favorites WHERE userId = ?1',
        mapper: (Map<String, Object?> row) => Favorite(
            id: row['id'] as String,
            placeId: row['placeId'] as String,
            userId: row['userId'] as String,
            placeName: row['placeName'] as String,
            placeAddress: row['placeAddress'] as String,
            rating: row['rating'] as double?,
            photoUrl: row['photoUrl'] as String?),
        arguments: [userId]);
  }

  @override
  Future<int?> isFavorite(
    String placeId,
    String userId,
  ) async {
    return _queryAdapter.query(
        'SELECT EXISTS(SELECT 1 FROM favorites WHERE placeId = ?1 AND userId = ?2)',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [placeId, userId]);
  }

  @override
  Future<void> deleteFavorite(String favoriteId) async {
    await _queryAdapter.queryNoReturn('DELETE FROM favorites WHERE id = ?1',
        arguments: [favoriteId]);
  }

  @override
  Future<void> insertFavorite(Favorite favorite) async {
    await _favoriteInsertionAdapter.insert(
        favorite, OnConflictStrategy.replace);
  }
}

class _$ReviewsDao extends ReviewsDao {
  _$ReviewsDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _reviewInsertionAdapter = InsertionAdapter(
            database,
            'reviews',
            (Review item) => <String, Object?>{
                  'id': item.id,
                  'userId': item.userId,
                  'placeId': item.placeId,
                  'placeName': item.placeName,
                  'placeAddress': item.placeAddress,
                  'rating': item.rating,
                  'comment': item.comment,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Review> _reviewInsertionAdapter;

  @override
  Future<List<Review>> getReviews(
    String placeId,
    int limit,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM reviews WHERE placeId = ?1 ORDER BY updatedAt DESC LIMIT ?2 OFFSET ?3',
        mapper: (Map<String, Object?> row) => Review(id: row['id'] as String, userId: row['userId'] as String, placeId: row['placeId'] as String, placeName: row['placeName'] as String?, placeAddress: row['placeAddress'] as String?, rating: row['rating'] as int, comment: row['comment'] as String?, createdAt: row['createdAt'] as int, updatedAt: row['updatedAt'] as int),
        arguments: [placeId, limit, offset]);
  }

  @override
  Future<int?> hasUserReviewed(
    String placeId,
    String userId,
  ) async {
    return _queryAdapter.query(
        'SELECT EXISTS(SELECT 1 FROM reviews WHERE placeId = ?1 AND userId = ?2)',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [placeId, userId]);
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await _queryAdapter.queryNoReturn('DELETE FROM reviews WHERE id = ?1',
        arguments: [reviewId]);
  }

  @override
  Future<Review?> getUserReviewForPlace(
    String placeId,
    String userId,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM reviews WHERE placeId = ?1 AND userId = ?2 LIMIT 1',
        mapper: (Map<String, Object?> row) => Review(
            id: row['id'] as String,
            userId: row['userId'] as String,
            placeId: row['placeId'] as String,
            placeName: row['placeName'] as String?,
            placeAddress: row['placeAddress'] as String?,
            rating: row['rating'] as int,
            comment: row['comment'] as String?,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int),
        arguments: [placeId, userId]);
  }

  @override
  Future<List<Review>> getReviewsByUser(String userId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM reviews WHERE userId = ?1 ORDER BY updatedAt DESC',
        mapper: (Map<String, Object?> row) => Review(
            id: row['id'] as String,
            userId: row['userId'] as String,
            placeId: row['placeId'] as String,
            placeName: row['placeName'] as String?,
            placeAddress: row['placeAddress'] as String?,
            rating: row['rating'] as int,
            comment: row['comment'] as String?,
            createdAt: row['createdAt'] as int,
            updatedAt: row['updatedAt'] as int),
        arguments: [userId]);
  }

  @override
  Future<void> upsertReview(Review review) async {
    await _reviewInsertionAdapter.insert(review, OnConflictStrategy.replace);
  }
}

class _$AccountDao extends AccountDao {
  _$AccountDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _accountInsertionAdapter = InsertionAdapter(
            database,
            'Account',
            (Account item) => <String, Object?>{
                  'id': item.id,
                  'email': item.email,
                  'userName': item.userName,
                  'password': item.password,
                  'photo': item.photo
                }),
        _accountUpdateAdapter = UpdateAdapter(
            database,
            'Account',
            ['id'],
            (Account item) => <String, Object?>{
                  'id': item.id,
                  'email': item.email,
                  'userName': item.userName,
                  'password': item.password,
                  'photo': item.photo
                }),
        _accountDeletionAdapter = DeletionAdapter(
            database,
            'Account',
            ['id'],
            (Account item) => <String, Object?>{
                  'id': item.id,
                  'email': item.email,
                  'userName': item.userName,
                  'password': item.password,
                  'photo': item.photo
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Account> _accountInsertionAdapter;

  final UpdateAdapter<Account> _accountUpdateAdapter;

  final DeletionAdapter<Account> _accountDeletionAdapter;

  @override
  Future<List<Account>> findAllAccounts() async {
    return _queryAdapter.queryList('SELECT * FROM Account',
        mapper: (Map<String, Object?> row) => Account(
            id: row['id'] as String,
            email: row['email'] as String,
            userName: row['userName'] as String,
            password: row['password'] as String,
            photo: row['photo'] as String?));
  }

  @override
  Future<void> removeAllAccounts() async {
    await _queryAdapter.queryNoReturn('DELETE FROM Account');
  }

  @override
  Future<int> insertAccount(Account account) {
    return _accountInsertionAdapter.insertAndReturnId(
        account, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateAccount(Account account) {
    return _accountUpdateAdapter.updateAndReturnChangedRows(
        account, OnConflictStrategy.abort);
  }

  @override
  Future<int> removeAccount(Account account) {
    return _accountDeletionAdapter.deleteAndReturnChangedRows(account);
  }
}

class _$PlaceDao extends PlaceDao {
  _$PlaceDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _placeInsertionAdapter = InsertionAdapter(
            database,
            'places',
            (Place item) => <String, Object?>{
                  'id': item.id,
                  'distance': item.distance,
                  'placeName': item.placeName,
                  'phone': item.phone,
                  'address': item.address,
                  'lat': item.lat,
                  'lng': item.lng,
                  'googleRating': item.googleRating,
                  'googleRatingCount': item.googleRatingCount,
                  'type': item.type,
                  'googleMapsUri': item.googleMapsUri,
                  'photoName': item.photoName,
                  'openingHoursJson': item.openingHoursJson
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Place> _placeInsertionAdapter;

  @override
  Future<Place?> getPlaceById(String placeId) async {
    return _queryAdapter.query('SELECT * FROM places WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Place(
            id: row['id'] as String,
            distance: row['distance'] as double,
            placeName: row['placeName'] as String,
            phone: row['phone'] as String?,
            address: row['address'] as String?,
            lat: row['lat'] as double,
            lng: row['lng'] as double,
            googleRating: row['googleRating'] as double?,
            googleRatingCount: row['googleRatingCount'] as int?,
            type: row['type'] as String?,
            photoName: row['photoName'] as String?,
            openingHoursJson: row['openingHoursJson'] as String?,
            googleMapsUri: row['googleMapsUri'] as String?),
        arguments: [placeId]);
  }

  @override
  Future<void> deletePlaceById(String placeId) async {
    await _queryAdapter.queryNoReturn('DELETE FROM places WHERE id = ?1',
        arguments: [placeId]);
  }

  @override
  Future<void> upsertPlace(Place place) async {
    await _placeInsertionAdapter.insert(place, OnConflictStrategy.replace);
  }
}
