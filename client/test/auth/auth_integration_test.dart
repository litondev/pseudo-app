import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:client/screens/auth/signin_screen.dart';
import 'package:client/screens/auth/signup_screen.dart';
import 'package:client/screens/auth/auth_wrapper.dart';
import 'package:client/screens/dashboard/dashboard_screen.dart';
import 'package:client/providers/auth_provider.dart';
import 'package:client/services/auth/auth_service.dart';
import 'package:client/models/auth.dart';
import 'package:client/models/user.dart';

import 'auth_integration_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  group('Authentication Integration Tests', () {
    late MockAuthService mockAuthService;
    late AuthProvider authProvider;

    setUp(() {
      mockAuthService = MockAuthService();
      authProvider = AuthProvider();
      // In a real implementation, you'd inject the mock service
    });

    Widget createTestApp(Widget child) {
      return MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>(
          create: (_) => authProvider,
          child: child,
        ),
      );
    }

    group('Sign In Flow Tests', () {
      testWidgets('should complete sign in flow successfully', (WidgetTester tester) async {
        // Arrange
        final mockUser = User(
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final mockResponse = AuthResponse(
          success: true,
          message: 'Sign in successful',
          data: TokenResponse(
            accessToken: 'mock_access_token',
            refreshToken: 'mock_refresh_token',
            expiresIn: 3600,
            user: mockUser,
          ),
        );

        when(mockAuthService.signIn(any))
            .thenAnswer((_) async => mockResponse);

        // Build the sign in screen
        await tester.pumpWidget(createTestApp(const SignInScreen()));
        await tester.pumpAndSettle();

        // Act - Fill in the form
        await tester.enterText(
          find.byKey(const Key('email_field')),
          'john@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'password123',
        );

        // Tap the sign in button
        await tester.tap(find.byKey(const Key('signin_button')));
        await tester.pumpAndSettle();

        // Assert - Check that the sign in was successful
        expect(authProvider.authState, AuthState.authenticated);
        expect(authProvider.user?.email, 'john@example.com');
        expect(authProvider.error, null);
      });

      testWidgets('should show error message on sign in failure', (WidgetTester tester) async {
        // Arrange
        final mockResponse = AuthResponse(
          success: false,
          message: 'Invalid credentials',
        );

        when(mockAuthService.signIn(any))
            .thenAnswer((_) async => mockResponse);

        await tester.pumpWidget(createTestApp(const SignInScreen()));
        await tester.pumpAndSettle();

        // Act
        await tester.enterText(
          find.byKey(const Key('email_field')),
          'john@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'wrong_password',
        );

        await tester.tap(find.byKey(const Key('signin_button')));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Invalid credentials'), findsOneWidget);
        expect(authProvider.authState, AuthState.unauthenticated);
      });

      testWidgets('should validate form fields', (WidgetTester tester) async {
        // Build the sign in screen
        await tester.pumpWidget(createTestApp(const SignInScreen()));
        await tester.pumpAndSettle();

        // Act - Try to submit empty form
        await tester.tap(find.byKey(const Key('signin_button')));
        await tester.pumpAndSettle();

        // Assert - Should show validation errors
        expect(find.text('Email is required'), findsOneWidget);
        expect(find.text('Password is required'), findsOneWidget);

        // Act - Enter invalid email
        await tester.enterText(
          find.byKey(const Key('email_field')),
          'invalid-email',
        );
        await tester.tap(find.byKey(const Key('signin_button')));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Please enter a valid email'), findsOneWidget);
      });

      testWidgets('should navigate to sign up screen', (WidgetTester tester) async {
        // Build the sign in screen
        await tester.pumpWidget(createTestApp(const SignInScreen()));
        await tester.pumpAndSettle();

        // Act - Tap the sign up link
        await tester.tap(find.byKey(const Key('signup_link')));
        await tester.pumpAndSettle();

        // Assert - Should navigate to sign up screen
        expect(find.byType(SignUpScreen), findsOneWidget);
      });
    });

    group('Sign Up Flow Tests', () {
      testWidgets('should complete sign up flow successfully', (WidgetTester tester) async {
        // Arrange
        final mockUser = User(
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final mockResponse = AuthResponse(
          success: true,
          message: 'Registration successful',
          data: TokenResponse(
            accessToken: 'mock_access_token',
            refreshToken: 'mock_refresh_token',
            expiresIn: 3600,
            user: mockUser,
          ),
        );

        when(mockAuthService.register(any))
            .thenAnswer((_) async => mockResponse);

        await tester.pumpWidget(createTestApp(const SignUpScreen()));
        await tester.pumpAndSettle();

        // Act - Fill in the form
        await tester.enterText(
          find.byKey(const Key('name_field')),
          'John Doe',
        );
        await tester.enterText(
          find.byKey(const Key('email_field')),
          'john@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'password123',
        );
        await tester.enterText(
          find.byKey(const Key('confirm_password_field')),
          'password123',
        );

        // Accept terms and conditions
        await tester.tap(find.byKey(const Key('terms_checkbox')));
        await tester.pumpAndSettle();

        // Tap the sign up button
        await tester.tap(find.byKey(const Key('signup_button')));
        await tester.pumpAndSettle();

        // Assert
        expect(authProvider.authState, AuthState.authenticated);
        expect(authProvider.user?.name, 'John Doe');
        expect(authProvider.error, null);
      });

      testWidgets('should validate sign up form fields', (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const SignUpScreen()));
        await tester.pumpAndSettle();

        // Act - Try to submit empty form
        await tester.tap(find.byKey(const Key('signup_button')));
        await tester.pumpAndSettle();

        // Assert - Should show validation errors
        expect(find.text('Name is required'), findsOneWidget);
        expect(find.text('Email is required'), findsOneWidget);
        expect(find.text('Password is required'), findsOneWidget);

        // Act - Enter mismatched passwords
        await tester.enterText(
          find.byKey(const Key('name_field')),
          'John Doe',
        );
        await tester.enterText(
          find.byKey(const Key('email_field')),
          'john@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'password123',
        );
        await tester.enterText(
          find.byKey(const Key('confirm_password_field')),
          'different_password',
        );

        await tester.tap(find.byKey(const Key('signup_button')));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Passwords do not match'), findsOneWidget);
      });

      testWidgets('should require terms and conditions acceptance', (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const SignUpScreen()));
        await tester.pumpAndSettle();

        // Act - Fill form but don't accept terms
        await tester.enterText(
          find.byKey(const Key('name_field')),
          'John Doe',
        );
        await tester.enterText(
          find.byKey(const Key('email_field')),
          'john@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'password123',
        );
        await tester.enterText(
          find.byKey(const Key('confirm_password_field')),
          'password123',
        );

        await tester.tap(find.byKey(const Key('signup_button')));
        await tester.pumpAndSettle();

        // Assert - Should show terms error
        expect(find.text('Please accept the terms and conditions'), findsOneWidget);
      });
    });

    group('Auth Wrapper Tests', () {
      testWidgets('should show sign in screen when unauthenticated', (WidgetTester tester) async {
        // Arrange
        when(mockAuthService.isAuthenticated())
            .thenAnswer((_) async => false);

        await tester.pumpWidget(createTestApp(const AuthWrapper()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(SignInScreen), findsOneWidget);
        expect(find.byType(DashboardScreen), findsNothing);
      });

      testWidgets('should show dashboard when authenticated', (WidgetTester tester) async {
        // Arrange
        final mockUser = User(
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockAuthService.isAuthenticated())
            .thenAnswer((_) async => true);

        final mockResponse = ApiResponse<User>(
          success: true,
          data: mockUser,
        );

        when(mockAuthService.getCurrentUser())
            .thenAnswer((_) async => mockResponse);

        // Set authenticated state
        authProvider.authState = AuthState.authenticated;
        authProvider.user = mockUser;

        await tester.pumpWidget(createTestApp(const AuthWrapper()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(DashboardScreen), findsOneWidget);
        expect(find.byType(SignInScreen), findsNothing);
      });

      testWidgets('should show loading screen during initialization', (WidgetTester tester) async {
        // Arrange
        when(mockAuthService.isAuthenticated())
            .thenAnswer((_) async {
          // Simulate delay
          await Future.delayed(Duration(milliseconds: 100));
          return false;
        });

        await tester.pumpWidget(createTestApp(const AuthWrapper()));

        // Assert - Should show loading initially
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for initialization to complete
        await tester.pumpAndSettle();

        // Assert - Should show sign in screen after loading
        expect(find.byType(SignInScreen), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    group('Complete Authentication Flow Tests', () {
      testWidgets('should complete full authentication cycle', (WidgetTester tester) async {
        // Arrange - Mock services for sign up
        final mockUser = User(
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final mockAuthResponse = AuthResponse(
          success: true,
          message: 'Registration successful',
          data: TokenResponse(
            accessToken: 'mock_access_token',
            refreshToken: 'mock_refresh_token',
            expiresIn: 3600,
            user: mockUser,
          ),
        );

        final mockSignOutResponse = ApiResponse<void>(
          success: true,
          message: 'Signed out successfully',
        );

        when(mockAuthService.register(any))
            .thenAnswer((_) async => mockAuthResponse);
        when(mockAuthService.signOut())
            .thenAnswer((_) async => mockSignOutResponse);

        // Start with sign up screen
        await tester.pumpWidget(createTestApp(const SignUpScreen()));
        await tester.pumpAndSettle();

        // Step 1: Complete sign up
        await tester.enterText(find.byKey(const Key('name_field')), 'John Doe');
        await tester.enterText(find.byKey(const Key('email_field')), 'john@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tester.enterText(find.byKey(const Key('confirm_password_field')), 'password123');
        await tester.tap(find.byKey(const Key('terms_checkbox')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('signup_button')));
        await tester.pumpAndSettle();

        // Assert - Should be authenticated
        expect(authProvider.authState, AuthState.authenticated);
        expect(authProvider.user?.name, 'John Doe');

        // Step 2: Sign out
        await authProvider.signOut();
        await tester.pumpAndSettle();

        // Assert - Should be unauthenticated
        expect(authProvider.authState, AuthState.unauthenticated);
        expect(authProvider.user, null);
      });
    });

    group('Error Handling Integration Tests', () {
      testWidgets('should handle network errors gracefully', (WidgetTester tester) async {
        // Arrange
        when(mockAuthService.signIn(any))
            .thenThrow(Exception('Network error'));

        await tester.pumpWidget(createTestApp(const SignInScreen()));
        await tester.pumpAndSettle();

        // Act
        await tester.enterText(find.byKey(const Key('email_field')), 'john@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tester.tap(find.byKey(const Key('signin_button')));
        await tester.pumpAndSettle();

        // Assert
        expect(authProvider.error?.type, AuthErrorType.networkError);
        expect(find.textContaining('network'), findsOneWidget);
      });

      testWidgets('should handle server errors gracefully', (WidgetTester tester) async {
        // Arrange
        final mockResponse = AuthResponse(
          success: false,
          message: 'Server error occurred',
        );

        when(mockAuthService.signIn(any))
            .thenAnswer((_) async => mockResponse);

        await tester.pumpWidget(createTestApp(const SignInScreen()));
        await tester.pumpAndSettle();

        // Act
        await tester.enterText(find.byKey(const Key('email_field')), 'john@example.com');
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tester.tap(find.byKey(const Key('signin_button')));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Server error occurred'), findsOneWidget);
        expect(authProvider.authState, AuthState.unauthenticated);
      });
    });
  });
}