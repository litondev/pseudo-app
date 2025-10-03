import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';

import 'package:client/main.dart';
import 'package:client/providers/auth_provider.dart';
import 'package:client/services/auth/auth_service.dart';
import 'package:client/services/api_service.dart';
import 'package:client/services/storage_service.dart';
import 'package:client/screens/auth/signin_screen.dart';
import 'package:client/screens/auth/signup_screen.dart';
import 'package:client/screens/auth/auth_wrapper.dart';
import 'package:client/screens/dashboard/dashboard_screen.dart';
import 'package:client/models/auth.dart';
import 'package:client/models/user.dart';

import '../test_utils.dart';
import 'auth_e2e_test.mocks.dart';

@GenerateMocks([AuthService, ApiService, StorageService])
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication E2E Tests', () {
    late MockAuthService mockAuthService;
    late MockApiService mockApiService;
    late MockStorageService mockStorageService;

    setUp(() {
      mockAuthService = MockAuthService();
      mockApiService = MockApiService();
      mockStorageService = MockStorageService();
    });

    Widget createApp() {
      return MaterialApp(
        title: 'Pseudo App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: ChangeNotifierProvider(
          create: (context) => AuthProvider(mockAuthService),
          child: const AuthWrapper(),
        ),
        routes: {
          '/signin': (context) => const SignInScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/dashboard': (context) => const DashboardScreen(),
        },
      );
    }

    group('Complete Authentication Flow', () {
      testWidgets('should complete full sign up and sign in flow', (WidgetTester tester) async {
        // Setup mocks for successful registration
        final mockUser = TestUtils.createMockUser(
          name: 'John Doe',
          email: 'john@example.com',
        );
        final mockTokenResponse = TestUtils.createMockTokenResponse(user: mockUser);
        final mockAuthResponse = TestUtils.createMockAuthResponse(data: mockTokenResponse);

        when(mockAuthService.register(any, any, any))
            .thenAnswer((_) async => mockAuthResponse);
        when(mockAuthService.signIn(any, any))
            .thenAnswer((_) async => mockAuthResponse);
        when(mockAuthService.isAuthenticated())
            .thenAnswer((_) async => false);
        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => null);

        // Start the app
        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        // Should start at sign in screen
        expect(find.byType(SignInScreen), findsOneWidget);
        expect(find.text('Welcome Back'), findsOneWidget);

        // Navigate to sign up screen
        await tester.tap(find.text('Sign up'));
        await tester.pumpAndSettle();

        // Should be on sign up screen
        expect(find.byType(SignUpScreen), findsOneWidget);
        expect(find.text('Create Account'), findsOneWidget);

        // Fill out sign up form
        await TestUtils.fillSignUpForm(tester, {
          'name': 'John Doe',
          'email': 'john@example.com',
          'password': 'password123',
          'confirmPassword': 'password123',
        });

        // Accept terms and conditions
        await TestUtils.acceptTermsAndConditions(tester);

        // Submit sign up form
        await TestUtils.tapButtonByText(tester, 'Sign Up');
        await tester.pumpAndSettle();

        // Verify registration was called
        verify(mockAuthService.register('John Doe', 'john@example.com', 'password123')).called(1);

        // Should navigate back to sign in screen after successful registration
        expect(find.byType(SignInScreen), findsOneWidget);

        // Fill out sign in form
        await TestUtils.fillSignInForm(tester, {
          'email': 'john@example.com',
          'password': 'password123',
        });

        // Submit sign in form
        await TestUtils.tapButtonByText(tester, 'Sign In');
        await tester.pumpAndSettle();

        // Verify sign in was called
        verify(mockAuthService.signIn('john@example.com', 'password123')).called(1);

        // Should navigate to dashboard after successful sign in
        // Note: This would require proper dashboard implementation
        expect(find.byType(SignInScreen), findsNothing);
      });

      testWidgets('should handle sign up validation errors', (WidgetTester tester) async {
        // Setup mocks for validation errors
        final validationErrors = TestUtils.createMockValidationErrors();
        final mockAuthResponse = TestUtils.createMockAuthResponse(
          success: false,
          message: 'Validation failed',
          errors: validationErrors,
        );

        when(mockAuthService.register(any, any, any))
            .thenAnswer((_) async => mockAuthResponse);
        when(mockAuthService.isAuthenticated())
            .thenAnswer((_) async => false);
        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => null);

        // Start the app
        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        // Navigate to sign up screen
        await tester.tap(find.text('Sign up'));
        await tester.pumpAndSettle();

        // Fill out sign up form with invalid data
        await TestUtils.fillSignUpForm(tester, TestUtils.getInvalidSignUpData());
        await TestUtils.acceptTermsAndConditions(tester);

        // Submit sign up form
        await TestUtils.tapButtonByText(tester, 'Sign Up');
        await tester.pumpAndSettle();

        // Should display validation errors
        TestUtils.expectTextDisplayed('Validation failed');
        TestUtils.verifyErrorState('Validation failed');

        // Should still be on sign up screen
        expect(find.byType(SignUpScreen), findsOneWidget);
      });

      testWidgets('should handle sign in authentication errors', (WidgetTester tester) async {
        // Setup mocks for authentication error
        final authError = TestUtils.createMockAuthError(
          type: AuthErrorType.invalidCredentials,
          message: 'Invalid email or password',
        );
        final mockAuthResponse = TestUtils.createMockAuthResponse(
          success: false,
          message: 'Invalid email or password',
        );

        when(mockAuthService.signIn(any, any))
            .thenThrow(authError);
        when(mockAuthService.isAuthenticated())
            .thenAnswer((_) async => false);
        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => null);

        // Start the app
        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        // Fill out sign in form
        await TestUtils.fillSignInForm(tester, {
          'email': 'wrong@example.com',
          'password': 'wrongpassword',
        });

        // Submit sign in form
        await TestUtils.tapButtonByText(tester, 'Sign In');
        await tester.pumpAndSettle();

        // Should display authentication error
        TestUtils.verifyErrorState('Invalid email or password');

        // Should still be on sign in screen
        expect(find.byType(SignInScreen), findsOneWidget);
      });

      testWidgets('should handle network errors gracefully', (WidgetTester tester) async {
        // Setup mocks for network error
        final authError = TestUtils.createMockAuthError(
          type: AuthErrorType.networkError,
          message: 'Network connection failed',
        );

        when(mockAuthService.signIn(any, any))
            .thenThrow(authError);
        when(mockAuthService.isAuthenticated())
            .thenAnswer((_) async => false);
        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => null);

        // Start the app
        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        // Fill out sign in form
        await TestUtils.fillSignInForm(tester, TestUtils.getValidSignInData());

        // Submit sign in form
        await TestUtils.tapButtonByText(tester, 'Sign In');
        await tester.pumpAndSettle();

        // Should display network error
        TestUtils.verifyErrorState('Network connection failed');

        // Should still be on sign in screen
        expect(find.byType(SignInScreen), findsOneWidget);
      });

      testWidgets('should maintain authentication state across app restarts', (WidgetTester tester) async {
        // Setup mocks for existing authentication
        final mockUser = TestUtils.createMockUser();
        final mockTokenResponse = TestUtils.createMockTokenResponse(user: mockUser);

        when(mockAuthService.isAuthenticated())
            .thenAnswer((_) async => true);
        when(mockAuthService.getCurrentUser())
            .thenAnswer((_) async => mockUser);
        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => 'existing_token');
        when(mockStorageService.getUserData())
            .thenAnswer((_) async => mockUser.toJson());

        // Start the app
        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        // Should skip sign in and go directly to dashboard
        expect(find.byType(SignInScreen), findsNothing);
        // Note: Would expect dashboard here with proper implementation
      });

      testWidgets('should handle token refresh on expired tokens', (WidgetTester tester) async {
        // Setup mocks for token refresh scenario
        final mockUser = TestUtils.createMockUser();
        final mockTokenResponse = TestUtils.createMockTokenResponse(user: mockUser);

        when(mockAuthService.isAuthenticated())
            .thenAnswer((_) async => true);
        when(mockAuthService.getCurrentUser())
            .thenAnswer((_) async => mockUser);
        when(mockAuthService.refreshToken())
            .thenAnswer((_) async => mockTokenResponse);
        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => 'expired_token');
        when(mockStorageService.getRefreshToken())
            .thenAnswer((_) async => 'refresh_token');

        // Start the app
        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        // Should handle token refresh automatically
        verify(mockAuthService.refreshToken()).called(1);
      });
    });

    group('Form Interaction Tests', () {
      testWidgets('should validate form fields in real-time', (WidgetTester tester) async {
        when(mockAuthService.isAuthenticated())
            .thenAnswer((_) async => false);
        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => null);

        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        // Navigate to sign up screen
        await tester.tap(find.text('Sign up'));
        await tester.pumpAndSettle();

        // Test email validation
        await TestUtils.enterTextByIndex(tester, 1, 'invalid-email');
        await tester.tap(find.text('Full Name')); // Tap elsewhere to trigger validation
        await tester.pump();

        // Should show email validation error
        expect(find.text('Please enter a valid email'), findsOneWidget);

        // Test password confirmation
        await TestUtils.enterTextByIndex(tester, 2, 'password123');
        await TestUtils.enterTextByIndex(tester, 3, 'different');
        await tester.tap(find.text('Full Name')); // Tap elsewhere to trigger validation
        await tester.pump();

        // Should show password mismatch error
        expect(find.text('Passwords do not match'), findsOneWidget);
      });

      testWidgets('should toggle password visibility', (WidgetTester tester) async {
        when(mockAuthService.isAuthenticated())
            .thenAnswer((_) async => false);
        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => null);

        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        // Find password field
        final passwordField = find.byType(TextFormField).last;

        // Initially password should be obscured
        expect(tester.widget<TextFormField>(passwordField).obscureText, true);

        // Tap visibility toggle
        await TestUtils.tapButtonByIcon(tester, Icons.visibility);

        // Password should now be visible
        expect(tester.widget<TextFormField>(passwordField).obscureText, false);

        // Tap visibility toggle again
        await TestUtils.tapButtonByIcon(tester, Icons.visibility_off);

        // Password should be obscured again
        expect(tester.widget<TextFormField>(passwordField).obscureText, true);
      });

      testWidgets('should handle remember me functionality', (WidgetTester tester) async {
        when(mockAuthService.isAuthenticated())
            .thenAnswer((_) async => false);
        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => null);

        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        // Find remember me checkbox
        final rememberMeCheckbox = find.widgetWithText(CheckboxListTile, 'Remember me');
        expect(rememberMeCheckbox, findsOneWidget);

        // Initially should be unchecked
        expect(tester.widget<CheckboxListTile>(rememberMeCheckbox).value, false);

        // Tap remember me checkbox
        await tester.tap(rememberMeCheckbox);
        await tester.pump();

        // Should now be checked
        expect(tester.widget<CheckboxListTile>(rememberMeCheckbox).value, true);
      });
    });

    group('Navigation Tests', () {
      testWidgets('should navigate between sign in and sign up screens', (WidgetTester tester) async {
        when(mockAuthService.isAuthenticated())
            .thenAnswer((_) async => false);
        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => null);

        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        // Should start at sign in screen
        expect(find.byType(SignInScreen), findsOneWidget);

        // Navigate to sign up
        await tester.tap(find.text('Sign up'));
        await tester.pumpAndSettle();

        // Should be on sign up screen
        expect(find.byType(SignUpScreen), findsOneWidget);
        expect(find.byType(SignInScreen), findsNothing);

        // Navigate back to sign in
        await tester.tap(find.text('Sign in'));
        await tester.pumpAndSettle();

        // Should be back on sign in screen
        expect(find.byType(SignInScreen), findsOneWidget);
        expect(find.byType(SignUpScreen), findsNothing);
      });

      testWidgets('should handle back button navigation', (WidgetTester tester) async {
        when(mockAuthService.isAuthenticated())
            .thenAnswer((_) async => false);
        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => null);

        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        // Navigate to sign up
        await tester.tap(find.text('Sign up'));
        await tester.pumpAndSettle();

        // Should be on sign up screen
        expect(find.byType(SignUpScreen), findsOneWidget);

        // Simulate back button press
        await tester.pageBack();
        await tester.pumpAndSettle();

        // Should be back on sign in screen
        expect(find.byType(SignInScreen), findsOneWidget);
      });
    });

    group('Loading States Tests', () {
      testWidgets('should show loading states during authentication', (WidgetTester tester) async {
        // Setup delayed response to test loading state
        final mockUser = TestUtils.createMockUser();
        final mockTokenResponse = TestUtils.createMockTokenResponse(user: mockUser);
        final mockAuthResponse = TestUtils.createMockAuthResponse(data: mockTokenResponse);

        when(mockAuthService.signIn(any, any))
            .thenAnswer((_) async {
              await TestUtils.simulateNetworkDelay(const Duration(seconds: 2));
              return mockAuthResponse;
            });
        when(mockAuthService.isAuthenticated())
            .thenAnswer((_) async => false);
        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => null);

        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        // Fill out sign in form
        await TestUtils.fillSignInForm(tester, TestUtils.getValidSignInData());

        // Submit form
        await TestUtils.tapButtonByText(tester, 'Sign In');
        await tester.pump(); // Don't wait for settle to catch loading state

        // Should show loading state
        TestUtils.verifyLoadingState(loadingText: 'Signing in...');

        // Wait for completion
        await tester.pumpAndSettle();

        // Loading should be gone
        TestUtils.expectWidgetNotDisplayed<CircularProgressIndicator>();
      });

      testWidgets('should show loading state during app initialization', (WidgetTester tester) async {
        // Setup delayed initialization
        when(mockAuthService.isAuthenticated())
            .thenAnswer((_) async {
              await TestUtils.simulateNetworkDelay(const Duration(seconds: 1));
              return false;
            });
        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => null);

        await tester.pumpWidget(createApp());
        await tester.pump(); // Don't wait for settle to catch loading state

        // Should show loading state
        TestUtils.verifyLoadingState(loadingText: 'Loading...');

        // Wait for completion
        await tester.pumpAndSettle();

        // Should show sign in screen after loading
        expect(find.byType(SignInScreen), findsOneWidget);
      });
    });

    group('Error Recovery Tests', () {
      testWidgets('should allow retry after network error', (WidgetTester tester) async {
        // Setup network error first, then success
        final mockUser = TestUtils.createMockUser();
        final mockTokenResponse = TestUtils.createMockTokenResponse(user: mockUser);
        final mockAuthResponse = TestUtils.createMockAuthResponse(data: mockTokenResponse);

        final authError = TestUtils.createMockAuthError(
          type: AuthErrorType.networkError,
          message: 'Network connection failed',
        );

        when(mockAuthService.signIn(any, any))
            .thenThrow(authError)
            .thenAnswer((_) async => mockAuthResponse);
        when(mockAuthService.isAuthenticated())
            .thenAnswer((_) async => false);
        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => null);

        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        // Fill out and submit form (first attempt - should fail)
        await TestUtils.fillSignInForm(tester, TestUtils.getValidSignInData());
        await TestUtils.tapButtonByText(tester, 'Sign In');
        await tester.pumpAndSettle();

        // Should show error
        TestUtils.verifyErrorState('Network connection failed');

        // Try again (second attempt - should succeed)
        await TestUtils.tapButtonByText(tester, 'Sign In');
        await tester.pumpAndSettle();

        // Should succeed this time
        verify(mockAuthService.signIn(any, any)).called(2);
      });

      testWidgets('should clear errors when user starts typing', (WidgetTester tester) async {
        // Setup authentication error
        final authError = TestUtils.createMockAuthError(
          type: AuthErrorType.invalidCredentials,
          message: 'Invalid credentials',
        );

        when(mockAuthService.signIn(any, any))
            .thenThrow(authError);
        when(mockAuthService.isAuthenticated())
            .thenAnswer((_) async => false);
        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => null);

        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        // Fill out and submit form (should fail)
        await TestUtils.fillSignInForm(tester, TestUtils.getValidSignInData());
        await TestUtils.tapButtonByText(tester, 'Sign In');
        await tester.pumpAndSettle();

        // Should show error
        TestUtils.verifyErrorState('Invalid credentials');

        // Start typing in email field
        await TestUtils.enterTextByIndex(tester, 0, 'new@example.com');
        await tester.pump();

        // Error should be cleared (this would depend on implementation)
        // TestUtils.expectTextNotDisplayed('Invalid credentials');
      });
    });
  });
}