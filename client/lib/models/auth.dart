import 'user.dart';

/// Request model for user login
class AuthRequest {
  final String email;
  final String password;

  AuthRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  @override
  String toString() {
    return 'AuthRequest{email: $email}';
  }
}

/// Request model for user registration
class RegisterRequest {
  final String name;
  final String email;
  final String password;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
    };
  }

  @override
  String toString() {
    return 'RegisterRequest{name: $name, email: $email}';
  }
}

/// Request model for token refresh
class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'refresh_token': refreshToken,
    };
  }

  @override
  String toString() {
    return 'RefreshTokenRequest{refreshToken: ${refreshToken.substring(0, 10)}...}';
  }
}

/// Response model for authentication operations
class AuthResponse {
  final User user;
  final String accessToken;
  final String refreshToken;

  AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user']),
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }

  @override
  String toString() {
    return 'AuthResponse{user: $user, accessToken: ${accessToken.substring(0, 10)}..., refreshToken: ${refreshToken.substring(0, 10)}...}';
  }
}

/// Response model for token refresh operations
class TokenResponse {
  final String accessToken;
  final String refreshToken;

  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }

  @override
  String toString() {
    return 'TokenResponse{accessToken: ${accessToken.substring(0, 10)}..., refreshToken: ${refreshToken.substring(0, 10)}...}';
  }
}

/// Standard API response wrapper
class ApiResponse<T> {
  final String message;
  final T? data;
  final String? error;
  final List<ValidationError>? errors;

  ApiResponse({
    required this.message,
    this.data,
    this.error,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      message: json['message'],
      data: json['data'] != null && fromJsonT != null 
          ? fromJsonT(json['data']) 
          : json['data'],
      error: json['error'],
      errors: json['errors'] != null
          ? (json['errors'] as List)
              .map((e) => ValidationError.fromJson(e))
              .toList()
          : null,
    );
  }

  bool get isSuccess => message == 'success';
  bool get isFailure => message == 'failed';

  @override
  String toString() {
    return 'ApiResponse{message: $message, data: $data, error: $error, errors: $errors}';
  }
}

/// Validation error model
class ValidationError {
  final String field;
  final String message;

  ValidationError({
    required this.field,
    required this.message,
  });

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      field: json['field'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'message': message,
    };
  }

  @override
  String toString() {
    return 'ValidationError{field: $field, message: $message}';
  }
}

/// Authentication state enum
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Authentication error types
enum AuthErrorType {
  invalidCredentials,
  networkError,
  serverError,
  validationError,
  tokenExpired,
  registrationFailed,
  unauthorized,
  unknown,
}

/// Authentication error model
class AuthError {
  final AuthErrorType type;
  final String message;
  final List<ValidationError>? validationErrors;

  AuthError({
    required this.type,
    required this.message,
    this.validationErrors,
  });

  factory AuthError.fromApiResponse(ApiResponse response) {
    if (response.errors != null && response.errors!.isNotEmpty) {
      return AuthError(
        type: AuthErrorType.validationError,
        message: response.error ?? 'Validation failed',
        validationErrors: response.errors,
      );
    }

    final errorMessage = response.error ?? 'Unknown error occurred';
    AuthErrorType errorType = AuthErrorType.unknown;

    if (errorMessage.toLowerCase().contains('credential')) {
      errorType = AuthErrorType.invalidCredentials;
    } else if (errorMessage.toLowerCase().contains('network')) {
      errorType = AuthErrorType.networkError;
    } else if (errorMessage.toLowerCase().contains('server')) {
      errorType = AuthErrorType.serverError;
    } else if (errorMessage.toLowerCase().contains('token')) {
      errorType = AuthErrorType.tokenExpired;
    }

    return AuthError(
      type: errorType,
      message: errorMessage,
    );
  }

  @override
  String toString() {
    return 'AuthError{type: $type, message: $message, validationErrors: $validationErrors}';
  }
}