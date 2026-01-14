import 'dart:io';
import 'package:app/database/services/localdbservice.dart';
import 'package:app/services/authservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:app/database/entity/account.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:app/services/reviewsservice.dart';
import 'package:app/services/favoritesservice.dart';

/*
Future<void> _pickAndSavePhoto(AccountDto dao, Account account) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    final file = File(pickedFile.path);

    final dir = await getApplicationDocumentsDirectory();
    final localPath = "${dir.path}/profile_${account.id}.jpg";

    await file.copy(localPath);

    final updatedAccount = Account(
      id: account.id,
      email: account.email,
      userName: account.userName,
      password: account.password,
      photo: localPath,
    );

    // DB’de güncelle
    await dao.updateAccount(updatedAccount);
  }
}
*/
Future<bool> signInAndSaveAccount({
  required String email,
  required String password,
  String? username,
}) async {
  try {
    await AuthService().signIn(email: email, password: password);

    if (username != null && username.isNotEmpty) {
      await AuthService().createUsername(username: username);
    }

    final db = await LocalServices.getDatabase();
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(AuthService().currentUser!.uid)
        .get();

    if (doc.exists) {
      await db.accountDao.insertAccount(
        Account(
          id: AuthService().currentUser?.uid ?? "",
          email: email,
          userName: doc['nickname'] ?? "",
          password: password,
        ),
      );

     /*  final uid = AuthService().currentUser!.uid;
      final prefs = await SharedPreferences.getInstance();
      final isSynched = prefs.getBool('initial_sync_$uid') ?? false;

      if (!isSynched) {
        String? cursor;
        do {
          final page = await GetIt.I<ReviewsService>()
              .readReviewsByUser(userId: uid, cursor: cursor);

          for (final review in page.items) {
            await db.reviewsDao.upsertReview(review);
          }

          cursor = page.hasMore ? page.nextCursor : null;
        } while (cursor != null);

        final favorites = await GetIt.I<FavoritesService>().readFavorites(uid);
        for (final fav in favorites) {
          await db.favoritesDao.insertFavorite(fav);
        }

        await prefs.setBool('initial_sync_$uid', true);
      } */
      return true;
    }

    return false;
  } catch (e) {
    return false;
  }
}

Future<void> changeFastSignInPassword({required String password}) async {
  final db = await LocalServices.getDatabase();
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(AuthService().currentUser!.uid)
      .get();
  if (doc.exists) {
    await db.accountDao.updateAccount(
      Account(
        id: AuthService().currentUser!.uid,
        email: AuthService().currentUser!.email ?? " ",
        userName: AuthService().currentUser!.displayName ?? " ",
        password: password,
      ),
    );
  }
}
