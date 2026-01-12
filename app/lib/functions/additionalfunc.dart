import 'dart:io';
import 'package:app/database/services/localdbservice.dart';
import 'package:app/services/authservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:app/database/entity/account.dart';

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
