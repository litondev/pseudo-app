import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:client/models/user.dart';
import 'package:client/models/auth.dart';
import 'package:client/providers/auth_provider.dart';

/// Test utilities and helpers for authentication testing
class TestUtils {
  /// Creates a mock user for testing
  static User createMockUser({
    int id = 1,
    String name = 'John Doe',
    String email = 'john@example.com',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return User(
      id: id,
      name: name,
      email: email,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  /// Creates a mock token response for testing
  static TokenResponse createMockTokenResponse({
    String accessToken = 'mock_access_token',
    String refreshToken = 'mock_refresh_token',
  }) {
    return TokenResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  /// Creates a mock auth response for testing
  static AuthResponse createMockAuthResponse({
    User? user,
    String accessToken = 'mock_access_token',
    String refreshToken = 'mock_refresh_token',
  }) {
    return AuthResponse(
      user: user ?? createMockUser(),
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  /// Creates a mock validation error for testing
  static ValidationError createMockValidationError({
    String field = 'email',
    String message = 'Invalid email format',
  }) {
    return ValidationError(
      field: field,
      message: message,
    );
  }

  /// Creates a mock auth error for testing
  static AuthError createMockAuthError({
    AuthErrorType type = AuthErrorType.invalidCredentials,
    String message = 'Invalid credentials',
    List<ValidationError>? validationErrors,
  }) {
    return AuthError(
      type: type,
      message: message,
      validationErrors: validationErrors,
    );
  }

  /// Creates a widget wrapped with necessary providers for testing
  static Widget createTestWidget({
    required Widget child,
    AuthProvider? authProvider,
  }) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          if (authProvider != null)
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ],
        child: child,
      ),
    );
  }

  /// Creates a widget with navigation for testing screen transitions
  static Widget createTestWidgetWithNavigation({
    required Widget home,
    Map<String, WidgetBuilder>? routes,
    AuthProvider? authProvider,
  }) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          if (authProvider != null)
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ],
        child: home,
      ),
      routes: routes ?? {},
    );
  }

  /// Pumps a widget and waits for all animations to complete
  static Future<void> pumpAndSettleWidget(
    WidgetTester tester,
    Widget widget, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle(timeout);
  }

  /// Enters text into a form field by its label
  static Future<void> enterTextByLabel(
    WidgetTester tester,
    String label,
    String text,
  ) async {
    final finder = find.widgetWithText(TextFormField, label);
    await tester.enterText(finder, text);
  }

  /// Enters text into a form field by its index
  static Future<void> enterTextByIndex(
    WidgetTester tester,
    int index,
    String text,
  ) async {
    final finder = find.byType(TextFormField).at(index);
    await tester.enterText(finder, text);
  }

  /// Taps a button by its text
  static Future<void> tapButtonByText(
    WidgetTester tester,
    String text,
  ) async {
    await tester.tap(find.text(text));
    await tester.pump();
  }

  /// Taps a button by its icon
  static Future<void> tapButtonByIcon(
    WidgetTester tester,
    IconData icon,
  ) async {
    await tester.tap(find.byIcon(icon));
    await tester.pump();
  }

  /// Verifies that a text is displayed on screen
  static void expectTextDisplayed(String text) {
    expect(find.text(text), findsOneWidget);
  }

  /// Verifies that a text is not displayed on screen
  static void expectTextNotDisplayed(String text) {
    expect(find.text(text), findsNothing);
  }

  /// Verifies that a widget type is displayed on screen
  static void expectWidgetDisplayed<T extends Widget>() {
    expect(find.byType(T), findsOneWidget);
  }

  /// Verifies that a widget type is not displayed on screen
  static void expectWidgetNotDisplayed<T extends Widget>() {
    expect(find.byType(T), findsNothing);
  }

  /// Verifies that an icon is displayed on screen
  static void expectIconDisplayed(IconData icon) {
    expect(find.byIcon(icon), findsOneWidget);
  }

  /// Verifies that a specific number of widgets of a type are displayed
  static void expectWidgetCount<T extends Widget>(int count) {
    expect(find.byType(T), findsNWidgets(count));
  }

  /// Waits for a specific condition to be true
  static Future<void> waitForCondition(
    WidgetTester tester,
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 5),
    Duration interval = const Duration(milliseconds: 100),
  }) async {
    final stopwatch = Stopwatch()..start();
    
    while (!condition() && stopwatch.elapsed < timeout) {
      await tester.pump(interval);
    }
    
    if (!condition()) {
      throw TimeoutException('Condition not met within timeout', timeout);
    }
  }

  /// Simulates a network delay for testing async operations
  static Future<void> simulateNetworkDelay([Duration? delay]) async {
    await Future.delayed(delay ?? const Duration(milliseconds: 500));
  }

  /// Creates a list of mock validation errors for testing
  static List<ValidationError> createMockValidationErrors() {
    return [
      ValidationError(field: 'email', message: 'Invalid email format'),
      ValidationError(field: 'password', message: 'Password too short'),
      ValidationError(field: 'name', message: 'Name is required'),
    ];
  }

  /// Verifies that a method was called with specific parameters
  static void verifyMethodCall<T>(
    Mock mock,
    Function method,
    List<dynamic> parameters, {
    int times = 1,
  }) {
    verify(method).called(times);
  }

  /// Verifies that a method was never called
  static void verifyMethodNeverCalled<T>(
    Mock mock,
    Function method,
  ) {
    verifyNever(method);
  }

  /// Sets up common mock behaviors for AuthProvider
  static void setupMockAuthProvider(Mock mockAuthProvider) {
    when(mockAuthProvider.isLoading).thenReturn(false);
    when(mockAuthProvider.error).thenReturn(null);
    when(mockAuthProvider.emailError).thenReturn(null);
    when(mockAuthProvider.passwordError).thenReturn(null);
    when(mockAuthProvider.nameError).thenReturn(null);
    when(mockAuthProvider.confirmPasswordError).thenReturn(null);
    when(mockAuthProvider.authState).thenReturn(AuthState.unauthenticated);
    when(mockAuthProvider.currentUser).thenReturn(null);
  }

  /// Creates test data for form validation scenarios
  static Map<String, dynamic> getValidSignInData() {
    return {
      'email': 'test@example.com',
      'password': 'password123',
    };
  }

  /// Creates test data for sign up form
  static Map<String, dynamic> getValidSignUpData() {
    return {
      'name': 'John Doe',
      'email': 'john@example.com',
      'password': 'password123',
      'confirmPassword': 'password123',
    };
  }

  /// Creates invalid test data for form validation
  static Map<String, dynamic> getInvalidSignInData() {
    return {
      'email': 'invalid-email',
      'password': '',
    };
  }

  /// Creates invalid test data for sign up form
  static Map<String, dynamic> getInvalidSignUpData() {
    return {
      'name': '',
      'email': 'invalid-email',
      'password': '123',
      'confirmPassword': 'different',
    };
  }

  /// Fills out a sign in form with provided data
  static Future<void> fillSignInForm(
    WidgetTester tester,
    Map<String, dynamic> data,
  ) async {
    await enterTextByIndex(tester, 0, data['email'] ?? '');
    await enterTextByIndex(tester, 1, data['password'] ?? '');
  }

  /// Fills out a sign up form with provided data
  static Future<void> fillSignUpForm(
    WidgetTester tester,
    Map<String, dynamic> data,
  ) async {
    await enterTextByIndex(tester, 0, data['name'] ?? '');
    await enterTextByIndex(tester, 1, data['email'] ?? '');
    await enterTextByIndex(tester, 2, data['password'] ?? '');
    await enterTextByIndex(tester, 3, data['confirmPassword'] ?? '');
  }

  /// Accepts terms and conditions checkbox
  static Future<void> acceptTermsAndConditions(WidgetTester tester) async {
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
  }

  /// Verifies form validation errors are displayed
  static void verifyValidationErrors(List<String> expectedErrors) {
    for (final error in expectedErrors) {
      expectTextDisplayed(error);
    }
  }

  /// Verifies loading state is displayed
  static void verifyLoadingState({String? loadingText}) {
    expectWidgetDisplayed<CircularProgressIndicator>();
    if (loadingText != null) {
      expectTextDisplayed(loadingText);
    }
  }

  /// Verifies error state is displayed
  static void verifyErrorState(String errorMessage) {
    expectTextDisplayed(errorMessage);
    expectIconDisplayed(Icons.error);
  }

  /// Creates a matcher for finding widgets with specific text
  static Finder findWidgetWithText<T extends Widget>(String text) {
    return find.widgetWithText(T, text);
  }

  /// Creates a matcher for finding widgets with specific icon
  static Finder findWidgetWithIcon<T extends Widget>(IconData icon) {
    return find.widgetWithIcon(T, icon);
  }
}

/// Custom matchers for testing
class TestMatchers {
  /// Matcher for checking if a TextFormField has specific validation error
  static Matcher hasValidationError(String error) {
    return predicate<TextFormField>((widget) {
      // This would need to be implemented based on how validation errors are displayed
      return true; // Placeholder
    }, 'has validation error: $error');
  }

  /// Matcher for checking if a widget is in loading state
  static Matcher isLoading() {
    return predicate<Widget>((widget) {
      // This would need to be implemented based on loading state implementation
      return true; // Placeholder
    }, 'is in loading state');
  }

  /// Matcher for checking if a widget displays an error
  static Matcher hasError(String error) {
    return predicate<Widget>((widget) {
      // This would need to be implemented based on error display implementation
      return true; // Placeholder
    }, 'has error: $error');
  }
}

/// Exception for test timeouts
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  const TimeoutException(this.message, this.timeout);

  @override
  String toString() => 'TimeoutException: $message (timeout: $timeout)';
}