import 'package:flutter_test/flutter_test.dart';
import 'package:client/services/auth/auth_service.dart';
import 'package:client/models/auth.dart';

void main() {
  group('AuthService Tests', () {
    group('Validation Tests', () {
      test('should validate email correctly', () {
        // Valid emails
        expect(AuthService.isValidEmail('test@example.com'), true);
        expect(AuthService.isValidEmail('user.name@domain.co.uk'), true);
        expect(AuthService.isValidEmail('user+tag@example.org'), true);

        // Invalid emails
        expect(AuthService.isValidEmail('invalid-email'), false);
        expect(AuthService.isValidEmail('test@'), false);
        expect(AuthService.isValidEmail('@example.com'), false);
        expect(AuthService.isValidEmail(''), false);
      });

      test('should validate password correctly', () {
        // Valid passwords (at least 8 chars with uppercase, lowercase, and number)
        expect(AuthService.isValidPassword('Password123'), true);
        expect(AuthService.isValidPassword('MySecure1'), true);
        expect(AuthService.isValidPassword('Test1234'), true);

        // Invalid passwords
        expect(AuthService.isValidPassword('short'), false); // too short
        expect(AuthService.isValidPassword('1234567'), false); // too short
        expect(AuthService.isValidPassword(''), false); // empty
        expect(AuthService.isValidPassword('password'), false); // no uppercase or number
        expect(AuthService.isValidPassword('PASSWORD123'), false); // no lowercase
        expect(AuthService.isValidPassword('Password'), false); // no number
      });

      test('should return correct password strength message', () {
        final message = AuthService.getPasswordStrengthMessage();
        expect(message, contains('8 characters'));
        expect(message, contains('uppercase'));
        expect(message, contains('lowercase'));
        expect(message, contains('numeric'));
      });
    });

    group('Error Handling Tests', () {
      test('should handle auth errors correctly', () {
        final error = Exception('Test error');
        final authError = AuthService.handleAuthError(error);
        
        expect(authError.type, AuthErrorType.unknown);
        expect(authError.message, contains('Test error'));
      });

      test('should preserve existing auth errors', () {
        final originalError = AuthError(
          type: AuthErrorType.invalidCredentials,
          message: 'Invalid credentials',
        );
        
        final handledError = AuthService.handleAuthError(originalError);
        
        expect(handledError.type, AuthErrorType.invalidCredentials);
        expect(handledError.message, 'Invalid credentials');
      });
    });
  });
}