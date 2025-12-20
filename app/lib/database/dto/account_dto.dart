import 'package:app/database/entity/account.dart';
import 'package:floor/floor.dart';

@dao
abstract class AccountDto {
  @Query("SELECT * FROM Account")
  Future<List<Account>> findAllAccounts();

  @delete
  Future<int?> removeAccount();

  @delete
  Future<int?> removeAllAccount();
}