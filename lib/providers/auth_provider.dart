import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/pb_client.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;
  RecordModel? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RecordModel? get currentUser => _currentUser;
  String get userName => _currentUser?.data['name'] as String? ?? 'Pengguna';
  String get userEmail => _currentUser?.data['email'] as String? ?? '';
  String? get userAvatar => _currentUser?.data['avatarUrl'] as String?;

  PocketBase get _pb => PbClient.instance;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isLoggedIn = _pb.authStore.isValid;
      _currentUser = _pb.authStore.isValid ? _pb.authStore.model as RecordModel? : null;
    } catch (e) {
      debugPrint('[Auth] initialize error: $e');
      _isLoggedIn = false;
      _currentUser = null;
    }

    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _pb.collection('users').authWithOAuth2Code(
        'google',
        (url) async {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        },
      );

      _isLoggedIn = result != null && _pb.authStore.isValid;
      _currentUser = _isLoggedIn ? _pb.authStore.model as RecordModel? : null;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return _isLoggedIn;
    } catch (e) {
      debugPrint('[Auth] signInWithGoogle error: $e');
      _isLoggedIn = false;
      _currentUser = null;
      _isLoading = false;

      final msg = e.toString().toLowerCase();
      if (msg.contains('cancel')) {
        _errorMessage = 'Login dibatalkan';
      } else if (msg.contains('network') || msg.contains('connection') || msg.contains('timeout')) {
        _errorMessage = 'Tidak dapat terhubung ke server. Cek koneksi internet kamu';
      } else {
        _errorMessage = 'Login gagal. Silakan coba lagi';
      }

      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _pb.authStore.clear();
    _isLoggedIn = false;
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }
}
