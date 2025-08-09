import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ourbit_pos/src/core/utils/logger.dart';

class LocalStorageService {
  static const String _userKey = 'user_data';
  static const String _businessKey = 'business_data';
  static const String _storeKey = 'store_data';
  static const String _roleAssignmentKey = 'role_assignment_data';
  static const String _themeKey = 'theme_preference';

  // Theme preference
  static Future<void> saveThemePreference(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }

  static Future<bool?> getThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey);
  }

  static Future<void> clearThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeKey);
  }

  // User data
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString != null) {
      return jsonDecode(userString) as Map<String, dynamic>;
    }
    return null;
  }

  // Business data
  static Future<void> saveBusinessData(
      Map<String, dynamic> businessData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_businessKey, jsonEncode(businessData));
  }

  static Future<Map<String, dynamic>?> getBusinessData() async {
    final prefs = await SharedPreferences.getInstance();
    final businessString = prefs.getString(_businessKey);
    if (businessString != null) {
      return jsonDecode(businessString) as Map<String, dynamic>;
    }
    return null;
  }

  // Store data
  static Future<void> saveStoreData(Map<String, dynamic> storeData) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(storeData);
    Logger.debug('LocalStorageService - Saving store data: $jsonString');
    await prefs.setString(_storeKey, jsonString);
    Logger.debug('LocalStorageService - Store data saved successfully');
  }

  static Future<Map<String, dynamic>?> getStoreData() async {
    final prefs = await SharedPreferences.getInstance();
    final storeString = prefs.getString(_storeKey);
    if (storeString != null) {
      return jsonDecode(storeString) as Map<String, dynamic>;
    }
    return null;
  }

  // Role assignment data
  static Future<void> saveRoleAssignmentData(
      Map<String, dynamic> roleData) async {
    final prefs = await SharedPreferences.getInstance();

    // Debug: Check what keys exist in roleData
    Logger.debug('Role data keys: ${roleData.keys.toList()}');
    Logger.debug('Role data contains roles: ${roleData.containsKey('roles')}');
    Logger.debug(
        'Role data contains businesses: ${roleData.containsKey('businesses')}');
    Logger.debug(
        'Role data contains stores: ${roleData.containsKey('stores')}');
    Logger.debug(
        'Role data contains store_id: ${roleData.containsKey('store_id')}');
    Logger.debug('Role data store_id value: ${roleData['store_id']}');

    final jsonString = jsonEncode(roleData);
    Logger.debug('Saving role data to local storage: $jsonString');
    await prefs.setString(_roleAssignmentKey, jsonString);
    Logger.debug('Role assignment data saved successfully');
  }

  static Future<Map<String, dynamic>?> getRoleAssignmentData() async {
    final prefs = await SharedPreferences.getInstance();
    final roleString = prefs.getString(_roleAssignmentKey);
    if (roleString != null) {
      Logger.debug('Loading role data from local storage: $roleString');
      return jsonDecode(roleString) as Map<String, dynamic>;
    }
    return null;
  }

  // Get store ID from local storage
  static Future<String?> getStoreId() async {
    final roleData = await getRoleAssignmentData();
    Logger.debug('getStoreId - roleData: $roleData');
    final storeId = roleData?['store_id'];
    Logger.debug('getStoreId - storeId: $storeId');

    // Also check store data directly
    final storeData = await getStoreData();
    Logger.debug('getStoreId - storeData: $storeData');

    return storeId;
  }

  // Clear all data (for logout)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_businessKey);
    await prefs.remove(_storeKey);
    await prefs.remove(_roleAssignmentKey);
    await prefs.remove(_themeKey);
  }

  // Debug method to check all stored data
  static Future<void> debugStoredData() async {
    Logger.debug('=== DEBUG: Checking all stored data ===');

    final userData = await getUserData();
    Logger.debug('Stored user data: $userData');

    final businessData = await getBusinessData();
    Logger.debug('Stored business data: $businessData');

    final storeData = await getStoreData();
    Logger.debug('Stored store data: $storeData');

    final roleData = await getRoleAssignmentData();
    Logger.debug('Stored role assignment data: $roleData');

    final storeId = await getStoreId();
    Logger.debug('Retrieved store ID: $storeId');

    Logger.debug('=== END DEBUG ===');
  }
}
