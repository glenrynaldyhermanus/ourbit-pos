import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ourbit_pos/src/core/services/local_storage_service.dart';
import 'package:ourbit_pos/src/core/services/token_service.dart';
import 'package:ourbit_pos/src/core/utils/logger.dart';

class BusinessStoreService {
  final SupabaseClient _supabaseClient;

  BusinessStoreService(this._supabaseClient);

  /// Get user's business and store data after successful login
  Future<Map<String, dynamic>> getUserBusinessAndStore() async {
    try {
      Logger.business('Starting getUserBusinessAndStore');

      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Ensure token is saved during this process
      final session = _supabaseClient.auth.currentSession;
      if (session != null && session.accessToken.isNotEmpty) {
        Logger.business('Ensuring token is saved');
        await TokenService.saveToken(
            session.accessToken,
            session.expiresAt != null
                ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
                : DateTime.now().add(const Duration(hours: 1)));
        Logger.business('Token saved successfully');
      }

      // Get user's role assignments
      final roleAssignmentsResponse = await _supabaseClient
          .from('role_assignments')
          .select('*')
          .eq('user_id', user.id);

      // Check if user has role assignments
      if (roleAssignmentsResponse.isEmpty) {
        throw Exception('Kamu tidak memiliki akses ke aplikasi POS');
      }

      // Get the first role assignment (assuming user has one primary assignment)
      final roleAssignment = roleAssignmentsResponse[0];

      // Get business data
      final businessResponse = await _supabaseClient
          .from('businesses')
          .select('*')
          .eq('id', roleAssignment['business_id'])
          .single();

      // Get store data
      final storeResponse = await _supabaseClient
          .from('stores')
          .select('*')
          .eq('id', roleAssignment['store_id'])
          .single();

      // Get role data
      final roleResponse = await _supabaseClient
          .from('roles')
          .select('*')
          .eq('id', roleAssignment['role_id'])
          .single();

      // Validate business exists and is not deleted
      if (businessResponse['deleted_at'] != null) {
        throw Exception('Bisnis tidak aktif atau tidak ditemukan');
      }

      // Validate store exists and is not deleted
      if (storeResponse['deleted_at'] != null) {
        throw Exception('Store tidak aktif atau tidak ditemukan');
      }

      // Save user data
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser != null) {
        final userData = {
          'id': currentUser.id,
          'email': currentUser.email,
          'name': currentUser.userMetadata?['display_name'] ??
              currentUser.email?.split('@')[0] ??
              'User',
          'avatar': currentUser.userMetadata?['avatar'],
        };
        Logger.business('Saving user data: ${userData['name']}');
        await LocalStorageService.saveUserData(userData);
      }

      // Save to local storage
      Logger.business('Saving business data: ${businessResponse['id']}');
      await LocalStorageService.saveBusinessData(businessResponse);

      Logger.business('Saving store data: ${storeResponse['id']}');
      await LocalStorageService.saveStoreData(storeResponse);

      // Create complete role assignment data with all related data
      final completeRoleAssignment = {
        ...roleAssignment,
        'businesses': businessResponse,
        'stores': storeResponse,
        'roles': roleResponse,
      };
      Logger.business(
          'Saving role assignment data with store_id: ${completeRoleAssignment['store_id']}');
      await LocalStorageService.saveRoleAssignmentData(completeRoleAssignment);

      // Debug: Check all stored data
      await LocalStorageService.debugStoredData();

      Logger.business('All data loaded and saved successfully');

      return {
        'business': businessResponse,
        'store': storeResponse,
        'role': roleResponse,
        'roleAssignment': roleAssignment,
      };
    } catch (e) {
      Logger.error('Error: $e');
      throw Exception(e.toString());
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
      await LocalStorageService.saveBusinessData(
          roleAssignmentResponse['business']);
      await LocalStorageService.saveRoleAssignmentData(roleAssignmentResponse);
    } catch (e) {
      throw Exception('Failed to switch store');
    }
  }
}
