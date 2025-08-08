import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourbit_pos/src/core/services/local_storage_service.dart';
import 'appbar_event.dart';
import 'appbar_state.dart';

class AppBarBloc extends Bloc<AppBarEvent, AppBarState> {
  AppBarBloc() : super(AppBarInitial()) {
    on<LoadAppBarData>(_onLoadAppBarData);
    on<RefreshAppBarData>(_onRefreshAppBarData);
  }

  Future<void> _onLoadAppBarData(
    LoadAppBarData event,
    Emitter<AppBarState> emit,
  ) async {
    emit(AppBarLoading());
    try {
      // Load data from local storage
      final businessData = await LocalStorageService.getBusinessData();
      final storeData = await LocalStorageService.getStoreData();
      final roleData = await LocalStorageService.getRoleAssignmentData();
      final userData = await LocalStorageService.getUserData();

      // Set default values
      String businessName = 'Allnimall Pet Shop';
      String storeName = 'Toko';
      String userRole = 'User';
      String userName = 'User';

      // Update values from storage
      if (businessData != null && businessData['name'] != null) {
        businessName = businessData['name'];
      }

      if (storeData != null && storeData['name'] != null) {
        storeName = storeData['name'];
      }

      if (userData != null && userData['name'] != null) {
        userName = userData['name'];
      } else if (userData != null && userData['email'] != null) {
        // Fallback to email if name is not available
        final email = userData['email'] as String;
        userName = email.split('@')[0]; // Use email prefix as name
      }

      // Get role name from role assignment data
      if (roleData != null && roleData['role'] != null) {
        final role = roleData['role'] as Map<String, dynamic>;
        final roleName = role['name'] as String?;
        if (roleName != null && roleName.isNotEmpty) {
          userRole = roleName;
        }
      }

      emit(AppBarLoaded(
        storeName: storeName,
        businessName: businessName,
        userRole: userRole,
        userName: userName,
      ));
    } catch (e) {
      emit(AppBarError(e.toString()));
    }
  }

  Future<void> _onRefreshAppBarData(
    RefreshAppBarData event,
    Emitter<AppBarState> emit,
  ) async {
    add(LoadAppBarData());
  }
}
