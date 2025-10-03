import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'auth/auth_service.dart';
import 'storage_service.dart';

/// Service for automatic token refresh management
class TokenRefreshService {
  static TokenRefreshService? _instance;
  static TokenRefreshService get instance => _instance ??= TokenRefreshService._();
  
  TokenRefreshService._();

  Timer? _refreshTimer;
  bool _isRefreshing = false;
  bool _isServiceActive = false;

  /// Duration for token refresh interval (30 minutes)
  static const Duration refreshInterval = Duration(minutes: 30);
  
  /// Duration before token expiry to trigger refresh (5 minutes buffer)
  static const Duration refreshBuffer = Duration(minutes: 5);

  /// Start automatic token refresh service
  Future<void> startTokenRefreshService() async {
    if (_isServiceActive) {
      developer.log('Token refresh service is already active');
      return;
    }

    try {
      // Check if user is authenticated
      final hasTokens = await StorageService.hasValidTokens();
      if (!hasTokens) {
        developer.log('No valid tokens found, skipping token refresh service');
        return;
      }

      _isServiceActive = true;
      developer.log('Starting token refresh service with ${refreshInterval.inMinutes} minute intervals');

      // Start periodic refresh
      _refreshTimer = Timer.periodic(refreshInterval, (timer) async {
        await _performTokenRefresh();
      });

      // Perform initial refresh check
      await _performTokenRefresh();

    } catch (e) {
      developer.log('Error starting token refresh service: $e');
      _isServiceActive = false;
    }
  }

  /// Stop automatic token refresh service
  void stopTokenRefreshService() {
    if (_refreshTimer != null) {
      _refreshTimer!.cancel();
      _refreshTimer = null;
    }
    _isServiceActive = false;
    _isRefreshing = false;
    developer.log('Token refresh service stopped');
  }

  /// Perform token refresh operation
  Future<void> _performTokenRefresh() async {
    if (_isRefreshing) {
      developer.log('Token refresh already in progress, skipping');
      return;
    }

    try {
      _isRefreshing = true;
      developer.log('Performing automatic token refresh');

      // Check if tokens still exist
      final hasTokens = await StorageService.hasValidTokens();
      if (!hasTokens) {
        developer.log('No valid tokens found, stopping refresh service');
        stopTokenRefreshService();
        return;
      }

      // Attempt to refresh token
      final tokenResponse = await AuthService.refreshToken();
      
      if (tokenResponse.accessToken.isNotEmpty && tokenResponse.refreshToken.isNotEmpty) {
        developer.log('Token refresh successful');
        
        // Notify listeners about successful refresh if needed
        _notifyTokenRefreshSuccess();
      } else {
        developer.log('Token refresh returned empty tokens');
        await _handleRefreshFailure();
      }

    } catch (e) {
      developer.log('Token refresh failed: $e');
      await _handleRefreshFailure();
    } finally {
      _isRefreshing = false;
    }
  }

  /// Handle token refresh failure
  Future<void> _handleRefreshFailure() async {
    developer.log('Handling token refresh failure');
    
    // Clear stored tokens
    await StorageService.clearAuthData();
    
    // Stop the refresh service
    stopTokenRefreshService();
    
    // Notify listeners about authentication failure
    _notifyAuthenticationFailure();
  }

  /// Manual token refresh (can be called from UI)
  Future<bool> refreshTokenManually() async {
    try {
      developer.log('Manual token refresh requested');
      await _performTokenRefresh();
      return await StorageService.hasValidTokens();
    } catch (e) {
      developer.log('Manual token refresh failed: $e');
      return false;
    }
  }

  /// Check if service is currently active
  bool get isServiceActive => _isServiceActive;

  /// Check if refresh is currently in progress
  bool get isRefreshing => _isRefreshing;

  /// Get time until next refresh
  Duration? get timeUntilNextRefresh {
    if (_refreshTimer == null || !_isServiceActive) return null;
    
    // This is an approximation since Timer.periodic doesn't provide exact timing
    return refreshInterval;
  }

  /// Restart the service (useful after login)
  Future<void> restartService() async {
    developer.log('Restarting token refresh service');
    stopTokenRefreshService();
    await Future.delayed(const Duration(milliseconds: 100));
    await startTokenRefreshService();
  }

  /// Initialize service on app startup
  static Future<void> initialize() async {
    try {
      developer.log('Initializing token refresh service');
      await instance.startTokenRefreshService();
    } catch (e) {
      developer.log('Failed to initialize token refresh service: $e');
    }
  }

  /// Cleanup service on app termination
  static void dispose() {
    instance.stopTokenRefreshService();
    _instance = null;
  }

  /// Notify about successful token refresh
  void _notifyTokenRefreshSuccess() {
    // You can implement a stream controller or callback here
    // to notify other parts of the app about successful refresh
    if (kDebugMode) {
      developer.log('Token refreshed successfully at ${DateTime.now()}');
    }
  }

  /// Notify about authentication failure
  void _notifyAuthenticationFailure() {
    // You can implement a stream controller or callback here
    // to notify other parts of the app about authentication failure
    // This could trigger a redirect to login screen
    if (kDebugMode) {
      developer.log('Authentication failed, user needs to login again');
    }
  }

  /// Get service status information
  Map<String, dynamic> getServiceStatus() {
    return {
      'isActive': _isServiceActive,
      'isRefreshing': _isRefreshing,
      'refreshInterval': '${refreshInterval.inMinutes} minutes',
      'hasTimer': _refreshTimer != null,
      'lastRefreshAttempt': DateTime.now().toIso8601String(),
    };
  }

  /// Force refresh if token is close to expiry
  Future<void> refreshIfNeeded() async {
    try {
      // This method can be enhanced to check actual token expiry time
      // For now, it performs refresh if service is active
      if (_isServiceActive && !_isRefreshing) {
        await _performTokenRefresh();
      }
    } catch (e) {
      developer.log('Error in refreshIfNeeded: $e');
    }
  }
}