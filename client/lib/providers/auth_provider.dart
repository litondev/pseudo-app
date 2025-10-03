import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';
import '../models/auth.dart';
import '../models/user.dart';
import '../services/auth/auth_service.dart';
import '../services/token_refresh_service.dart';
import '../cores/utils/snackbar_utils.dart';

/// Provider for managing authentication state throughout the app
class AuthProvider extends ChangeNotifier {
  // Private fields
  AuthState _authState = AuthState.loading;
  User? _currentUser;
  AuthError? _lastError;
  bool _isLoading = false;

  // Public getters
  AuthState get authState => _authState;
  User? get currentUser => _currentUser;
  AuthError? get lastError => _lastError;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _authState == AuthState.authenticated;
  bool get isUnauthenticated => _authState == AuthState.unauthenticated;

  /// Initialize authentication state
  Future<void> initialize() async {
    _setLoading(true);
    _clearError();

    try {
      final isAuth = await AuthService.isAuthenticated();
      if (isAuth) {
        final user = await AuthService.getCurrentUser();
        _setAuthenticatedState(user);
      } else {
        _setUnauthenticatedState();
      }
    } catch (e) {
      _setError(AuthService.handleAuthError(e));
      _setUnauthenticatedState();
    } finally {
      _setLoading(false);
    }
  }

  /// Register a new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    BuildContext? context,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final request = RegisterRequest(
        name: name,
        email: email,
        password: password,
      );

      final response = await AuthService.register(request);
      _setAuthenticatedState(response.user);
      
      // Start token refresh service after successful registration
      await TokenRefreshService.instance.restartService();
      
      // Show success message
      if (context != null && context.mounted) {
        SnackbarUtils.showSuccess(context, 'Account created successfully!');
      }
      
      return true;
    } catch (e) {
      final error = AuthService.handleAuthError(e);
      _setError(error);
      
      // Show error snackbar
      if (context != null && context.mounted) {
        SnackbarUtils.showApiError(context, error);
      }
      
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in user
  Future<bool> signIn({
    required String email,
    required String password,
    BuildContext? context,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final request = AuthRequest(
        email: email,
        password: password,
      );

      final response = await AuthService.signIn(request);
      _setAuthenticatedState(response.user);
      
      // Restart token refresh service after successful login
      await TokenRefreshService.instance.restartService();
      
      // Show success message
      if (context != null && context.mounted) {
        SnackbarUtils.showSuccess(context, 'Welcome back!');
      }
      
      return true;
    } catch (e) {
      final error = AuthService.handleAuthError(e);
      _setError(error);
      
      // Show error snackbar
      if (context != null && context.mounted) {
        SnackbarUtils.showApiError(context, error);
      }
      
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out user
  Future<void> signOut({BuildContext? context}) async {
    _setLoading(true);
    _clearError();

    try {
      await AuthService.signOut();
      _setUnauthenticatedState();
      
      // Stop token refresh service after sign out
      TokenRefreshService.instance.stopTokenRefreshService();
      
      // Show success message
      if (context != null && context.mounted) {
        SnackbarUtils.showSuccess(context, 'Signed out successfully');
      }
    } catch (e) {
      // Even if sign out fails on server, clear local state
      _setUnauthenticatedState();
      
      // Stop token refresh service even if sign out fails
      TokenRefreshService.instance.stopTokenRefreshService();
      
      final error = AuthService.handleAuthError(e);
      _setError(error);
      
      // Show error snackbar
      if (context != null && context.mounted) {
        SnackbarUtils.showApiError(context, error);
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    if (!isAuthenticated) return;

    _setLoading(true);
    _clearError();

    try {
      final user = await AuthService.getCurrentUser();
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      final error = AuthService.handleAuthError(e);
      if (error.type == AuthErrorType.tokenExpired) {
        // Token expired, try to refresh
        final refreshed = await _attemptTokenRefresh();
        if (!refreshed) {
          _setUnauthenticatedState();
        }
      } else {
        _setError(error);
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Attempt to refresh token
  Future<bool> _attemptTokenRefresh() async {
    try {
      await AuthService.refreshToken();
      // If refresh successful, try to get user again
      final user = await AuthService.getCurrentUser();
      _setAuthenticatedState(user);
      return true;
    } catch (e) {
      _setError(AuthService.handleAuthError(e));
      return false;
    }
  }

  /// Clear any authentication errors
  void clearError() {
    _clearError();
  }

  /// Check if current error is of specific type
  bool hasErrorType(AuthErrorType type) {
    return _lastError?.type == type;
  }

  /// Get user display name
  String get userDisplayName {
    if (_currentUser?.name?.isNotEmpty == true) {
      return _currentUser!.name!;
    }
    return _currentUser?.email ?? 'User';
  }

  /// Get user initials for avatar
  String get userInitials {
    final name = _currentUser?.name;
    if (name?.isNotEmpty == true) {
      final parts = name!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        return name[0].toUpperCase();
      }
    }
    final email = _currentUser?.email;
    return email?.isNotEmpty == true ? email![0].toUpperCase() : 'U';
  }

  /// Validate registration form
  Map<String, String?> validateRegistrationForm({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    final errors = <String, String?>{};

    // Name validation
    if (name.trim().isEmpty) {
      errors['name'] = 'Name is required';
    } else if (name.trim().length < 2) {
      errors['name'] = 'Name must be at least 2 characters';
    }

    // Email validation
    if (email.trim().isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!AuthService.isValidEmail(email)) {
      errors['email'] = 'Please enter a valid email address';
    }

    // Password validation
    if (password.isEmpty) {
      errors['password'] = 'Password is required';
    } else if (!AuthService.isValidPassword(password)) {
      errors['password'] = AuthService.getPasswordStrengthMessage();
    }

    // Confirm password validation
    if (confirmPassword.isEmpty) {
      errors['confirmPassword'] = 'Please confirm your password';
    } else if (password != confirmPassword) {
      errors['confirmPassword'] = 'Passwords do not match';
    }

    return errors;
  }

  /// Validate sign in form
  Map<String, String?> validateSignInForm({
    required String email,
    required String password,
  }) {
    final errors = <String, String?>{};

    // Email validation
    if (email.trim().isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!AuthService.isValidEmail(email)) {
      errors['email'] = 'Please enter a valid email address';
    }

    // Password validation
    if (password.isEmpty) {
      errors['password'] = 'Password is required';
    }

    return errors;
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setAuthenticatedState(User user) {
    _authState = AuthState.authenticated;
    _currentUser = user;
    _clearError();
    notifyListeners();
  }

  void _setUnauthenticatedState() {
    _authState = AuthState.unauthenticated;
    _currentUser = null;
    notifyListeners();
  }

  void _setError(AuthError error) {
    _lastError = error;
    notifyListeners();
  }

  void _clearError() {
    _lastError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}