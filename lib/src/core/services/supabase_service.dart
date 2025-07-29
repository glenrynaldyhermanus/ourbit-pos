import 'package:supabase_flutter/supabase_flutter.dart';
import 'local_storage_service.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  // Products
  static Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await client
          .from('products')
          .select('*, categories(name)')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // TODO: gunakan logger jika perlu
      return [];
    }
  }

  // Store Cart
  static Future<List<Map<String, dynamic>>> getStoreCart(String storeId) async {
    try {
      final response = await client
          .from('store_carts')
          .select('*, products(*)')
          .eq('store_id', storeId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // TODO: gunakan logger jika perlu
      return [];
    }
  }

  static Future<void> addToCart(
      String storeId, String productId, int quantity) async {
    try {
      // Check if product already in cart
      final existingCart = await client
          .from('store_carts')
          .select()
          .eq('store_id', storeId)
          .eq('product_id', productId)
          .single();

      // Update quantity
      await client
          .from('store_carts')
          .update({'quantity': existingCart['quantity'] + quantity})
          .eq('store_id', storeId)
          .eq('product_id', productId);
    } catch (e) {
      // TODO: gunakan logger jika perlu
      throw Exception('Failed to add to cart');
    }
  }

  static Future<void> updateCartQuantity(
      String storeId, String productId, int quantity) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(storeId, productId);
      } else {
        await client
            .from('store_carts')
            .update({'quantity': quantity})
            .eq('store_id', storeId)
            .eq('product_id', productId);
      }
    } catch (e) {
      // TODO: gunakan logger jika perlu
      throw Exception('Failed to update cart quantity');
    }
  }

  static Future<void> removeFromCart(String storeId, String productId) async {
    try {
      await client
          .from('store_carts')
          .delete()
          .eq('store_id', storeId)
          .eq('product_id', productId);
    } catch (e) {
      // TODO: gunakan logger jika perlu
      throw Exception('Failed to remove from cart');
    }
  }

  static Future<void> clearCart(String storeId) async {
    try {
      await client.from('store_carts').delete().eq('store_id', storeId);
    } catch (e) {
      // TODO: gunakan logger jika perlu
      throw Exception('Failed to clear cart');
    }
  }

  // User Profile
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) return null;
      return {
        'id': user.id,
        'email': user.email,
        'name': user.userMetadata?['name'],
        'avatar': user.userMetadata?['avatar'],
      };
    } catch (e) {
      // TODO: gunakan logger jika perlu
      return null;
    }
  }

  // Get user's store ID from local storage first, then from database if needed
  static Future<String?> getStoreId() async {
    // Try to get from local storage first (more efficient)
    final storeId = await LocalStorageService.getStoreId();
    if (storeId != null) {
      return storeId;
    }

    // If not in local storage, get from database and cache it
    try {
      final user = client.auth.currentUser;
      if (user == null) return null;

      final response = await client
          .from('role_assignments')
          .select('store_id')
          .eq('user_id', user.id)
          .limit(1)
          .single();

      final storeIdFromDb = response['store_id'];

      // Cache the store ID for future use
      if (storeIdFromDb != null) {
        await LocalStorageService.saveRoleAssignmentData(
            {'store_id': storeIdFromDb});
      }

      return storeIdFromDb;
    } catch (e) {
      // TODO: gunakan logger jika perlu
      return null;
    }
  }

  // Load and cache user data after successful login
  static Future<void> loadUserDataAfterLogin() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) {
        print('No current user found');
        return;
      }

      // Get user data
      final userData = {
        'id': user.id,
        'email': user.email,
        'name': user.userMetadata?['name'],
        'avatar': user.userMetadata?['avatar'],
      };
      await LocalStorageService.saveUserData(userData);
      print('User data saved to local storage');

      // Get role assignment data
      final roleResponse = await client
          .from('role_assignments')
          .select('*, businesses(*), stores(*)')
          .eq('user_id', user.id)
          .limit(1)
          .single();

      await LocalStorageService.saveRoleAssignmentData(roleResponse);
      print('Role assignment data saved to local storage');

      // Save business data
      final businessData = roleResponse['businesses'];
      if (businessData != null) {
        await LocalStorageService.saveBusinessData(businessData);
        print('Business data saved to local storage');
      }

      // Save store data
      final storeData = roleResponse['stores'];
      if (storeData != null) {
        await LocalStorageService.saveStoreData(storeData);
        print('Store data saved to local storage');
      }
    } catch (e) {
      print('Error in loadUserDataAfterLogin: $e');
      // Don't throw exception here to avoid breaking the login flow
    }
  }

  // Set session token for external authentication
  static Future<void> setSessionToken(String token) async {
    try {
      // Decode the JWT token to extract user information
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid JWT token format');
      }

      // Method 1: Try using refreshSession with a dummy refresh token
      // This is a workaround since we only have access token
      try {
        await client.auth.refreshSession(token);
        print('Session token set successfully via refreshSession');
        return;
      } catch (e) {
        print('refreshSession failed: $e');
      }

      // Method 2: Try setSession with access_token format
      try {
        // Format as session object
        await client.auth.setSession(token);
        print('Session token set successfully via setSession');
        return;
      } catch (e) {
        print('setSession failed: $e');
      }

      // Method 3: Get user info and manually trigger auth state change
      final response = await client.auth.getUser(token);

      if (response.user != null) {
        print('Session token set successfully via getUser');
        print('Current user after getUser: ${response.user!.email}');
      } else {
        throw Exception('Invalid token - no user found');
      }
    } catch (e) {
      print('Error setting session token: $e');
      throw Exception('Failed to set session token: ${e.toString()}');
    }
  }

  // Check if user is authenticated
  static Future<bool> isUserAuthenticated() async {
    try {
      final user = client.auth.currentUser;
      return user != null;
    } catch (e) {
      print('Error checking user authentication: $e');
      return false;
    }
  }
}
