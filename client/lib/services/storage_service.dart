import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling secure storage across different platforms
class StorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  // Secure storage for mobile/desktop platforms
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    lOptions: LinuxOptions(),
    wOptions: WindowsOptions(),
    mOptions: MacOsOptions(),
  );

  /// Save access token
  static Future<void> saveAccessToken(String token) async {
    try {
      print('StorageService: Saving access token - length: ${token.length}');
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_accessTokenKey, token);
      } else {
        await _secureStorage.write(key: _accessTokenKey, value: token);
      }
      print('StorageService: Access token saved successfully');
    } catch (e) {
      print('StorageService: Error saving access token: $e');
      throw Exception('Failed to save access token: $e');
    }
  }

  /// Save refresh token
  static Future<void> saveRefreshToken(String token) async {
    try {
      print('StorageService: Saving refresh token - length: ${token.length}');
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_refreshTokenKey, token);
      } else {
        await _secureStorage.write(key: _refreshTokenKey, value: token);
      }
      print('StorageService: Refresh token saved successfully');
    } catch (e) {
      print('StorageService: Error saving refresh token: $e');
      throw Exception('Failed to save refresh token: $e');
    }
  }

  /// Save both tokens at once
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      print('StorageService: Saving tokens - access token length: ${accessToken.length}, refresh token length: ${refreshToken.length}');
      await Future.wait([
        saveAccessToken(accessToken),
        saveRefreshToken(refreshToken),
      ]);
      print('StorageService: Tokens saved successfully');
    } catch (e) {
      print('StorageService: Error saving tokens: $e');
      throw Exception('Failed to save authentication tokens: $e');
    }
  }

  /// Save user data as JSON string
  static Future<void> saveUserData(String userData) async {
    try {
      print('StorageService: Saving user data - length: ${userData.length}');
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userDataKey, userData);
      } else {
        await _secureStorage.write(key: _userDataKey, value: userData);
      }
      print('StorageService: User data saved successfully');
    } catch (e) {
      print('StorageService: Error saving user data: $e');
      throw Exception('Failed to save user data: $e');
    }
  }

  /// Get access token
  static Future<String?> getAccessToken() async {
    try {
      String? token;
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString(_accessTokenKey);
      } else {
        token = await _secureStorage.read(key: _accessTokenKey);
      }
      print('StorageService: Retrieved access token - ${token != null ? 'found (length: ${token.length})' : 'not found'}');
      return token;
    } catch (e) {
      print('StorageService: Error reading access token: $e');
      return null;
    }
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    try {
      String? token;
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString(_refreshTokenKey);
      } else {
        token = await _secureStorage.read(key: _refreshTokenKey);
      }
      print('StorageService: Retrieved refresh token - ${token != null ? 'found (length: ${token.length})' : 'not found'}');
      return token;
    } catch (e) {
      print('StorageService: Error reading refresh token: $e');
      return null;
    }
  }

  /// Get user data as JSON string
  static Future<String?> getUserData() async {
    try {
      String? userData;
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        userData = prefs.getString(_userDataKey);
      } else {
        userData = await _secureStorage.read(key: _userDataKey);
      }
      print('StorageService: Retrieved user data - ${userData != null ? 'found (length: ${userData.length})' : 'not found'}');
      return userData;
    } catch (e) {
      print('StorageService: Error reading user data: $e');
      return null;
    }
  }

  /// Clear all stored authentication data
  static Future<void> clearAuthData() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_accessTokenKey),
        prefs.remove(_refreshTokenKey),
        prefs.remove(_userDataKey),
      ]);
    } else {
      await Future.wait([
        _secureStorage.delete(key: _accessTokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
        _secureStorage.delete(key: _userDataKey),
      ]);
    }
  }

  /// Check if user has valid tokens stored
  static Future<bool> hasValidTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }

  /// Get platform information for debugging
  static String getPlatformInfo() {
    if (kIsWeb) {
      return 'Web (using SharedPreferences)';
    } else if (Platform.isAndroid) {
      return 'Android (using FlutterSecureStorage)';
    } else if (Platform.isIOS) {
      return 'iOS (using FlutterSecureStorage)';
    } else if (Platform.isWindows) {
      return 'Windows (using FlutterSecureStorage)';
    } else if (Platform.isMacOS) {
      return 'macOS (using FlutterSecureStorage)';
    } else if (Platform.isLinux) {
      return 'Linux (using FlutterSecureStorage)';
    } else {
      return 'Unknown platform';
    }
  }
}