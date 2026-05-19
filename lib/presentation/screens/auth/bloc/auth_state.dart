import 'package:equatable/equatable.dart';
import '../../../../domain/entities/user_profile.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserProfile profile;

  const AuthAuthenticated({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthActionSuccess extends AuthState {
  final String message;

  const AuthActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
