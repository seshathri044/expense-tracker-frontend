import 'environment.dart';

class AppConfig {
  // Use Environment baseUrl
  static String get baseUrl => Environment.baseUrl;
  
  // API Endpoints (these are appended to baseUrl)
  static const String authEndpoint = '';
  static const String expenseEndpoint = '/expense';
  static const String incomeEndpoint = '/income';
  static const String statsEndpoint = '/stats';
  
  // Full URLs for convenience
  static String get authUrl => '$baseUrl$authEndpoint';
  static String get expenseUrl => '$baseUrl$expenseEndpoint';
  static String get incomeUrl => '$baseUrl$incomeEndpoint';
  static String get statsUrl => '$baseUrl$statsEndpoint';
  
  // Storage Keys
  static String get tokenKey => Environment.tokenKey;
  static String get userIdKey => Environment.userIdKey;
  static String get userNameKey => Environment.userNameKey;
  static String get userEmailKey => Environment.userEmailKey;
  
  // App Settings
  static String get appName => Environment.appName;
  static int get sessionTimeout => Environment.sessionTimeout;
  static int get requestTimeout => Environment.requestTimeout;
  
  // Debug
  static bool get enableLogging => Environment.enableLogging;
}