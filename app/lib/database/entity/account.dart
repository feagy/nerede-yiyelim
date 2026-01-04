import 'package:floor/floor.dart';

@entity
class Account {
  @primaryKey
  final String id;

  final String email;

  final String userName;

  final String password;

  final String? photo;

  Account({required this.id, required this.email, required this.userName, required this.password, this.photo});
}