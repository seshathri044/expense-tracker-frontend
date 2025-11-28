class AppConfig {
  // 🔥 CRITICAL FIX: Added /api context path from Spring Boot
  static const String baseUrl = 'http://localhost:8080/api';
  
  // API Endpoints (these are appended to baseUrl)
  static const String authEndpoint = '';
  static const String expenseEndpoint = '/expense';
  static const String incomeEndpoint = '/income';
  static const String statsEndpoint = '/stats';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
  static const String userEmailKey = 'user_email';
  
  // App Settings
  static const String appName = 'Expense Tracker';
  static const int sessionTimeout = 30; // minutes
}