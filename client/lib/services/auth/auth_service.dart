import 'dart:convert';
import '../../models/auth.dart';
import '../../models/user.dart';
import '../api_service.dart';
import '../storage_service.dart';

/// Service for handling authentication operations
class AuthService {
  static const String _authEndpoint = '/auth';

  /// Register a new user
  static Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await ApiService.post<AuthResponse>(
        '$_authEndpoint/signup',
        request.toJson(),
        fromJsonT: (json) => AuthResponse.fromJson(json),
      );

      if (response.isSuccess && response.data != null) {
        // Save tokens and user data
        await _saveAuthData(response.data!);
        return response.data!;
      } else {
        throw AuthError(
          type: AuthErrorType.registrationFailed,
          message: response.error ?? 'Registration failed',
          validationErrors: response.errors,
        );
      }
    } catch (e) {
      if (e is AuthError) rethrow;
      throw AuthError(
        type: AuthErrorType.networkError,
        message: 'Network error during registration: $e',
      );
    }
  }

  /// Sign in user
  static Future<AuthResponse> signIn(AuthRequest request) async {
    try {
      final response = await ApiService.post<AuthResponse>(
        '$_authEndpoint/signin',
        request.toJson(),
        fromJsonT: (json) => AuthResponse.fromJson(json),
      );

      if (response.isSuccess && response.data != null) {
        // Save tokens and user data
        await _saveAuthData(response.data!);
        return response.data!;
      } else {
        throw AuthError(
          type: AuthErrorType.invalidCredentials,
          message: response.error ?? 'Sign in failed',
          validationErrors: response.errors,
        );
      }
    } catch (e) {
      if (e is AuthError) rethrow;
      throw AuthError(
        type: AuthErrorType.networkError,
        message: 'Network error during sign in: $e',
      );
    }
  }

  /// Get current user information
  static Future<User> getCurrentUser() async {
    try {
      // First try to get user from local storage
      final userData = await StorageService.getUserData();
      if (userData != null) {
        try {
          final userJson = json.decode(userData);
          return User.fromJson(userJson);
        } catch (e) {
          // If local data is corrupted, fetch from server
        }
      }

      // Fetch from server
      final response = await ApiService.get<User>(
        '$_authEndpoint/me',
        requireAuth: true,
        fromJsonT: (json) => User.fromJson(json),
      );

      if (response.isSuccess && response.data != null) {
        // Update local storage
        await StorageService.saveUserData(json.encode(response.data!.toJson()));
        return response.data!;
      } else {
        if (ApiService.isTokenExpired(response)) {
          throw AuthError(
            type: AuthErrorType.tokenExpired,
            message: 'Session expired',
          );
        }
        throw AuthError(
          type: AuthErrorType.unauthorized,
          message: response.error ?? 'Failed to get user information',
        );
      }
    } catch (e) {
      if (e is AuthError) rethrow;
      throw AuthError(
        type: AuthErrorType.networkError,
        message: 'Network error while fetching user: $e',
      );
    }
  }

  /// Refresh authentication token
  static Future<TokenResponse> refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) {
        throw AuthError(
          type: AuthErrorType.tokenExpired,
          message: 'No refresh token available',
        );
      }

      final request = RefreshTokenRequest(refreshToken: refreshToken);
      final response = await ApiService.post<TokenResponse>(
        '$_authEndpoint/refresh-token',
        request.toJson(),
        fromJsonT: (json) => TokenResponse.fromJson(json),
      );

      if (response.isSuccess && response.data != null) {
        // Save new tokens
        await StorageService.saveTokens(
          accessToken: response.data!.accessToken,
          refreshToken: response.data!.refreshToken,
        );
        return response.data!;
      } else {
        throw AuthError(
          type: AuthErrorType.tokenExpired,
          message: response.error ?? 'Failed to refresh token',
        );
      }
    } catch (e) {
      if (e is AuthError) rethrow;
      throw AuthError(
        type: AuthErrorType.networkError,
        message: 'Network error during token refresh: $e',
      );
    }
  }

  /// Sign out user
  static Future<void> signOut() async {
    try {
      // Try to call logout endpoint
      final response = await ApiService.post(
        '$_authEndpoint/logout',
        {},
        requireAuth: true,
      );

      // Clear local storage regardless of API response
      await StorageService.clearAuthData();

      // If API call failed, still consider logout successful locally
      if (!response.isSuccess) {
        // Log the error but don't throw - user is logged out locally
        print('Logout API call failed: ${response.error}');
      }
    } catch (e) {
      // Clear local storage even if network request fails
      await StorageService.clearAuthData();
      print('Network error during logout: $e');
    }
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    try {
      final hasTokens = await StorageService.hasValidTokens();
      if (!hasTokens) return false;

      // Try to get current user to validate token
      await getCurrentUser();
      return true;
    } catch (e) {
      if (e is AuthError && e.type == AuthErrorType.tokenExpired) {
        // Try to refresh token
        try {
          await refreshToken();
          return true;
        } catch (refreshError) {
          // Refresh failed, user needs to sign in again
          await StorageService.clearAuthData();
          return false;
        }
      }
      return false;
    }
  }

  /// Get current authentication state
  static Future<AuthState> getAuthState() async {
    try {
      final isAuth = await isAuthenticated();
      return isAuth ? AuthState.authenticated : AuthState.unauthenticated;
    } catch (e) {
      return AuthState.unauthenticated;
    }
  }

  /// Save authentication data to storage
  static Future<void> _saveAuthData(AuthResponse authResponse) async {
    await Future.wait([
      StorageService.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      ),
      StorageService.saveUserData(json.encode(authResponse.user.toJson())),
    ]);
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  /// Validate password strength
  static bool isValidPassword(String password) {
    // At least 8 characters, contains uppercase, lowercase, and number
    return password.length >= 8 &&
           RegExp(r'[A-Z]').hasMatch(password) &&
           RegExp(r'[a-z]').hasMatch(password) &&
           RegExp(r'[0-9]').hasMatch(password);
  }

  /// Get password strength description
  static String getPasswordStrengthMessage() {
    return 'Password must be at least 8 characters long and contain uppercase, lowercase, and numeric characters.';
  }

  /// Handle authentication errors consistently
  static AuthError handleAuthError(dynamic error) {
    if (error is AuthError) return error;
    
    return AuthError(
      type: AuthErrorType.unknown,
      message: error.toString(),
    );
  }
}