import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Token operations
  Future<bool> saveToken(String token) async {
    return await prefs.setString(AppConfig.tokenKey, token);
  }

  String? getToken() {
    return prefs.getString(AppConfig.tokenKey);
  }

  Future<bool> removeToken() async {
    return await prefs.remove(AppConfig.tokenKey);
  }

  // User operations
  Future<bool> saveUserId(String userId) async {
    return await prefs.setString(AppConfig.userIdKey, userId);
  }

  String? getUserId() {
    return prefs.getString(AppConfig.userIdKey);
  }

  Future<bool> saveUserName(String userName) async {
    return await prefs.setString(AppConfig.userNameKey, userName);
  }

  String? getUserName() {
    return prefs.getString(AppConfig.userNameKey);
  }

  Future<bool> saveUserEmail(String userEmail) async {
    return await prefs.setString(AppConfig.userEmailKey, userEmail);
  }

  String? getUserEmail() {
    return prefs.getString(AppConfig.userEmailKey);
  }

  // Clear all data
  Future<bool> clearAll() async {
    return await prefs.clear();
  }

  // Generic string operations
  Future<bool> saveString(String key, String value) async {
    return await prefs.setString(key, value);
  }

  String? getString(String key) {
    return prefs.getString(key);
  }

  // Generic int operations
  Future<bool> saveInt(String key, int value) async {
    return await prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return prefs.getInt(key);
  }

  // Generic bool operations
  Future<bool> saveBool(String key, bool value) async {
    return await prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return prefs.getBool(key);
  }

  // Generic double operations
  Future<bool> saveDouble(String key, double value) async {
    return await prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return prefs.getDouble(key);
  }

  // Remove specific key
  Future<bool> remove(String key) async {
    return await prefs.remove(key);
  }

  // Check if key exists
  bool containsKey(String key) {
    return prefs.containsKey(key);
  }
}