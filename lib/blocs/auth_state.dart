import 'package:equatable/equatable.dart';
import 'package:ourbit_pos/src/data/objects/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {
  final bool isCheckingAuth;
  
  const AuthLoading({this.isCheckingAuth = false});
  
  @override
  List<Object?> get props => [isCheckingAuth];
}

class Authenticated extends AuthState {
  final AppUser user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
