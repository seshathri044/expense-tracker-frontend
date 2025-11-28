import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String baseUrl = AppConfig.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.tokenKey);
  }

  Map<String, String> _getHeaders(String? token, {bool isMultipart = false}) {
    final headers = <String, String>{};
    
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // GET request
  Future<http.Response> get(String endpoint, {bool requiresAuth = true}) async {
    try {
      final token = requiresAuth ? await _getToken() : null;
      final uri = Uri.parse('$baseUrl$endpoint');
      
      final response = await http.get(
        uri,
        headers: _getHeaders(token),
      ).timeout(const Duration(seconds: 30));
      
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final token = requiresAuth ? await _getToken() : null;
      final uri = Uri.parse('$baseUrl$endpoint');
      
      final response = await http.post(
        uri,
        headers: _getHeaders(token),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));
      
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final token = requiresAuth ? await _getToken() : null;
      final uri = Uri.parse('$baseUrl$endpoint');
      
      final response = await http.put(
        uri,
        headers: _getHeaders(token),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));
      
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<http.Response> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final token = requiresAuth ? await _getToken() : null;
      final uri = Uri.parse('$baseUrl$endpoint');
      
      final response = await http.delete(
        uri,
        headers: _getHeaders(token),
      ).timeout(const Duration(seconds: 30));
      
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PATCH request
  Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final token = requiresAuth ? await _getToken() : null;
      final uri = Uri.parse('$baseUrl$endpoint');
      
      final response = await http.patch(
        uri,
        headers: _getHeaders(token),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));
      
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Handle response errors
  String handleError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return data['message'] ?? 'An error occurred';
    } catch (e) {
      return 'Network error occurred';
    }
  }

  // Check if response is successful
  bool isSuccessful(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }
}