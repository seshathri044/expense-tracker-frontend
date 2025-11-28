class Income {
  final String id;
  final String userId;
  final double amount;
  final String source;
  final String description;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;

  Income({
    required this.id,
    required this.userId,
    required this.amount,
    required this.source,
    required this.description,
    required this.date,
    this.notes,
    required this.createdAt,
  });

  // 🔥 CRITICAL FIX: Handles ID as BOTH int and String
  factory Income.fromJson(Map<String, dynamic> json) {
    try {
      return Income(
        id: _safeId(json['id']),
        userId: _safeString(json['userId']),
        amount: _safeDouble(json['amount']),
        source: _safeString(json['category']),
        description: _safeString(json['title']),
        date: _safeDate(json['date']),
        notes: json['description']?.toString(),
        createdAt: _safeDate(json['createdAt']),
      );
    } catch (e) {
      print('❌ Error parsing Income: $e');
      print('📦 JSON data: $json');
      // Return default income on error
      return Income(
        id: '',
        userId: '',
        amount: 0.0,
        source: 'Unknown',
        description: 'Error loading income',
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );
    }
  }

  // 🔥 CRITICAL: Convert ID (can be int or String) to String
  static String _safeId(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is int) return value.toString();  // ← KEY FIX!
    if (value is double) return value.toInt().toString();
    return value.toString();
  }

  // Safe string conversion
  static String _safeString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  // Safe double conversion
  static double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        print('⚠️ Error parsing double from string: $value');
        return 0.0;
      }
    }
    return 0.0;
  }

  // Safe date conversion
  static DateTime _safeDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('⚠️ Error parsing date from string: $value');
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'source': source,
      'description': description,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  Income copyWith({
    String? id,
    String? userId,
    double? amount,
    String? source,
    String? description,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
  }) {
    return Income(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      source: source ?? this.source,
      description: description ?? this.description,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Income Sources
class IncomeSource {
  static const String salary = 'Salary';
  static const String freelance = 'Freelance';
  static const String business = 'Business';
  static const String investment = 'Investment';
  static const String gift = 'Gift';
  static const String bonus = 'Bonus';
  static const String others = 'Others';

  static List<String> getAllSources() {
    return [
      salary,
      freelance,
      business,
      investment,
      gift,
      bonus,
      others,
    ];
  }

  static String getEmoji(String source) {
    switch (source) {
      case salary:
        return '💼';
      case freelance:
        return '💻';
      case business:
        return '🏢';
      case investment:
        return '📈';
      case gift:
        return '🎁';
      case bonus:
        return '🎉';
      default:
        return '💵';
    }
  }
}