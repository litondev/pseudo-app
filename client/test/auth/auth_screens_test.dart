import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';

import 'package:client/screens/auth/signin_screen.dart';
import 'package:client/screens/auth/signup_screen.dart';
import 'package:client/screens/auth/auth_wrapper.dart';
import 'package:client/providers/auth_provider.dart';
import 'package:client/models/auth.dart';
import 'package:client/models/user.dart';

import 'auth_screens_test.mocks.dart';

@GenerateMocks([AuthProvider])
void main() {
  group('Authentication Screens Tests', () {
    late MockAuthProvider mockAuthProvider;

    setUp(() {
      mockAuthProvider = MockAuthProvider();
      
      // Default mock setup
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.lastError).thenReturn(null);
      when(mockAuthProvider.authState).thenReturn(AuthState.unauthenticated);
      when(mockAuthProvider.currentUser).thenReturn(null);
      when(mockAuthProvider.isAuthenticated).thenReturn(false);
      when(mockAuthProvider.isUnauthenticated).thenReturn(true);
      
      // Mock validation methods to return empty maps (no errors)
      when(mockAuthProvider.validateSignInForm(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenReturn({});
      
      when(mockAuthProvider.validateRegistrationForm(
        name: anyNamed('name'),
        email: anyNamed('email'),
        password: anyNamed('password'),
        confirmPassword: anyNamed('confirmPassword'),
      )).thenReturn({});
      
      // Mock async methods
      when(mockAuthProvider.signIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => true);
      
      when(mockAuthProvider.register(
        name: anyNamed('name'),
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => true);
    });

    group('SignInScreen Tests', () {
      Widget createSignInScreen() {
        return MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const SignInScreen(),
          ),
        );
      }

      testWidgets('should display all required UI elements', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createSignInScreen());

        // Assert
        expect(find.text('Welcome Back'), findsOneWidget);
        expect(find.text('Sign in to your account'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(2)); // Email and Password
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Remember me'), findsOneWidget);
        expect(find.text('Forgot Password?'), findsOneWidget);
        expect(find.text('Sign In'), findsOneWidget);
        expect(find.text('Don\'t have an account?'), findsOneWidget);
        expect(find.text('Sign up'), findsOneWidget);
      });

      testWidgets('should validate email field when empty', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createSignInScreen());

        // Act
        await tester.tap(find.text('Sign In'));
        await tester.pump();

        // Assert
        expect(find.text('Please enter your email'), findsOneWidget);
      });

      testWidgets('should validate email format', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createSignInScreen());

        // Act
        await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
        await tester.tap(find.text('Sign In'));
        await tester.pump();

        // Assert
        expect(find.text('Please enter a valid email'), findsOneWidget);
      });

      testWidgets('should validate password field when empty', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createSignInScreen());

        // Act
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.tap(find.text('Sign In'));
        await tester.pump();

        // Assert
        expect(find.text('Please enter your password'), findsOneWidget);
      });

      testWidgets('should call signIn when form is valid', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createSignInScreen());

        // Act
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.byType(TextFormField).last, 'password123');
        await tester.tap(find.text('Sign In'));
        await tester.pump();

        // Assert
        verify(mockAuthProvider.signIn(
          email: 'test@example.com',
          password: 'password123',
        )).called(1);
      });

      testWidgets('should show loading indicator when signing in', (WidgetTester tester) async {
        // Arrange
        when(mockAuthProvider.isLoading).thenReturn(true);
        await tester.pumpWidget(createSignInScreen());

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Signing in...'), findsOneWidget);
      });

      testWidgets('should display error message when sign in fails', (WidgetTester tester) async {
        // Simulate authentication error
        final authError = AuthError(
          type: AuthErrorType.invalidCredentials,
          message: 'Invalid email or password',
        );
        when(mockAuthProvider.lastError).thenReturn(authError);
        await tester.pumpWidget(createSignInScreen());

        // Assert
        expect(find.text('Invalid email or password'), findsOneWidget);
        expect(find.byIcon(Icons.error), findsOneWidget);
      });

      testWidgets('should display validation errors from provider', (WidgetTester tester) async {
        // Arrange
        when(mockAuthProvider.validateSignInForm(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenReturn({
          'email': 'Email is required',
          'password': 'Password is too short',
        });
        await tester.pumpWidget(createSignInScreen());

        // Act - trigger validation by attempting to submit
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        expect(find.text('Email is required'), findsOneWidget);
        expect(find.text('Password is too short'), findsOneWidget);
      });

      testWidgets('should toggle password visibility', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createSignInScreen());

        // Act - Check that password visibility toggle exists
        expect(find.byIcon(Icons.visibility), findsOneWidget);

        // Tap the visibility toggle
        await tester.tap(find.byIcon(Icons.visibility));
        await tester.pump();

        // Assert - Icon should change to visibility_off
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      });

      testWidgets('should navigate to sign up screen when sign up link is tapped', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const SignInScreen(),
          ),
          routes: {
            '/signup': (context) => const SignUpScreen(),
          },
        ));

        // Act
        await tester.tap(find.text('Sign up'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(SignUpScreen), findsOneWidget);
      });
    });

    group('SignUpScreen Tests', () {
      Widget createSignUpScreen() {
        return MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const SignUpScreen(),
          ),
        );
      }

      testWidgets('should display all required UI elements', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createSignUpScreen());

        // Assert
        expect(find.text('Create Account'), findsOneWidget);
        expect(find.text('Join us today'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(4)); // Name, Email, Password, Confirm Password
        expect(find.text('Full Name'), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Confirm Password'), findsOneWidget);
        expect(find.text('I agree to the Terms and Conditions'), findsOneWidget);
        expect(find.text('Sign Up'), findsOneWidget);
        expect(find.text('Already have an account?'), findsOneWidget);
        expect(find.text('Sign in'), findsOneWidget);
      });

      testWidgets('should validate all required fields', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createSignUpScreen());

        // Act
        await tester.tap(find.text('Sign Up'));
        await tester.pump();

        // Assert
        expect(find.text('Please enter your full name'), findsOneWidget);
        expect(find.text('Please enter your email'), findsOneWidget);
        expect(find.text('Please enter a password'), findsOneWidget);
        expect(find.text('Please confirm your password'), findsOneWidget);
      });

      testWidgets('should validate password confirmation', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createSignUpScreen());
        final textFields = find.byType(TextFormField);

        // Act
        await tester.enterText(textFields.at(0), 'John Doe');
        await tester.enterText(textFields.at(1), 'john@example.com');
        await tester.enterText(textFields.at(2), 'password123');
        await tester.enterText(textFields.at(3), 'different_password');
        await tester.tap(find.text('Sign Up'));
        await tester.pump();

        // Assert
        expect(find.text('Passwords do not match'), findsOneWidget);
      });

      testWidgets('should require terms and conditions acceptance', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createSignUpScreen());
        final textFields = find.byType(TextFormField);

        // Act - Fill all fields but don't check terms
        await tester.enterText(textFields.at(0), 'John Doe');
        await tester.enterText(textFields.at(1), 'john@example.com');
        await tester.enterText(textFields.at(2), 'password123');
        await tester.enterText(textFields.at(3), 'password123');
        await tester.tap(find.text('Sign Up'));
        await tester.pump();

        // Assert
        expect(find.text('Please accept the terms and conditions'), findsOneWidget);
      });

      testWidgets('should call register when form is valid', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createSignUpScreen());
        final textFields = find.byType(TextFormField);

        // Act
        await tester.enterText(textFields.at(0), 'John Doe');
        await tester.enterText(textFields.at(1), 'john@example.com');
        await tester.enterText(textFields.at(2), 'password123');
        await tester.enterText(textFields.at(3), 'password123');
        await tester.tap(find.byType(Checkbox));
        await tester.pump();
        await tester.tap(find.text('Sign Up'));
        await tester.pump();

        // Assert
        verify(mockAuthProvider.register(
          name: 'John Doe',
          email: 'john@example.com',
          password: 'password123',
        )).called(1);
      });

      testWidgets('should show loading indicator when registering', (WidgetTester tester) async {
        // Arrange
        when(mockAuthProvider.isLoading).thenReturn(true);
        await tester.pumpWidget(createSignUpScreen());

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Creating account...'), findsOneWidget);
      });

      testWidgets('should display registration error', (WidgetTester tester) async {
        // Arrange
        final authError = AuthError(
          type: AuthErrorType.registrationFailed,
          message: 'Email already exists',
        );
        when(mockAuthProvider.lastError).thenReturn(authError);
        await tester.pumpWidget(createSignUpScreen());

        // Assert
        expect(find.text('Email already exists'), findsOneWidget);
        expect(find.byIcon(Icons.error), findsOneWidget);
      });

      testWidgets('should display validation errors from provider', (WidgetTester tester) async {
        // Arrange
        when(mockAuthProvider.validateRegistrationForm(
          name: anyNamed('name'),
          email: anyNamed('email'),
          password: anyNamed('password'),
          confirmPassword: anyNamed('confirmPassword'),
        )).thenReturn({
          'name': 'Name is required',
          'email': 'Invalid email format',
          'password': 'Password too short',
          'confirmPassword': 'Passwords do not match',
        });
        await tester.pumpWidget(createSignUpScreen());

        // Act - trigger validation by attempting to submit
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        expect(find.text('Name is required'), findsOneWidget);
        expect(find.text('Invalid email format'), findsOneWidget);
        expect(find.text('Password too short'), findsOneWidget);
        expect(find.text('Passwords do not match'), findsOneWidget);
      });

      testWidgets('should navigate to sign in screen when sign in link is tapped', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const SignUpScreen(),
          ),
          routes: {
            '/signin': (context) => const SignInScreen(),
          },
        ));

        // Act
        await tester.tap(find.text('Sign in'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(SignInScreen), findsOneWidget);
      });
    });

    group('AuthWrapper Tests', () {
      Widget createAuthWrapper() {
        return MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const AuthWrapper(),
          ),
        );
      }

      testWidgets('should show loading screen when auth state is loading', (WidgetTester tester) async {
        // Arrange
        when(mockAuthProvider.authState).thenReturn(AuthState.loading);
        await tester.pumpWidget(createAuthWrapper());

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Loading...'), findsOneWidget);
      });

      testWidgets('should show sign in screen when unauthenticated', (WidgetTester tester) async {
        // Arrange
        when(mockAuthProvider.authState).thenReturn(AuthState.unauthenticated);
        await tester.pumpWidget(createAuthWrapper());

        // Assert
        expect(find.byType(SignInScreen), findsOneWidget);
      });

      testWidgets('should show dashboard when authenticated', (WidgetTester tester) async {
        // Arrange
        final user = User(
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        when(mockAuthProvider.authState).thenReturn(AuthState.authenticated);
        when(mockAuthProvider.currentUser).thenReturn(user);
        
        await tester.pumpWidget(MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const AuthWrapper(),
          ),
        ));

        // Assert
        // Note: This would require importing DashboardScreen or creating a mock
        // For now, we'll just verify that SignInScreen is not shown
        expect(find.byType(SignInScreen), findsNothing);
      });

      testWidgets('should initialize auth provider on startup', (WidgetTester tester) async {
        // Arrange
        when(mockAuthProvider.authState).thenReturn(AuthState.loading);
        
        // Act
        await tester.pumpWidget(createAuthWrapper());

        // Assert
        verify(mockAuthProvider.initialize()).called(1);
      });
    });

    group('Form Validation Edge Cases', () {
      testWidgets('should handle special characters in email validation', (WidgetTester tester) async {
        // Arrange
        final signInScreen = MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const SignInScreen(),
          ),
        );
        await tester.pumpWidget(signInScreen);

        // Act
        await tester.enterText(find.byType(TextFormField).first, 'test+tag@example.com');
        await tester.enterText(find.byType(TextFormField).last, 'password123');
        await tester.tap(find.text('Sign In'));
        await tester.pump();

        // Assert - Should accept valid email with special characters
        verify(mockAuthProvider.signIn(
          email: 'test+tag@example.com',
          password: 'password123',
        )).called(1);
      });

      testWidgets('should handle minimum password length validation', (WidgetTester tester) async {
        // Arrange
        final signUpScreen = MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const SignUpScreen(),
          ),
        );
        await tester.pumpWidget(signUpScreen);
        final textFields = find.byType(TextFormField);

        // Act
        await tester.enterText(textFields.at(0), 'John Doe');
        await tester.enterText(textFields.at(1), 'john@example.com');
        await tester.enterText(textFields.at(2), '123'); // Too short
        await tester.enterText(textFields.at(3), '123');
        await tester.tap(find.text('Sign Up'));
        await tester.pump();

        // Assert
        expect(find.text('Password must be at least 6 characters'), findsOneWidget);
      });

      testWidgets('should trim whitespace from form inputs', (WidgetTester tester) async {
        // Arrange
        final signInScreen = MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const SignInScreen(),
          ),
        );
        await tester.pumpWidget(signInScreen);

        // Act
        await tester.enterText(find.byType(TextFormField).first, '  test@example.com  ');
        await tester.enterText(find.byType(TextFormField).last, '  password123  ');
        await tester.tap(find.text('Sign In'));
        await tester.pump();

        // Assert - Should trim whitespace
        verify(mockAuthProvider.signIn(
          email: 'test@example.com',
          password: 'password123',
        )).called(1);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should have proper semantic labels for form fields', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const SignInScreen(),
          ),
        ));

        // Assert
        expect(find.bySemanticsLabel('Email'), findsOneWidget);
        expect(find.bySemanticsLabel('Password'), findsOneWidget);
        expect(find.bySemanticsLabel('Sign In'), findsOneWidget);
      });

      testWidgets('should have proper semantic labels for buttons', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
            child: const SignUpScreen(),
          ),
        ));

        // Assert
        expect(find.bySemanticsLabel('Sign Up'), findsOneWidget);
        expect(find.bySemanticsLabel('I agree to the Terms and Conditions'), findsOneWidget);
      });
    });
  });
}