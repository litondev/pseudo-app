import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiHelper {
  static const String _baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080');
  static const String _apiPrefix = '/api/v1';
  static const _storage = FlutterSecureStorage();

  // Get full API URL
  static String getApiUrl(String endpoint) {
    return _baseUrl + _apiPrefix + endpoint;
  }

  // Get base headers
  static Map<String, String> getBaseHeaders() {
    return {
      'Accept': 'application/json',
    };
  }

  // Add Content-Type header for JSON
  static Map<String, String> addContentTypeJson(Map<String, String>? headers) {
    final Map<String, String> newHeaders = headers ?? {};
    newHeaders['Content-Type'] = 'application/json';
    return newHeaders;
  }

  // Add Authorization header
  static Future<Map<String, String>> addAuthorizationHeader(Map<String, String>? headers) async {
    final Map<String, String> newHeaders = headers ?? {};
    final String? token = await getAuthToken();
    
    if (token != null && token.isNotEmpty) {
      newHeaders['Authorization'] = 'Bearer $token';
    }
    
    return newHeaders;
  }

  // Get auth token from secure storage
  static Future<String?> getAuthToken() async {
    try {
      return await _storage.read(key: 'auth_token');
    } catch (e) {
      print('Error reading auth token: $e');
      return null;
    }
  }

  // Save auth token to secure storage
  static Future<void> saveAuthToken(String token) async {
    try {
      await _storage.write(key: 'auth_token', value: token);
    } catch (e) {
      print('Error saving auth token: $e');
    }
  }

  // Remove auth token from secure storage
  static Future<void> removeAuthToken() async {
    try {
      await _storage.delete(key: 'auth_token');
    } catch (e) {
      print('Error removing auth token: $e');
    }
  }

  // Prepare headers for authenticated requests
  static Future<Map<String, String>> prepareAuthHeaders({Map<String, String>? additionalHeaders}) async {
    Map<String, String> headers = getBaseHeaders();
    headers = addContentTypeJson(headers);
    headers = await addAuthorizationHeader(headers);
    
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    
    return headers;
  }

  // Prepare headers for public requests
  static Map<String, String> preparePublicHeaders({Map<String, String>? additionalHeaders}) {
    Map<String, String> headers = getBaseHeaders();
    headers = addContentTypeJson(headers);
    
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    
    return headers;
  }

  // Encode request body to JSON
  static String encodeBody(Map<String, dynamic> body) {
    return jsonEncode(body);
  }

  // Decode response body from JSON
  static Map<String, dynamic> decodeResponse(String responseBody) {
    try {
      return jsonDecode(responseBody);
    } catch (e) {
      throw FormatException('Invalid JSON response: $e');
    }
  }

  // Handle HTTP response
  static Map<String, dynamic> handleResponse(http.Response response) {
    final Map<String, dynamic> data = decodeResponse(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw HttpException(
        message: data['message'] ?? 'Unknown error occurred',
        statusCode: response.statusCode,
        data: data,
      );
    }
  }

  // Build query parameters
  static String buildQueryParams(Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) return '';
    
    final List<String> queryParts = [];
    params.forEach((key, value) {
      if (value != null) {
        queryParts.add('${Uri.encodeComponent(key)}=${Uri.encodeComponent(value.toString())}');
      }
    });
    
    return queryParts.isNotEmpty ? '?${queryParts.join('&')}' : '';
  }

  // Get full URL with query parameters
  static String getUrlWithParams(String endpoint, Map<String, dynamic>? params) {
    final String baseUrl = getApiUrl(endpoint);
    final String queryParams = buildQueryParams(params);
    return baseUrl + queryParams;
  }
}

// Custom HTTP Exception class
class HttpException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? data;

  HttpException({
    required this.message,
    required this.statusCode,
    this.data,
  });

  @override
  String toString() {
    return 'HttpException: $message (Status: $statusCode)';
  }
}