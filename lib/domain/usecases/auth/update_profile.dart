import '../../repositories/auth_repository.dart';

class UpdateProfile {
  final AuthRepository repository;

  UpdateProfile(this.repository);

  Future<void> call(String name) async {
    await repository.updateProfile(name);
  }
}
