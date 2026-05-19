import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/user_profile.dart';
import '../../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthCheckStatus>(_onCheckAuthStatus);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthGoogleLoginRequested>(_onGoogleLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthDeleteAccountRequested>(_onDeleteAccountRequested);
    on<AuthUpdateProfileRequested>(_onUpdateProfileRequested);
    on<AuthChangePasswordRequested>(_onChangePasswordRequested);
  }

  Future<UserProfile?> _refreshProfile() async {
    try {
      return await _authRepository.getCurrentUser();
    } catch (e) {
      debugPrint('[AuthBloc] refresh profile error: $e');
      return null;
    }
  }

  Future<void> _onCheckAuthStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final profile = await _refreshProfile();
      if (profile != null) {
        emit(AuthAuthenticated(profile: profile));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      debugPrint('[AuthBloc] check error: $e');
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _emitAuthenticated(Emitter<AuthState> emit) async {
    final profile = await _refreshProfile();
    if (profile != null) {
      emit(AuthAuthenticated(profile: profile));
    } else {
      emit(const AuthError(message: 'Gagal memuat profil'));
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signInWithEmail(event.email, event.password);
      await _emitAuthenticated(emit);
    } catch (e) {
      debugPrint('[AuthBloc] login error: $e');
      final msg = e.toString().toLowerCase();
      if (msg.contains('invalid') ||
          msg.contains('credentials') ||
          msg.contains('password')) {
        emit(const AuthError(message: 'Email atau password salah'));
      } else if (msg.contains('network') ||
          msg.contains('connection') ||
          msg.contains('socket')) {
        emit(const AuthError(
          message: 'Tidak dapat terhubung ke server. Periksa koneksi internet kamu',
        ));
      } else if (msg.contains('timeout')) {
        emit(const AuthError(message: 'Koneksi timeout. Coba lagi'));
      } else {
        emit(const AuthError(message: 'Login gagal. Silakan coba lagi'));
      }
    }
  }

  Future<void> _onGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signInWithGoogle();
      await _emitAuthenticated(emit);
    } catch (e) {
      debugPrint('[AuthBloc] google login error: $e');
      final msg = e.toString().toLowerCase();
      if (msg.contains('cancel')) {
        emit(const AuthUnauthenticated());
      } else if (msg.contains('network') ||
          msg.contains('connection') ||
          msg.contains('socket')) {
        emit(const AuthError(
          message: 'Tidak dapat terhubung ke server. Periksa koneksi internet kamu',
        ));
      } else {
        emit(const AuthError(message: 'Login gagal. Silakan coba lagi'));
      }
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      debugPrint('[AuthBloc] logout error: $e');
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onDeleteAccountRequested(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.deleteAccount();
      emit(const AuthUnauthenticated());
    } catch (e) {
      debugPrint('[AuthBloc] delete account error: $e');
      emit(AuthError(message: 'Gagal menghapus akun: $e'));
    }
  }

  Future<void> _onUpdateProfileRequested(
    AuthUpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.updateProfile(event.name);
      emit(const AuthActionSuccess(message: 'Profil berhasil diperbarui'));
      await _emitAuthenticated(emit);
    } catch (e) {
      debugPrint('[AuthBloc] update profile error: $e');
      emit(const AuthError(message: 'Gagal memperbarui profil'));
    }
  }

  Future<void> _onChangePasswordRequested(
    AuthChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.changePassword(
        event.currentPassword,
        event.newPassword,
      );
      emit(const AuthActionSuccess(message: 'Password berhasil diubah'));
    } catch (e) {
      debugPrint('[AuthBloc] change password error: $e');
      final msg = e.toString().toLowerCase();
      if (msg.contains('old') || msg.contains('current')) {
        emit(const AuthError(message: 'Password saat ini salah'));
      } else {
        emit(const AuthError(message: 'Gagal mengubah password'));
      }
    }
  }
}
