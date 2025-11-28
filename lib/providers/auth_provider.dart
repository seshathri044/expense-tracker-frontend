// lib/providers/auth_provider.dart
// ✅ FIXED: Fetch profile after login to get the actual user name from database

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_models.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isAuthenticated => _token != null && _user != null;

  /// Initialize auth state from storage
  Future<void> initAuth() async {
    _isLoading = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(AppConfig.tokenKey);
      
      if (_token != null) {
        // 🔥 CRITICAL: Fetch fresh profile from backend to get current user data
        try {
          _user = await _authService.getProfile();
          
          // Save to SharedPreferences for offline access
          await prefs.setString(AppConfig.userIdKey, _user!.id);
          await prefs.setString(AppConfig.userNameKey, _user!.name);
          await prefs.setString(AppConfig.userEmailKey, _user!.email);
          
          print('✅ User profile loaded: ${_user!.name}');
        } catch (e) {
          // If profile fetch fails, try loading from local storage
          final userId = prefs.getString(AppConfig.userIdKey);
          final userName = prefs.getString(AppConfig.userNameKey);
          final userEmail = prefs.getString(AppConfig.userEmailKey);
          
          if (userId != null && userName != null && userEmail != null) {
            _user = User(
              id: userId,
              name: userName,
              email: userEmail,
              isVerified: true,
              createdAt: DateTime.now(),
            );
            print('✅ User loaded from storage: ${_user!.name}');
          } else {
            print('⚠️ Profile fetch failed and no local data');
            _token = null;
          }
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to initialize auth';
      debugPrint('❌ Auth init error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Register - Step 1: Initiate registration (doesn't save to DB yet)
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _authService.register(name, email, password);
      
      if (response.success) {
        _successMessage = response.message ?? 'Registration initiated. Please verify your email.';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Send Verification OTP - Step 2: Request OTP via email
  Future<bool> sendVerificationOtp(String email) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _authService.sendVerificationOtp(email);
      _isLoading = false;
      
      if (response.success) {
        _successMessage = response.message ?? 'OTP sent successfully to your email';
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to send OTP';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verify OTP - Step 3: Verify OTP, save user to DB, and log in
  Future<bool> verifyOtp(String email, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _authService.verifyOtp(email, otp);
      
      if (response.success && response.token != null) {
        _token = response.token;
        
        // 🔥 CRITICAL: Fetch profile from backend to get the actual user name
        try {
          _user = await _authService.getProfile();
          await _saveAuthData();
          print('✅ Profile fetched after OTP: ${_user!.name}');
        } catch (e) {
          print('⚠️ Could not fetch profile after OTP: $e');
        }
        
        _successMessage = response.message ?? 'Account verified successfully';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'OTP verification failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 🔥 CRITICAL FIX: Login and fetch profile from backend
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);
      
      if (response.success && response.token != null) {
        _token = response.token;
        
        // 🔥 CRITICAL: Fetch profile from backend to get the actual user name from database
        try {
          _user = await _authService.getProfile();
          await _saveAuthData();
          print('✅ Profile fetched after login: ${_user!.name}');
        } catch (e) {
          print('❌ Failed to fetch profile: $e');
          _errorMessage = 'Login successful but could not load profile';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        
        _successMessage = 'Login successful';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Forgot Password - Send reset OTP
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _authService.forgotPassword(email);
      _isLoading = false;
      
      if (response.success) {
        _successMessage = response.message ?? 'Reset OTP sent to your email';
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to send reset code';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Reset Password with OTP
  Future<bool> resetPassword(String email, String otp, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _authService.resetPassword(email, otp, newPassword);
      _isLoading = false;
      
      if (response.success) {
        _successMessage = response.message ?? 'Password reset successfully';
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to reset password';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      debugPrint('❌ Logout error: $e');
    }
    
    _token = null;
    _user = null;
    _errorMessage = null;
    _successMessage = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    notifyListeners();
  }

  /// Save auth data to local storage
  Future<void> _saveAuthData() async {
    if (_token != null && _user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.tokenKey, _token!);
      await prefs.setString(AppConfig.userIdKey, _user!.id);
      await prefs.setString(AppConfig.userNameKey, _user!.name);
      await prefs.setString(AppConfig.userEmailKey, _user!.email);
      print('💾 Saved user data - Name: ${_user!.name}, Email: ${_user!.email}');
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear success message
  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }
}