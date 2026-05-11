abstract class AuthRepository {
  Future<void> initialize();
  Future<bool> signInWithGoogle();
  Future<void> signOut();
  bool get isLoggedIn;
}
