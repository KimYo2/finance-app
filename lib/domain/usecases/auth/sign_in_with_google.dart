import '../../repositories/auth_repository.dart';

class SignInWithGoogle {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  Future<bool> call() async {
    return await repository.signInWithGoogle();
  }
}
