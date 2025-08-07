import 'package:equatable/equatable.dart';

abstract class AppBarEvent extends Equatable {
  const AppBarEvent();

  @override
  List<Object?> get props => [];
}

class LoadAppBarData extends AppBarEvent {}

class RefreshAppBarData extends AppBarEvent {}
