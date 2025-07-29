import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ourbit_pos/src/core/services/local_storage_service.dart';

class BusinessStoreService {
  final SupabaseClient _supabaseClient;

  BusinessStoreService(this._supabaseClient);

  /// Get user's business and store data after successful login
  Future<Map<String, dynamic>> getUserBusinessAndStore() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get user's role assignments with business and store info
      final roleAssignmentsResponse =
          await _supabaseClient.from('role_assignments').select('''
            *,
            business:businesses(*),
            store:stores(*),
            role:roles(*)
          ''').eq('user_id', user.id);

      if (roleAssignmentsResponse.isEmpty) {
        throw Exception('No role assignments found for user');
      }

      // Get the first role assignment (assuming user has one primary assignment)
      final roleAssignment = roleAssignmentsResponse[0];

      // Extract business and store data
      final businessData = roleAssignment['business'] as Map<String, dynamic>;
      final storeData = roleAssignment['store'] as Map<String, dynamic>;
      final roleData = roleAssignment['role'] as Map<String, dynamic>;

      // Save to local storage
      await LocalStorageService.saveBusinessData(businessData);
      await LocalStorageService.saveStoreData(storeData);
      await LocalStorageService.saveRoleAssignmentData(roleAssignment);

      return {
        'business': businessData,
        'store': storeData,
        'role': roleData,
        'roleAssignment': roleAssignment,
      };
    } catch (e) {
      throw Exception('Failed to get user business and store data');
    }
  }

  /// Get current store ID from local storage
  Future<String?> getCurrentStoreId() async {
    return await LocalStorageService.getStoreId();
  }

  /// Get current business ID from local storage
  Future<String?> getCurrentBusinessId() async {
    final businessData = await LocalStorageService.getBusinessData();
    return businessData?['id'];
  }

  /// Check if user has valid business and store data
  Future<bool> hasValidBusinessAndStore() async {
    final storeId = await getCurrentStoreId();
    final businessId = await getCurrentBusinessId();
    return storeId != null && businessId != null;
  }

  /// Get all stores for current business
  Future<List<Map<String, dynamic>>> getBusinessStores() async {
    try {
      final businessId = await getCurrentBusinessId();
      if (businessId == null) {
        throw Exception('No business ID found');
      }

      final response = await _supabaseClient
          .from('stores')
          .select('*')
          .eq('business_id', businessId)
          .order('name', ascending: true);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to get business stores');
    }
  }

  /// Switch to different store
  Future<void> switchStore(String storeId) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get role assignment for this store
      final roleAssignmentResponse =
          await _supabaseClient.from('role_assignments').select('''
            *,
            business:businesses(*),
            store:stores(*),
            role:roles(*)
          ''').eq('user_id', user.id).eq('store_id', storeId).single();

      // Save new store data
      await LocalStorageService.saveStoreData(roleAssignmentResponse['store']);
      await LocalStorageService.saveRoleAssignmentData(roleAssignmentResponse);
    } catch (e) {
      throw Exception('Failed to switch store');
    }
  }
}
