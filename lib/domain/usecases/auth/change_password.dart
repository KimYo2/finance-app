import '../../repositories/auth_repository.dart';

class ChangePassword {
  final AuthRepository repository;

  ChangePassword(this.repository);

  Future<void> call(String currentPassword, String newPassword) async {
    await repository.changePassword(currentPassword, newPassword);
  }
}
