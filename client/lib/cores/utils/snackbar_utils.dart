import 'package:flutter/material.dart';
import '../../models/auth.dart';

/// Utility class for displaying consistent snackbars throughout the app
class SnackbarUtils {
  /// Show error snackbar with red background
  static void showError(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show success snackbar with green background
  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show warning snackbar with orange background
  static void showWarning(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.warning_outlined,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show info snackbar with blue background
  static void showInfo(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show API error snackbar with detailed error handling
  static void showApiError(BuildContext context, AuthError error) {
    if (!context.mounted) return;
    
    String message = _getErrorMessage(error);
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getErrorTitle(error.type),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
            // Show validation errors if available
            if (error.validationErrors != null && error.validationErrors!.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...error.validationErrors!.map((validationError) => Padding(
                padding: const EdgeInsets.only(left: 32, top: 2),
                child: Text(
                  '• ${validationError.field}: ${validationError.message}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              )),
            ],
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Get user-friendly error title based on error type
  static String _getErrorTitle(AuthErrorType type) {
    switch (type) {
      case AuthErrorType.invalidCredentials:
        return 'Invalid Credentials';
      case AuthErrorType.registrationFailed:
        return 'Registration Failed';
      case AuthErrorType.networkError:
        return 'Network Error';
      case AuthErrorType.tokenExpired:
        return 'Session Expired';
      case AuthErrorType.unauthorized:
        return 'Unauthorized Access';
      case AuthErrorType.validationError:
        return 'Validation Error';
      case AuthErrorType.serverError:
        return 'Server Error';
      case AuthErrorType.unknown:
      default:
        return 'Error Occurred';
    }
  }

  /// Get user-friendly error message
  static String _getErrorMessage(AuthError error) {
    if (error.message.isNotEmpty) {
      return error.message;
    }

    switch (error.type) {
      case AuthErrorType.invalidCredentials:
        return 'Please check your email and password';
      case AuthErrorType.registrationFailed:
        return 'Unable to create account. Please try again';
      case AuthErrorType.networkError:
        return 'Please check your internet connection';
      case AuthErrorType.tokenExpired:
        return 'Please sign in again';
      case AuthErrorType.unauthorized:
        return 'You are not authorized to perform this action';
      case AuthErrorType.validationError:
        return 'Please check your input and try again';
      case AuthErrorType.serverError:
        return 'Server is temporarily unavailable';
      case AuthErrorType.unknown:
      default:
        return 'Something went wrong. Please try again';
    }
  }

  /// Show generic API error from ApiResponse
  static void showGenericApiError(BuildContext context, String? errorMessage) {
    if (!context.mounted) return;
    
    final message = errorMessage ?? 'An error occurred. Please try again.';
    showError(context, message);
  }
}