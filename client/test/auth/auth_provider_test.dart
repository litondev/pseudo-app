import 'package:flutter_test/flutter_test.dart';
import 'package:client/providers/auth_provider.dart';
import 'package:client/models/auth.dart';

void main() {
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    group('Initial State Tests', () {
      test('should have correct initial state', () {
        expect(authProvider.authState, AuthState.loading);
        expect(authProvider.currentUser, null);
        expect(authProvider.lastError, null);
        expect(authProvider.isLoading, false);
        expect(authProvider.isAuthenticated, false);
        expect(authProvider.isUnauthenticated, false);
      });
    });

    group('Validation Tests', () {
      test('should validate registration form correctly', () {
        // Test valid registration
        final validErrors = authProvider.validateRegistrationForm(
          name: 'John Doe',
          email: 'john@example.com',
          password: 'Password123!',
          confirmPassword: 'Password123!',
        );
        expect(validErrors.isEmpty, true);

        // Test empty name
        final nameErrors = authProvider.validateRegistrationForm(
          name: '',
          email: 'john@example.com',
          password: 'Password123!',
          confirmPassword: 'Password123!',
        );
        expect(nameErrors['name'], 'Name is required');

        // Test empty email
        final emailErrors = authProvider.validateRegistrationForm(
          name: 'John Doe',
          email: '',
          password: 'Password123!',
          confirmPassword: 'Password123!',
        );
        expect(emailErrors['email'], 'Email is required');

        // Test invalid email
        final invalidEmailErrors = authProvider.validateRegistrationForm(
          name: 'John Doe',
          email: 'invalid-email',
          password: 'Password123!',
          confirmPassword: 'Password123!',
        );
        expect(invalidEmailErrors['email'], 'Please enter a valid email address');

        // Test empty password
        final passwordErrors = authProvider.validateRegistrationForm(
          name: 'John Doe',
          email: 'john@example.com',
          password: '',
          confirmPassword: '',
        );
        expect(passwordErrors['password'], 'Password is required');

        // Test password mismatch
        final mismatchErrors = authProvider.validateRegistrationForm(
          name: 'John Doe',
          email: 'john@example.com',
          password: 'Password123!',
          confirmPassword: 'DifferentPassword',
        );
        expect(mismatchErrors['confirmPassword'], 'Passwords do not match');

        // Test empty confirm password
        final confirmPasswordErrors = authProvider.validateRegistrationForm(
          name: 'John Doe',
          email: 'john@example.com',
          password: 'Password123!',
          confirmPassword: '',
        );
        expect(confirmPasswordErrors['confirmPassword'], 'Please confirm your password');
      });

      test('should validate sign in form correctly', () {
        // Test valid sign in
        final validErrors = authProvider.validateSignInForm(
          email: 'john@example.com',
          password: 'password123',
        );
        expect(validErrors.isEmpty, true);

        // Test empty email
        final emailErrors = authProvider.validateSignInForm(
          email: '',
          password: 'password123',
        );
        expect(emailErrors['email'], 'Email is required');

        // Test invalid email
        final invalidEmailErrors = authProvider.validateSignInForm(
          email: 'invalid-email',
          password: 'password123',
        );
        expect(invalidEmailErrors['email'], 'Please enter a valid email address');

        // Test empty password
        final passwordErrors = authProvider.validateSignInForm(
          email: 'john@example.com',
          password: '',
        );
        expect(passwordErrors['password'], 'Password is required');
      });
    });

    group('State Management Tests', () {
      test('should have correct authentication state properties', () {
        // Test loading state
        expect(authProvider.authState, AuthState.loading);
        expect(authProvider.isAuthenticated, false);
        expect(authProvider.isUnauthenticated, false);
      });

      test('should handle error state correctly', () {
        expect(authProvider.lastError, null);
      });

      test('should handle loading state correctly', () {
        expect(authProvider.isLoading, false);
      });
    });

    group('Property Getters Tests', () {
      test('should return correct values for all getters', () {
        expect(authProvider.authState, isA<AuthState>());
        expect(authProvider.currentUser, null);
        expect(authProvider.lastError, null);
        expect(authProvider.isLoading, isA<bool>());
        expect(authProvider.isAuthenticated, isA<bool>());
        expect(authProvider.isUnauthenticated, isA<bool>());
      });
    });

    tearDown(() {
      authProvider.dispose();
    });
  });
}