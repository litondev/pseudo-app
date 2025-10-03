import 'package:flutter_test/flutter_test.dart';
import 'package:client/models/auth.dart';
import 'package:client/models/user.dart';

void main() {
  group('AuthRequest', () {
     test('should create AuthRequest with required fields', () {
       final authRequest = AuthRequest(
         email: 'test@example.com',
         password: 'password123',
       );

       expect(authRequest.email, 'test@example.com');
       expect(authRequest.password, 'password123');
     });

     test('should convert AuthRequest to JSON', () {
       final authRequest = AuthRequest(
         email: 'test@example.com',
         password: 'password123',
       );

       final json = authRequest.toJson();

       expect(json['email'], 'test@example.com');
       expect(json['password'], 'password123');
     });

     test('should have proper toString representation', () {
       final authRequest = AuthRequest(
         email: 'test@example.com',
         password: 'password123',
       );

       final stringRepresentation = authRequest.toString();

       expect(stringRepresentation, contains('test@example.com'));
       expect(stringRepresentation, isNot(contains('password123'))); // Password should not be in toString
     });
   });

   group('RegisterRequest', () {
     test('should create RegisterRequest with required fields', () {
       final registerRequest = RegisterRequest(
         name: 'John Doe',
         email: 'john@example.com',
         password: 'password123',
       );

       expect(registerRequest.name, 'John Doe');
       expect(registerRequest.email, 'john@example.com');
       expect(registerRequest.password, 'password123');
     });

     test('should convert RegisterRequest to JSON', () {
       final registerRequest = RegisterRequest(
         name: 'John Doe',
         email: 'john@example.com',
         password: 'password123',
       );

       final json = registerRequest.toJson();

       expect(json['name'], 'John Doe');
       expect(json['email'], 'john@example.com');
       expect(json['password'], 'password123');
     });

     test('should have proper toString representation', () {
       final registerRequest = RegisterRequest(
         name: 'John Doe',
         email: 'john@example.com',
         password: 'password123',
       );

       final stringRepresentation = registerRequest.toString();

       expect(stringRepresentation, contains('John Doe'));
       expect(stringRepresentation, contains('john@example.com'));
       expect(stringRepresentation, isNot(contains('password123'))); // Password should not be in toString
     });
   });

   group('RefreshTokenRequest', () {
     test('should create RefreshTokenRequest with required fields', () {
       final refreshTokenRequest = RefreshTokenRequest(
         refreshToken: 'refresh_token_123',
       );

       expect(refreshTokenRequest.refreshToken, 'refresh_token_123');
     });

     test('should convert RefreshTokenRequest to JSON', () {
       final refreshTokenRequest = RefreshTokenRequest(
         refreshToken: 'refresh_token_123',
       );

       final json = refreshTokenRequest.toJson();

       expect(json['refresh_token'], 'refresh_token_123');
     });

     test('should have proper toString representation', () {
       final refreshTokenRequest = RefreshTokenRequest(
         refreshToken: 'refresh_token_123456789',
       );

       final stringRepresentation = refreshTokenRequest.toString();

       expect(stringRepresentation, contains('refresh_to')); // Should show truncated token
       expect(stringRepresentation, isNot(contains('123456789'))); // Should not show full token
     });
   });

  group('TokenResponse', () {
    test('should create TokenResponse from JSON', () {
      final json = {
        'access_token': 'access_token_123',
        'refresh_token': 'refresh_token_456',
      };

      final tokenResponse = TokenResponse.fromJson(json);

      expect(tokenResponse.accessToken, 'access_token_123');
      expect(tokenResponse.refreshToken, 'refresh_token_456');
    });

    test('should convert TokenResponse to JSON', () {
       final tokenResponse = TokenResponse(
         accessToken: 'access_token_123',
         refreshToken: 'refresh_token_456',
       );

       final json = tokenResponse.toJson();

       expect(json['access_token'], 'access_token_123');
       expect(json['refresh_token'], 'refresh_token_456');
     });

     test('should have proper toString representation', () {
       final tokenResponse = TokenResponse(
         accessToken: 'access_token_123456789',
         refreshToken: 'refresh_token_987654321',
       );

      final stringRepresentation = tokenResponse.toString();

      expect(stringRepresentation, contains('access_tok')); // Should show truncated token
      expect(stringRepresentation, contains('refresh_to')); // Should show truncated token
      expect(stringRepresentation, isNot(contains('123456789'))); // Should not show full tokens
      expect(stringRepresentation, isNot(contains('987654321')));
    });
  });

  group('AuthResponse', () {
    test('should create AuthResponse from JSON', () {
      final json = {
        'user': {
          'id': 1,
          'name': 'John Doe',
          'email': 'john@example.com',
        },
        'access_token': 'access_token_123',
        'refresh_token': 'refresh_token_456',
      };

      final authResponse = AuthResponse.fromJson(json);

      expect(authResponse.user.id, 1);
      expect(authResponse.user.name, 'John Doe');
      expect(authResponse.user.email, 'john@example.com');
      expect(authResponse.accessToken, 'access_token_123');
      expect(authResponse.refreshToken, 'refresh_token_456');
    });

    test('should convert AuthResponse to JSON', () {
      final user = User(
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
      );
      final authResponse = AuthResponse(
        user: user,
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
      );

      final json = authResponse.toJson();

      expect(json['user']['id'], 1);
      expect(json['user']['name'], 'John Doe');
      expect(json['user']['email'], 'john@example.com');
      expect(json['access_token'], 'access_token_123');
      expect(json['refresh_token'], 'refresh_token_456');
    });

    test('should have proper toString representation', () {
      final user = User(
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
      );
      final authResponse = AuthResponse(
        user: user,
        accessToken: 'access_token_123456789',
        refreshToken: 'refresh_token_987654321',
      );

      final stringRepresentation = authResponse.toString();

      expect(stringRepresentation, contains('John Doe'));
      expect(stringRepresentation, contains('access_tok')); // Should show truncated token
      expect(stringRepresentation, contains('refresh_to')); // Should show truncated token
      expect(stringRepresentation, isNot(contains('123456789'))); // Should not show full tokens
      expect(stringRepresentation, isNot(contains('987654321')));
    });
  });

  group('ValidationError', () {
    test('should create ValidationError with required fields', () {
       final validationError = ValidationError(
         field: 'email',
         message: 'Email is required',
       );

       expect(validationError.field, 'email');
       expect(validationError.message, 'Email is required');
     });

     test('should create ValidationError from JSON', () {
       final json = {
         'field': 'password',
         'message': 'Password must be at least 8 characters',
       };

       final validationError = ValidationError.fromJson(json);

       expect(validationError.field, 'password');
       expect(validationError.message, 'Password must be at least 8 characters');
     });

     test('should convert ValidationError to JSON', () {
       final validationError = ValidationError(
         field: 'name',
         message: 'Name is required',
       );

       final json = validationError.toJson();

       expect(json['field'], 'name');
       expect(json['message'], 'Name is required');
     });

     test('should have proper toString representation', () {
       final validationError = ValidationError(
         field: 'email',
         message: 'Invalid email format',
       );

      final stringRepresentation = validationError.toString();

      expect(stringRepresentation, contains('email'));
      expect(stringRepresentation, contains('Invalid email format'));
    });
  });

  group('ApiResponse', () {
    test('should create ApiResponse from JSON with data', () {
      final json = {
        'message': 'success',
        'data': {'id': 1, 'name': 'Test'},
      };

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        json,
        (data) => data as Map<String, dynamic>,
      );

      expect(apiResponse.message, 'success');
      expect(apiResponse.data?['id'], 1);
      expect(apiResponse.data?['name'], 'Test');
      expect(apiResponse.isSuccess, true);
      expect(apiResponse.isFailure, false);
    });

    test('should create ApiResponse from JSON with errors', () {
      final json = {
        'message': 'failed',
        'error': 'Validation failed',
        'errors': [
          {'field': 'email', 'message': 'Email is required'},
          {'field': 'password', 'message': 'Password is required'},
        ],
      };

      final apiResponse = ApiResponse<String>.fromJson(json, null);

      expect(apiResponse.message, 'failed');
      expect(apiResponse.error, 'Validation failed');
      expect(apiResponse.errors?.length, 2);
      expect(apiResponse.errors?[0].field, 'email');
      expect(apiResponse.errors?[0].message, 'Email is required');
      expect(apiResponse.isSuccess, false);
      expect(apiResponse.isFailure, true);
    });

    test('should handle null data correctly', () {
      final json = {
        'message': 'success',
        'data': null,
      };

      final apiResponse = ApiResponse<String>.fromJson(json, null);

      expect(apiResponse.message, 'success');
      expect(apiResponse.data, null);
      expect(apiResponse.isSuccess, true);
    });
  });

  group('AuthState', () {
    test('should have all required states', () {
      expect(AuthState.values, contains(AuthState.initial));
      expect(AuthState.values, contains(AuthState.loading));
      expect(AuthState.values, contains(AuthState.authenticated));
      expect(AuthState.values, contains(AuthState.unauthenticated));
      expect(AuthState.values, contains(AuthState.error));
    });

    test('should be comparable', () {
      expect(AuthState.initial == AuthState.initial, true);
      expect(AuthState.loading == AuthState.authenticated, false);
    });
  });

  group('AuthErrorType', () {
    test('should have all required error types', () {
      expect(AuthErrorType.values, contains(AuthErrorType.invalidCredentials));
      expect(AuthErrorType.values, contains(AuthErrorType.networkError));
      expect(AuthErrorType.values, contains(AuthErrorType.serverError));
      expect(AuthErrorType.values, contains(AuthErrorType.validationError));
      expect(AuthErrorType.values, contains(AuthErrorType.tokenExpired));
      expect(AuthErrorType.values, contains(AuthErrorType.registrationFailed));
      expect(AuthErrorType.values, contains(AuthErrorType.unauthorized));
      expect(AuthErrorType.values, contains(AuthErrorType.unknown));
    });

    test('should be comparable', () {
      expect(AuthErrorType.networkError == AuthErrorType.networkError, true);
      expect(AuthErrorType.serverError == AuthErrorType.networkError, false);
    });
  });

  group('AuthError', () {
    test('should create AuthError with required fields', () {
       final authError = AuthError(
         type: AuthErrorType.invalidCredentials,
         message: 'Invalid email or password',
       );

      expect(authError.type, AuthErrorType.invalidCredentials);
      expect(authError.message, 'Invalid email or password');
      expect(authError.validationErrors, null);
    });

    test('should create AuthError with validation errors', () {
       final validationErrors = [
         ValidationError(field: 'email', message: 'Email is required'),
         ValidationError(field: 'password', message: 'Password is required'),
       ];

       final authError = AuthError(
         type: AuthErrorType.validationError,
         message: 'Validation failed',
         validationErrors: validationErrors,
       );

      expect(authError.type, AuthErrorType.validationError);
      expect(authError.message, 'Validation failed');
      expect(authError.validationErrors?.length, 2);
      expect(authError.validationErrors?[0].field, 'email');
      expect(authError.validationErrors?[1].field, 'password');
    });

    test('should create AuthError from ApiResponse with validation errors', () {
       final apiResponse = ApiResponse<String>(
         message: 'failed',
         error: 'Validation failed',
         errors: [
           ValidationError(field: 'email', message: 'Email is required'),
           ValidationError(field: 'password', message: 'Password is required'),
         ],
       );

      final authError = AuthError.fromApiResponse(apiResponse);

      expect(authError.type, AuthErrorType.validationError);
      expect(authError.message, 'Validation failed');
      expect(authError.validationErrors?.length, 2);
    });

    test('should create AuthError from ApiResponse with credential error', () {
      final apiResponse = ApiResponse<String>(
        message: 'failed',
        error: 'Invalid credentials provided',
      );

      final authError = AuthError.fromApiResponse(apiResponse);

      expect(authError.type, AuthErrorType.invalidCredentials);
      expect(authError.message, 'Invalid credentials provided');
    });

    test('should create AuthError from ApiResponse with network error', () {
      final apiResponse = ApiResponse<String>(
        message: 'failed',
        error: 'Network connection failed',
      );

      final authError = AuthError.fromApiResponse(apiResponse);

      expect(authError.type, AuthErrorType.networkError);
      expect(authError.message, 'Network connection failed');
    });

    test('should create AuthError from ApiResponse with server error', () {
      final apiResponse = ApiResponse<String>(
        message: 'failed',
        error: 'Internal server error occurred',
      );

      final authError = AuthError.fromApiResponse(apiResponse);

      expect(authError.type, AuthErrorType.serverError);
      expect(authError.message, 'Internal server error occurred');
    });

    test('should create AuthError from ApiResponse with token error', () {
      final apiResponse = ApiResponse<String>(
        message: 'failed',
        error: 'Token has expired',
      );

      final authError = AuthError.fromApiResponse(apiResponse);

      expect(authError.type, AuthErrorType.tokenExpired);
      expect(authError.message, 'Token has expired');
    });

    test('should create AuthError from ApiResponse with unknown error', () {
      final apiResponse = ApiResponse<String>(
        message: 'failed',
        error: 'Something went wrong',
      );

      final authError = AuthError.fromApiResponse(apiResponse);

      expect(authError.type, AuthErrorType.unknown);
      expect(authError.message, 'Something went wrong');
    });

    test('should handle null error message in ApiResponse', () {
      final apiResponse = ApiResponse<String>(
        message: 'failed',
      );

      final authError = AuthError.fromApiResponse(apiResponse);

      expect(authError.type, AuthErrorType.unknown);
      expect(authError.message, 'Unknown error occurred');
    });

    test('should have proper toString representation', () {
       final authError = AuthError(
         type: AuthErrorType.networkError,
         message: 'Connection timeout',
       );

       final stringRepresentation = authError.toString();

       expect(stringRepresentation, contains('networkError'));
       expect(stringRepresentation, contains('Connection timeout'));
     });

     test('should be equal when properties match', () {
       final authError1 = AuthError(
         type: AuthErrorType.networkError,
         message: 'Network error',
       );

       final authError2 = AuthError(
         type: AuthErrorType.networkError,
         message: 'Network error',
       );

       final authError3 = AuthError(
         type: AuthErrorType.serverError,
         message: 'Server error',
       );

      expect(authError1.type, authError2.type);
      expect(authError1.message, authError2.message);
      expect(authError1.type == authError3.type, false);
    });
  });
}