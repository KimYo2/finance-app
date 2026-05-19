import '../../entities/user_profile.dart';
import '../../repositories/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  Future<UserProfile?> call() async {
    return await repository.getCurrentUser();
  }
}
