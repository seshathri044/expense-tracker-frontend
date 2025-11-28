// lib/models/user_models.dart
// ✅ FIXED: Combines safety of OLD code with flexibility of NEW code

/// User Model - Represents authenticated user data
class User {
  final String id;
  final String name;
  final String email;
  final bool isVerified;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.isVerified,
    required this.createdAt,
  });

  /// Factory constructor to parse from JSON with flexible field mapping
  /// ✅ FIXED: Added null safety operators (??) everywhere
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      // Support multiple possible ID field names with fallback
      id: json['userId'] ?? json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '', // ✅ FIXED: Added ?? operator for safety
      // Support multiple possible verification field names
      isVerified: json['isAccountVerified'] ?? json['isVerified'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': id,
      'name': name,
      'email': email,
      'isAccountVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Authentication Response - Handles login/register responses
class AuthResponse {
  final bool success;
  final String? message;
  final String? token;
  final User? user;
  final String? email;
  final String? userId;
  final String? name;

  AuthResponse({
    this.success = false,
    this.message,
    this.token,
    this.user,
    this.email,
    this.userId,
    this.name,
  });

  /// Factory constructor with flexible response parsing
  /// ✅ FIXED: Enhanced null safety in all parsing paths
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Determine success status
    bool isSuccess = json['success'] == true || 
                     json['error'] == false || 
                     (json['error'] == null && json['success'] == null && json['token'] != null);

    User? user;

    // Try to construct user from various possible structures
    if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      // Case 1: User object provided directly
      try {
        user = User.fromJson(json['user']);
      } catch (e) {
        // Silently handle parsing errors
        user = null;
      }
    } else if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      // Case 2: User data nested in 'data' field
      final data = json['data'] as Map<String, dynamic>;
      if (data['email'] != null && data['email'].toString().isNotEmpty) {
        try {
          user = User(
            id: data['userId'] ?? data['id'] ?? '',
            name: data['name'] ?? '',
            email: data['email'] ?? '', // ✅ FIXED: Added ?? operator
            isVerified: data['isAccountVerified'] ?? data['isVerified'] ?? false,
            createdAt: data['createdAt'] != null
                ? DateTime.parse(data['createdAt'])
                : DateTime.now(),
          );
        } catch (e) {
          user = null;
        }
      }
    } else if (json['email'] != null && json['email'].toString().isNotEmpty) {
      // Case 3: Flat structure with email at root level
      try {
        user = User(
          id: json['userId'] ?? json['id'] ?? '',
          name: json['name'] ?? '',
          email: json['email'] ?? '', // ✅ FIXED: Added ?? operator
          isVerified: json['isAccountVerified'] ?? json['isVerified'] ?? true,
          createdAt: json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
        );
      } catch (e) {
        user = null;
      }
    }

    return AuthResponse(
      success: isSuccess,
      message: json['message'],
      token: json['token'],
      user: user,
      email: json['email'],
      userId: json['userId'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'user': user?.toJson(),
      'email': email,
      'userId': userId,
      'name': name,
    };
  }
}

/// Generic API Response wrapper
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final List<String>? errors;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? json['error'] == false ?? false,
      message: json['message'],
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      errors: json['errors'] != null
          ? List<String>.from(json['errors'])
          : null,
    );
  }

  factory ApiResponse.success({String? message, T? data}) {
    return ApiResponse(
      success: true,
      message: message,
      data: data,
    );
  }

  factory ApiResponse.error({String? message, List<String>? errors}) {
    return ApiResponse(
      success: false,
      message: message,
      errors: errors,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'errors': errors,
    };
  }
}

/// Paginated Response for list endpoints
class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    var dataList = json['data'] as List? ?? [];

    return PaginatedResponse(
      data: dataList
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
    };
  }
}