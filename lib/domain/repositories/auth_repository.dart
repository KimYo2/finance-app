import '../entities/user_profile.dart';

abstract class AuthRepository {
  Future<void> initialize();
  Future<bool> signInWithGoogle();
  Future<bool> signInWithEmail(String email, String password);
  Future<void> signOut();
  Future<UserProfile?> getCurrentUser();
  Future<void> updateProfile(String name);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> deleteAccount();
  bool get isLoggedIn;
  String? get userId;
}
