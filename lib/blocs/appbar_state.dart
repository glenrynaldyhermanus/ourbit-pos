import 'package:equatable/equatable.dart';

abstract class AppBarState extends Equatable {
  const AppBarState();

  @override
  List<Object?> get props => [];
}

class AppBarInitial extends AppBarState {}

class AppBarLoading extends AppBarState {}

class AppBarLoaded extends AppBarState {
  final String storeName;
  final String businessName;
  final String userRole;
  final String userName;

  const AppBarLoaded({
    required this.storeName,
    required this.businessName,
    required this.userRole,
    required this.userName,
  });

  @override
  List<Object?> get props => [storeName, businessName, userRole, userName];
}

class AppBarError extends AppBarState {
  final String message;

  const AppBarError(this.message);

  @override
  List<Object?> get props => [message];
}
