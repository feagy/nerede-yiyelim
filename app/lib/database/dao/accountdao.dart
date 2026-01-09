import 'package:app/database/entity/account.dart';
import 'package:floor/floor.dart';

@dao
abstract class AccountDao {
  @Query("SELECT * FROM Account")
  Future<List<Account>> findAllAccounts();

  @insert
  Future<int> insertAccount(Account account);

  @delete
  Future<int> removeAccount(Account account);

  @Query("DELETE FROM Account")
  Future<void> removeAllAccounts();

  @update
  Future<int> updateAccount(Account account);
}