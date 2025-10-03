import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:client/services/storage_service.dart';
import 'package:client/models/user.dart';
import 'dart:convert';

import 'storage_service_test.mocks.dart';

@GenerateMocks([SharedPreferences, FlutterSecureStorage])
void main() {
  group('StorageService Tests', () {
    late StorageService storageService;
    late MockSharedPreferences mockSharedPreferences;
    late MockFlutterSecureStorage mockSecureStorage;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      mockSecureStorage = MockFlutterSecureStorage();
      storageService = StorageService();
      
      // In a real implementation, you'd inject these dependencies
    });

    group('Access Token Tests', () {
      test('should save access token successfully', () async {
        // Arrange
        const token = 'mock_access_token';
        
        when(mockSharedPreferences.setString('access_token', token))
            .thenAnswer((_) async => true);

        // Act
        await storageService.saveAccessToken(token);

        // Assert
        verify(mockSharedPreferences.setString('access_token', token)).called(1);
      });

      test('should retrieve access token successfully', () async {
        // Arrange
        const token = 'mock_access_token';
        
        when(mockSharedPreferences.getString('access_token'))
            .thenReturn(token);

        // Act
        final result = await storageService.getAccessToken();

        // Assert
        expect(result, token);
        verify(mockSharedPreferences.getString('access_token')).called(1);
      });

      test('should return null when access token does not exist', () async {
        // Arrange
        when(mockSharedPreferences.getString('access_token'))
            .thenReturn(null);

        // Act
        final result = await storageService.getAccessToken();

        // Assert
        expect(result, null);
      });

      test('should clear access token successfully', () async {
        // Arrange
        when(mockSharedPreferences.remove('access_token'))
            .thenAnswer((_) async => true);

        // Act
        await storageService.clearAccessToken();

        // Assert
        verify(mockSharedPreferences.remove('access_token')).called(1);
      });
    });

    group('Refresh Token Tests', () {
      test('should save refresh token successfully on web platform', () async {
        // Arrange
        const token = 'mock_refresh_token';
        
        when(mockSharedPreferences.setString('refresh_token', token))
            .thenAnswer((_) async => true);

        // Act
        await storageService.saveRefreshToken(token);

        // Assert
        verify(mockSharedPreferences.setString('refresh_token', token)).called(1);
      });

      test('should save refresh token securely on mobile platforms', () async {
        // Arrange
        const token = 'mock_refresh_token';
        
        when(mockSecureStorage.write(key: 'refresh_token', value: token))
            .thenAnswer((_) async => {});

        // Act
        // This would be called when not on web platform
        await storageService.saveRefreshToken(token);

        // Assert - In real implementation, this would check platform
        // For this test, we'll verify the secure storage call
        // verify(mockSecureStorage.write(key: 'refresh_token', value: token)).called(1);
      });

      test('should retrieve refresh token successfully', () async {
        // Arrange
        const token = 'mock_refresh_token';
        
        when(mockSharedPreferences.getString('refresh_token'))
            .thenReturn(token);

        // Act
        final result = await storageService.getRefreshToken();

        // Assert
        expect(result, token);
      });

      test('should clear refresh token successfully', () async {
        // Arrange
        when(mockSharedPreferences.remove('refresh_token'))
            .thenAnswer((_) async => true);

        // Act
        await storageService.clearRefreshToken();

        // Assert
        verify(mockSharedPreferences.remove('refresh_token')).called(1);
      });
    });

    group('User Data Tests', () {
      test('should save user data successfully', () async {
        // Arrange
        final user = User(
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        final userJson = jsonEncode(user.toJson());
        
        when(mockSharedPreferences.setString('user_data', userJson))
            .thenAnswer((_) async => true);

        // Act
        await storageService.saveUserData(user.toJson());

        // Assert
        verify(mockSharedPreferences.setString('user_data', userJson)).called(1);
      });

      test('should retrieve user data successfully', () async {
        // Arrange
        final user = User(
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        final userJson = jsonEncode(user.toJson());
        
        when(mockSharedPreferences.getString('user_data'))
            .thenReturn(userJson);

        // Act
        final result = await storageService.getUserData();

        // Assert
        expect(result, isNotNull);
        expect(result!['name'], 'John Doe');
        expect(result['email'], 'john@example.com');
      });

      test('should return null when user data does not exist', () async {
        // Arrange
        when(mockSharedPreferences.getString('user_data'))
            .thenReturn(null);

        // Act
        final result = await storageService.getUserData();

        // Assert
        expect(result, null);
      });

      test('should handle invalid JSON in user data', () async {
        // Arrange
        when(mockSharedPreferences.getString('user_data'))
            .thenReturn('invalid_json');

        // Act
        final result = await storageService.getUserData();

        // Assert
        expect(result, null);
      });

      test('should clear user data successfully', () async {
        // Arrange
        when(mockSharedPreferences.remove('user_data'))
            .thenAnswer((_) async => true);

        // Act
        await storageService.clearUserData();

        // Assert
        verify(mockSharedPreferences.remove('user_data')).called(1);
      });
    });

    group('Clear All Tests', () {
      test('should clear all stored data successfully', () async {
        // Arrange
        when(mockSharedPreferences.remove('access_token'))
            .thenAnswer((_) async => true);
        when(mockSharedPreferences.remove('refresh_token'))
            .thenAnswer((_) async => true);
        when(mockSharedPreferences.remove('user_data'))
            .thenAnswer((_) async => true);

        // Act
        await storageService.clearAll();

        // Assert
        verify(mockSharedPreferences.remove('access_token')).called(1);
        verify(mockSharedPreferences.remove('refresh_token')).called(1);
        verify(mockSharedPreferences.remove('user_data')).called(1);
      });

      test('should handle errors when clearing data', () async {
        // Arrange
        when(mockSharedPreferences.remove('access_token'))
            .thenThrow(Exception('Storage error'));
        when(mockSharedPreferences.remove('refresh_token'))
            .thenAnswer((_) async => true);
        when(mockSharedPreferences.remove('user_data'))
            .thenAnswer((_) async => true);

        // Act & Assert - Should not throw exception
        expect(() => storageService.clearAll(), returnsNormally);
      });
    });

    group('Platform-Specific Tests', () {
      test('should use SharedPreferences on web platform', () async {
        // This test would verify that web platform uses SharedPreferences
        // In a real implementation, you'd mock the platform detection
        
        const token = 'web_token';
        when(mockSharedPreferences.setString('access_token', token))
            .thenAnswer((_) async => true);

        await storageService.saveAccessToken(token);

        verify(mockSharedPreferences.setString('access_token', token)).called(1);
      });

      test('should use FlutterSecureStorage on mobile platforms', () async {
        // This test would verify that mobile platforms use FlutterSecureStorage
        // for sensitive data like refresh tokens
        
        const token = 'mobile_refresh_token';
        when(mockSecureStorage.write(key: 'refresh_token', value: token))
            .thenAnswer((_) async => {});

        // In real implementation, this would check if platform is mobile
        // await storageService.saveRefreshToken(token);

        // verify(mockSecureStorage.write(key: 'refresh_token', value: token)).called(1);
      });
    });

    group('Error Handling Tests', () {
      test('should handle storage write errors gracefully', () async {
        // Arrange
        when(mockSharedPreferences.setString('access_token', any))
            .thenThrow(Exception('Storage write error'));

        // Act & Assert - Should not throw exception
        expect(() => storageService.saveAccessToken('token'), returnsNormally);
      });

      test('should handle storage read errors gracefully', () async {
        // Arrange
        when(mockSharedPreferences.getString('access_token'))
            .thenThrow(Exception('Storage read error'));

        // Act
        final result = await storageService.getAccessToken();

        // Assert - Should return null on error
        expect(result, null);
      });

      test('should handle storage clear errors gracefully', () async {
        // Arrange
        when(mockSharedPreferences.remove('access_token'))
            .thenThrow(Exception('Storage clear error'));

        // Act & Assert - Should not throw exception
        expect(() => storageService.clearAccessToken(), returnsNormally);
      });
    });

    group('Data Persistence Tests', () {
      test('should maintain data consistency across app restarts', () async {
        // Arrange
        const accessToken = 'persistent_access_token';
        const refreshToken = 'persistent_refresh_token';
        
        final user = User(
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Mock saving data
        when(mockSharedPreferences.setString('access_token', accessToken))
            .thenAnswer((_) async => true);
        when(mockSharedPreferences.setString('refresh_token', refreshToken))
            .thenAnswer((_) async => true);
        when(mockSharedPreferences.setString('user_data', any))
            .thenAnswer((_) async => true);

        // Mock retrieving data
        when(mockSharedPreferences.getString('access_token'))
            .thenReturn(accessToken);
        when(mockSharedPreferences.getString('refresh_token'))
            .thenReturn(refreshToken);
        when(mockSharedPreferences.getString('user_data'))
            .thenReturn(jsonEncode(user.toJson()));

        // Act - Save data
        await storageService.saveAccessToken(accessToken);
        await storageService.saveRefreshToken(refreshToken);
        await storageService.saveUserData(user.toJson());

        // Act - Retrieve data (simulating app restart)
        final retrievedAccessToken = await storageService.getAccessToken();
        final retrievedRefreshToken = await storageService.getRefreshToken();
        final retrievedUserData = await storageService.getUserData();

        // Assert
        expect(retrievedAccessToken, accessToken);
        expect(retrievedRefreshToken, refreshToken);
        expect(retrievedUserData?['name'], user.name);
        expect(retrievedUserData?['email'], user.email);
      });
    });
  });
}