import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class SignOutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class AuthenticateWithToken extends AuthEvent {
  final String token;

  const AuthenticateWithToken({
    required this.token,
  });

  @override
  List<Object?> get props => [token];
}
