import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:app/database/entity/account.dart';
import 'package:app/database/dto/account_dto.dart';

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
