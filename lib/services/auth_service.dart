import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user_models.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  /// Register new user (Step 1: Initiate registration)
  Future<AuthResponse> register(String name, String email, String password) async {
    try {
      final response = await _apiService.post(
        '/register',
        {
          'name': name,
          'email': email,
          'password': password,
        },
        requiresAuth: false,
      );

      print('📥 Register response: ${response.statusCode}');
      print('📦 Register body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return AuthResponse.fromJson(data);
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print('❌ Register error: $e');
      throw Exception(_cleanErrorMessage(e.toString()));
    }
  }

  /// Send OTP for email verification (Step 2: Request OTP)
  Future<ApiResponse<void>> sendVerificationOtp(String email) async {
    try {
      final response = await _apiService.post(
        '/send-otp',
        {'email': email},
        requiresAuth: false,
      );

      print('📥 Send OTP response: ${response.statusCode}');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(message: data['message']);
      } else {
        throw Exception(data['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      return ApiResponse.error(message: _cleanErrorMessage(e.toString()));
    }
  }

  /// Verify OTP and complete registration (Step 3: Verify & Save to DB)
  Future<AuthResponse> verifyOtp(String email, String otp) async {
    try {
      final response = await _apiService.post(
        '/verify-otp',
        {
          'email': email,
          'otp': otp,
        },
        requiresAuth: false,
      );

      print('📥 Verify OTP response: ${response.statusCode}');
      print('📦 Verify OTP body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        if (data['token'] != null) {
          await _saveToken(data['token']);
          
          // 🔥 CRITICAL: Extract name from JWT token
          final name = _extractNameFromToken(data['token']) ?? email.split('@')[0];
          
          // Save user data
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(AppConfig.userNameKey, name);
          await prefs.setString(AppConfig.userEmailKey, email);
          
          print('✅ Saved user data - Name: $name, Email: $email');
        }
        return AuthResponse.fromJson(data);
      } else {
        throw Exception(data['message'] ?? 'Invalid OTP');
      }
    } catch (e) {
      print('❌ Verify OTP error: $e');
      throw Exception(_cleanErrorMessage(e.toString()));
    }
  }

  /// 🔥 CRITICAL FIX: Login with username extraction from JWT
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        '/login',
        {
          'email': email,
          'password': password,
        },
        requiresAuth: false,
      );

      print('📥 Login response: ${response.statusCode}');
      print('📦 Login body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['token'] != null) {
          await _saveToken(data['token']);
          
          // 🔥 CRITICAL FIX: Extract name from JWT token
          final name = _extractNameFromToken(data['token']) ?? email.split('@')[0];
          
          // Save user data to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(AppConfig.userNameKey, name);
          await prefs.setString(AppConfig.userEmailKey, data['email'] ?? email);
          
          print('✅ Login successful - Name: $name, Email: ${data['email'] ?? email}');
        }
        
        return AuthResponse.fromJson(data);
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('❌ Login error: $e');
      throw Exception(_cleanErrorMessage(e.toString()));
    }
  }

  /// 🔥 NEW: Extract name from JWT token
  String? _extractNameFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode the payload (second part)
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> payloadMap = jsonDecode(decoded);

      print('🔓 JWT Payload: $payloadMap');

      // Extract name (might be in 'name' or 'sub' field)
      return payloadMap['name'] ?? payloadMap['sub'];
    } catch (e) {
      print('⚠️ Failed to decode JWT: $e');
      return null;
    }
  }

  /// Send OTP for password reset
  Future<ApiResponse<void>> forgotPassword(String email) async {
    try {
      final response = await _apiService.post(
        '/send-reset-otp',
        {'email': email},
        requiresAuth: false,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(message: data['message']);
      } else {
        throw Exception(data['message'] ?? 'Failed to send reset OTP');
      }
    } catch (e) {
      return ApiResponse.error(message: _cleanErrorMessage(e.toString()));
    }
  }

  Future<ApiResponse<void>> sendResetOtp(String email) async {
    return forgotPassword(email);
  }

  /// Reset password with OTP
  Future<ApiResponse<void>> resetPassword(String email, String otp, String newPassword) async {
    try {
      final response = await _apiService.post(
        '/reset-password',
        {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        },
        requiresAuth: false,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(message: data['message']);
      } else {
        throw Exception(data['message'] ?? 'Password reset failed');
      }
    } catch (e) {
      return ApiResponse.error(message: _cleanErrorMessage(e.toString()));
    }
  }

  /// Get user profile
  Future<User> getProfile() async {
    try {
      final response = await _apiService.get('/profile', requiresAuth: true);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['error'] == false) {
        return User.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to load profile');
      }
    } catch (e) {
      throw Exception(_cleanErrorMessage(e.toString()));
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final response = await _apiService.get('/is-authenticated', requiresAuth: true);
      final data = jsonDecode(response.body);
      return data['authenticated'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _apiService.post('/logout', {}, requiresAuth: true);
      await _clearToken();
    } catch (e) {
      await _clearToken();
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.tokenKey, token);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.tokenKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.tokenKey);
  }

  /// Clean error messages
  String _cleanErrorMessage(String error) {
    return error
        .replaceAll('Exception: ', '')
        .replaceAll('Network error: ', '')
        .replaceAll('Registration error: ', '')
        .replaceAll('Login error: ', '')
        .replaceAll('OTP verification error: ', '')
        .replaceAll('Profile error: ', '')
        .trim();
  }
}