import 'dart:ffi';

import 'package:floor/floor.dart';

@entity
class Account {
  @primaryKey
  final String id;

  final String email;

  final String userName;

  final String password;

  Account(this.id, this.email, this.userName, this.password);
}