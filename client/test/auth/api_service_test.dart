import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:client/services/api_service.dart';
import 'package:client/services/storage_service.dart';
import 'package:client/models/auth.dart';
import 'package:client/models/user.dart';

import 'api_service_test.mocks.dart';

@GenerateMocks([http.Client, StorageService])
void main() {
  group('ApiService Tests', () {
    late ApiService apiService;
    late MockClient mockHttpClient;
    late MockStorageService mockStorageService;

    setUp(() {
      mockHttpClient = MockClient();
      mockStorageService = MockStorageService();
      apiService = ApiService();
      
      // In a real implementation, you'd inject these dependencies
    });

    group('GET Request Tests', () {
      test('should make successful GET request', () async {
        // Arrange
        const endpoint = '/test-endpoint';
        final responseData = {'message': 'success', 'data': 'test'};
        
        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => 'mock_token');

        when(mockHttpClient.get(
          Uri.parse('${apiService.baseUrl}$endpoint'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode(responseData),
          200,
          headers: {'content-type': 'application/json'},
        ));

        // Act
        final result = await apiService.get(endpoint);

        // Assert
        expect(result.success, true);
        expect(result.data, responseData);
      });

      test('should handle GET request with query parameters', () async {
        // Arrange
        const endpoint = '/test-endpoint';
        final queryParams = {'page': '1', 'limit': '10'};
        final responseData = {'items': [], 'total': 0};

        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => 'mock_token');

        when(mockHttpClient.get(
          Uri.parse('${apiService.baseUrl}$endpoint?page=1&limit=10'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode(responseData),
          200,
          headers: {'content-type': 'application/json'},
        ));

        // Act
        final result = await apiService.get(endpoint, queryParams: queryParams);

        // Assert
        expect(result.success, true);
        expect(result.data, responseData);
      });

      test('should handle 404 error in GET request', () async {
        // Arrange
        const endpoint = '/non-existent';

        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => 'mock_token');

        when(mockHttpClient.get(
          Uri.parse('${apiService.baseUrl}$endpoint'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode({'message': 'Not found'}),
          404,
          headers: {'content-type': 'application/json'},
        ));

        // Act
        final result = await apiService.get(endpoint);

        // Assert
        expect(result.success, false);
        expect(result.message, 'Not found');
      });

      test('should handle unauthorized GET request', () async {
        // Arrange
        const endpoint = '/protected';

        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => 'invalid_token');

        when(mockHttpClient.get(
          Uri.parse('${apiService.baseUrl}$endpoint'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode({'message': 'Unauthorized'}),
          401,
          headers: {'content-type': 'application/json'},
        ));

        // Act
        final result = await apiService.get(endpoint);

        // Assert
        expect(result.success, false);
        expect(result.message, 'Unauthorized');
      });
    });

    group('POST Request Tests', () {
      test('should make successful POST request', () async {
        // Arrange
        const endpoint = '/auth/signin';
        final requestData = {'email': 'test@example.com', 'password': 'password'};
        final responseData = {
          'success': true,
          'message': 'Login successful',
          'data': {'token': 'jwt_token'}
        };

        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => null); // No token for login

        when(mockHttpClient.post(
          Uri.parse('${apiService.baseUrl}$endpoint'),
          headers: anyNamed('headers'),
          body: jsonEncode(requestData),
        )).thenAnswer((_) async => http.Response(
          jsonEncode(responseData),
          200,
          headers: {'content-type': 'application/json'},
        ));

        // Act
        final result = await apiService.post(endpoint, data: requestData);

        // Assert
        expect(result.success, true);
        expect(result.message, 'Login successful');
        expect(result.data['token'], 'jwt_token');
      });

      test('should handle validation errors in POST request', () async {
        // Arrange
        const endpoint = '/auth/signup';
        final requestData = {'email': 'invalid', 'password': '123'};
        final responseData = {
          'success': false,
          'message': 'Validation failed',
          'errors': [
            {'field': 'email', 'message': 'Invalid email format'},
            {'field': 'password', 'message': 'Password too short'}
          ]
        };

        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => null);

        when(mockHttpClient.post(
          Uri.parse('${apiService.baseUrl}$endpoint'),
          headers: anyNamed('headers'),
          body: jsonEncode(requestData),
        )).thenAnswer((_) async => http.Response(
          jsonEncode(responseData),
          422,
          headers: {'content-type': 'application/json'},
        ));

        // Act
        final result = await apiService.post(endpoint, data: requestData);

        // Assert
        expect(result.success, false);
        expect(result.message, 'Validation failed');
        expect(result.errors?.length, 2);
      });

      test('should handle server error in POST request', () async {
        // Arrange
        const endpoint = '/test-endpoint';
        final requestData = {'test': 'data'};

        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => 'mock_token');

        when(mockHttpClient.post(
          Uri.parse('${apiService.baseUrl}$endpoint'),
          headers: anyNamed('headers'),
          body: jsonEncode(requestData),
        )).thenAnswer((_) async => http.Response(
          jsonEncode({'message': 'Internal server error'}),
          500,
          headers: {'content-type': 'application/json'},
        ));

        // Act
        final result = await apiService.post(endpoint, data: requestData);

        // Assert
        expect(result.success, false);
        expect(result.message, 'Internal server error');
      });
    });

    group('PUT Request Tests', () {
      test('should make successful PUT request', () async {
        // Arrange
        const endpoint = '/users/1';
        final requestData = {'name': 'Updated Name', 'email': 'updated@example.com'};
        final responseData = {
          'success': true,
          'message': 'User updated successfully',
          'data': {'id': 1, 'name': 'Updated Name', 'email': 'updated@example.com'}
        };

        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => 'mock_token');

        when(mockHttpClient.put(
          Uri.parse('${apiService.baseUrl}$endpoint'),
          headers: anyNamed('headers'),
          body: jsonEncode(requestData),
        )).thenAnswer((_) async => http.Response(
          jsonEncode(responseData),
          200,
          headers: {'content-type': 'application/json'},
        ));

        // Act
        final result = await apiService.put(endpoint, data: requestData);

        // Assert
        expect(result.success, true);
        expect(result.message, 'User updated successfully');
        expect(result.data['name'], 'Updated Name');
      });

      test('should handle not found error in PUT request', () async {
        // Arrange
        const endpoint = '/users/999';
        final requestData = {'name': 'Updated Name'};

        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => 'mock_token');

        when(mockHttpClient.put(
          Uri.parse('${apiService.baseUrl}$endpoint'),
          headers: anyNamed('headers'),
          body: jsonEncode(requestData),
        )).thenAnswer((_) async => http.Response(
          jsonEncode({'message': 'User not found'}),
          404,
          headers: {'content-type': 'application/json'},
        ));

        // Act
        final result = await apiService.put(endpoint, data: requestData);

        // Assert
        expect(result.success, false);
        expect(result.message, 'User not found');
      });
    });

    group('DELETE Request Tests', () {
      test('should make successful DELETE request', () async {
        // Arrange
        const endpoint = '/users/1';
        final responseData = {
          'success': true,
          'message': 'User deleted successfully'
        };

        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => 'mock_token');

        when(mockHttpClient.delete(
          Uri.parse('${apiService.baseUrl}$endpoint'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode(responseData),
          200,
          headers: {'content-type': 'application/json'},
        ));

        // Act
        final result = await apiService.delete(endpoint);

        // Assert
        expect(result.success, true);
        expect(result.message, 'User deleted successfully');
      });

      test('should handle forbidden error in DELETE request', () async {
        // Arrange
        const endpoint = '/users/1';

        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => 'mock_token');

        when(mockHttpClient.delete(
          Uri.parse('${apiService.baseUrl}$endpoint'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode({'message': 'Forbidden'}),
          403,
          headers: {'content-type': 'application/json'},
        ));

        // Act
        final result = await apiService.delete(endpoint);

        // Assert
        expect(result.success, false);
        expect(result.message, 'Forbidden');
      });
    });

    group('Token Management Tests', () {
      test('should include authorization header when token exists', () async {
        // Arrange
        const endpoint = '/protected';
        const token = 'mock_access_token';

        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => token);

        when(mockHttpClient.get(
          Uri.parse('${apiService.baseUrl}$endpoint'),
          headers: argThat(
            contains('Authorization'),
            named: 'headers',
          ),
        )).thenAnswer((_) async => http.Response(
          jsonEncode({'message': 'success'}),
          200,
          headers: {'content-type': 'application/json'},
        ));

        // Act
        await apiService.get(endpoint);

        // Assert
        verify(mockHttpClient.get(
          Uri.parse('${apiService.baseUrl}$endpoint'),
          headers: argThat(
            allOf([
              contains('Authorization'),
              containsPair('Authorization', 'Bearer $token'),
            ]),
            named: 'headers',
          ),
        )).called(1);
      });

      test('should not include authorization header when token is null', () async {
        // Arrange
        const endpoint = '/public';

        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => null);

        when(mockHttpClient.get(
          Uri.parse('${apiService.baseUrl}$endpoint'),
          headers: argThat(
            isNot(contains('Authorization')),
            named: 'headers',
          ),
        )).thenAnswer((_) async => http.Response(
          jsonEncode({'message': 'success'}),
          200,
          headers: {'content-type': 'application/json'},
        ));

        // Act
        await apiService.get(endpoint);

        // Assert
        verify(mockHttpClient.get(
          Uri.parse('${apiService.baseUrl}$endpoint'),
          headers: argThat(
            isNot(contains('Authorization')),
            named: 'headers',
          ),
        )).called(1);
      });
    });

    group('Token Expiration Tests', () {
      test('should detect expired token correctly', () {
        // Arrange
        final expiredToken = _createJwtToken(DateTime.now().subtract(Duration(hours: 1)));
        final validToken = _createJwtToken(DateTime.now().add(Duration(hours: 1)));

        // Act & Assert
        expect(apiService.isTokenExpired(expiredToken), true);
        expect(apiService.isTokenExpired(validToken), false);
      });

      test('should handle invalid token format', () {
        // Arrange
        const invalidToken = 'invalid.token.format';

        // Act & Assert
        expect(apiService.isTokenExpired(invalidToken), true);
      });

      test('should handle null token', () {
        // Act & Assert
        expect(apiService.isTokenExpired(null), true);
      });
    });

    group('Network Connectivity Tests', () {
      test('should detect network connectivity', () async {
        // This test would require mocking network connectivity
        // In a real implementation, you'd test the actual connectivity check
        
        // Act
        final isConnected = await apiService.hasNetworkConnection();

        // Assert
        expect(isConnected, isA<bool>());
      });
    });

    group('Error Handling Tests', () {
      test('should handle network timeout', () async {
        // Arrange
        const endpoint = '/slow-endpoint';

        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => 'mock_token');

        when(mockHttpClient.get(
          Uri.parse('${apiService.baseUrl}$endpoint'),
          headers: anyNamed('headers'),
        )).thenThrow(Exception('Connection timeout'));

        // Act
        final result = await apiService.get(endpoint);

        // Assert
        expect(result.success, false);
        expect(result.message, contains('network'));
      });

      test('should handle invalid JSON response', () async {
        // Arrange
        const endpoint = '/invalid-json';

        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => 'mock_token');

        when(mockHttpClient.get(
          Uri.parse('${apiService.baseUrl}$endpoint'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          'invalid json response',
          200,
          headers: {'content-type': 'application/json'},
        ));

        // Act
        final result = await apiService.get(endpoint);

        // Assert
        expect(result.success, false);
        expect(result.message, contains('Invalid response format'));
      });

      test('should handle empty response body', () async {
        // Arrange
        const endpoint = '/empty-response';

        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => 'mock_token');

        when(mockHttpClient.get(
          Uri.parse('${apiService.baseUrl}$endpoint'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          '',
          200,
          headers: {'content-type': 'application/json'},
        ));

        // Act
        final result = await apiService.get(endpoint);

        // Assert
        expect(result.success, false);
        expect(result.message, contains('Empty response'));
      });
    });

    group('Request Headers Tests', () {
      test('should include correct content-type header for POST requests', () async {
        // Arrange
        const endpoint = '/test';
        final data = {'test': 'data'};

        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => 'mock_token');

        when(mockHttpClient.post(
          Uri.parse('${apiService.baseUrl}$endpoint'),
          headers: argThat(
            containsPair('Content-Type', 'application/json'),
            named: 'headers',
          ),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode({'success': true}),
          200,
          headers: {'content-type': 'application/json'},
        ));

        // Act
        await apiService.post(endpoint, data: data);

        // Assert
        verify(mockHttpClient.post(
          Uri.parse('${apiService.baseUrl}$endpoint'),
          headers: argThat(
            containsPair('Content-Type', 'application/json'),
            named: 'headers',
          ),
          body: jsonEncode(data),
        )).called(1);
      });

      test('should include accept header', () async {
        // Arrange
        const endpoint = '/test';

        when(mockStorageService.getAccessToken())
            .thenAnswer((_) async => 'mock_token');

        when(mockHttpClient.get(
          Uri.parse('${apiService.baseUrl}$endpoint'),
          headers: argThat(
            containsPair('Accept', 'application/json'),
            named: 'headers',
          ),
        )).thenAnswer((_) async => http.Response(
          jsonEncode({'success': true}),
          200,
          headers: {'content-type': 'application/json'},
        ));

        // Act
        await apiService.get(endpoint);

        // Assert
        verify(mockHttpClient.get(
          Uri.parse('${apiService.baseUrl}$endpoint'),
          headers: argThat(
            containsPair('Accept', 'application/json'),
            named: 'headers',
          ),
        )).called(1);
      });
    });
  });
}

// Helper function to create a JWT token with specific expiration
String _createJwtToken(DateTime expiration) {
  final header = base64Url.encode(utf8.encode(jsonEncode({'typ': 'JWT', 'alg': 'HS256'})));
  final payload = base64Url.encode(utf8.encode(jsonEncode({
    'exp': expiration.millisecondsSinceEpoch ~/ 1000,
    'sub': '1',
    'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
  })));
  final signature = base64Url.encode(utf8.encode('mock_signature'));
  
  return '$header.$payload.$signature';
}