import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // BİR DEFA BİLE LOGIN OLUNSA HESAP BİLGİLERİNİ TUTUYOR VE OTOMATİK OLARAK GİRİŞ YAPTIYIRO.
  // BURADA BİRDEN FAZLA HESAP İÇİN VERİ TABANININDA TUTUM OLUP KULLANICIDAN SEÇİM YAPMA EKRANINI
  // ÇIKARTIP ORADAN SEÇİM YAPTIRMALIYIZ.
  // GOOGLE HESAPLARI İLE GİRİŞ YAPARKEN Kİ GİBİ.
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn(
    {
      required String email, required String password
    }) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential> createAccount(
    {
      required String email, required String password
    }) async {
    return await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(
    {
      required String email
    }) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> resetPasswordFromCurrentPassword(
    {
      required String currentPassword,
      required String newPassword,
      required String email
    }) async {
    AuthCredential credential = EmailAuthProvider.credential(
        email: email, password: currentPassword);
    await currentUser?.reauthenticateWithCredential(credential);
    await currentUser?.updatePassword(newPassword);
  }

  Future<void> updateUsername(
    {
      required String displayName
    }) async {
    await currentUser?.updateDisplayName(displayName);
  }

  Future<void> createUsername({required String username}) async {
    final user = currentUser;
    if (user == null) throw Exception("No authenticated user");
    try{
      await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid) // user! yerine user.uid kullanmak daha temiz
        .set({
      'nickname': username,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    } on FirebaseFirestore catch(e) {
      await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .delete();
    }
  }
}