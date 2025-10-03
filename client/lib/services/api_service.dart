import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/auth.dart';
import 'storage_service.dart';

/// Service for handling API requests with authentication
class ApiService {
  static String get baseUrl => '${dotenv.env['API_URL'] ?? 'http://localhost:8000'}/api/v1';
  static const Duration timeoutDuration = Duration(seconds: 30);

  /// Get headers with authentication token
  static Future<Map<String, String>> _getHeaders({bool includeAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await StorageService.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Handle HTTP response and convert to ApiResponse
  static ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJsonT,
  ) {
    try {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>.fromJson(jsonData, fromJsonT);
      } else {
        return ApiResponse<T>(
          message: 'failed',
          error: jsonData['error'] ?? 'Request failed with status ${response.statusCode}',
          errors: jsonData['errors'] != null
              ? (jsonData['errors'] as List)
                  .map((e) => ValidationError.fromJson(e))
                  .toList()
              : null,
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        message: 'failed',
        error: 'Failed to parse response: $e',
      );
    }
  }

  /// Handle network exceptions
  static ApiResponse<T> _handleException<T>(dynamic e) {
    String errorMessage = 'Network error occurred';
    
    if (e is SocketException) {
      errorMessage = 'No internet connection';
    } else if (e is HttpException) {
      errorMessage = 'HTTP error: ${e.message}';
    } else if (e is FormatException) {
      errorMessage = 'Invalid response format';
    } else {
      errorMessage = 'Unexpected error: $e';
    }

    return ApiResponse<T>(
      message: 'failed',
      error: errorMessage,
    );
  }

  /// Make GET request
  static Future<ApiResponse<T>> get<T>(
    String endpoint, {
    bool requireAuth = false,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: requireAuth);
      final uri = Uri.parse('$baseUrl$endpoint');
      
      final response = await http
          .get(uri, headers: headers)
          .timeout(timeoutDuration);

      return _handleResponse<T>(response, fromJsonT);
    } catch (e) {
      return _handleException<T>(e);
    }
  }

  /// Make POST request
  static Future<ApiResponse<T>> post<T>(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = false,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: requireAuth);
      final uri = Uri.parse('$baseUrl$endpoint');
      
      final response = await http
          .post(
            uri,
            headers: headers,
            body: json.encode(body),
          )
          .timeout(timeoutDuration);

      return _handleResponse<T>(response, fromJsonT);
    } catch (e) {
      return _handleException<T>(e);
    }
  }

  /// Make PUT request
  static Future<ApiResponse<T>> put<T>(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = false,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: requireAuth);
      final uri = Uri.parse('$baseUrl$endpoint');
      
      final response = await http
          .put(
            uri,
            headers: headers,
            body: json.encode(body),
          )
          .timeout(timeoutDuration);

      return _handleResponse<T>(response, fromJsonT);
    } catch (e) {
      return _handleException<T>(e);
    }
  }

  /// Make DELETE request
  static Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    bool requireAuth = false,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: requireAuth);
      final uri = Uri.parse('$baseUrl$endpoint');
      
      final response = await http
          .delete(uri, headers: headers)
          .timeout(timeoutDuration);

      return _handleResponse<T>(response, fromJsonT);
    } catch (e) {
      return _handleException<T>(e);
    }
  }

  /// Check if response indicates token expiration
  static bool isTokenExpired(ApiResponse response) {
    return response.error?.toLowerCase().contains('token') == true ||
           response.error?.toLowerCase().contains('unauthorized') == true ||
           response.error?.toLowerCase().contains('expired') == true;
  }

  /// Get network status information
  static Future<bool> checkConnectivity() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}