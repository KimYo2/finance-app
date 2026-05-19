import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckStatus extends AuthEvent {
  const AuthCheckStatus();
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthGoogleLoginRequested extends AuthEvent {
  const AuthGoogleLoginRequested();
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthDeleteAccountRequested extends AuthEvent {
  const AuthDeleteAccountRequested();
}

class AuthUpdateProfileRequested extends AuthEvent {
  final String name;

  const AuthUpdateProfileRequested({required this.name});

  @override
  List<Object?> get props => [name];
}

class AuthChangePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const AuthChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}
