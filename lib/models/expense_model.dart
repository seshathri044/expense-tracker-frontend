class Expense {
  final String id;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    this.notes,
    required this.createdAt,
  });

  // 🔥 FIXED: Better parsing to handle backend response
  factory Expense.fromJson(Map<String, dynamic> json) {
    try {
      return Expense(
        id: _safeString(json['id']),
        amount: _safeDouble(json['amount']),
        category: _safeString(json['category']),
        description: _safeString(json['description']),
        date: _safeDate(json['date']),
        notes: json['notes']?.toString(),
        createdAt: _safeDate(json['createdAt'] ?? json['date']),
      );
    } catch (e) {
      print('❌ Error parsing Expense: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static String _safeString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static DateTime _safeDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        // Handle both ISO format and date-only format
        if (value.length == 10) {
          // Date only: "2025-11-09"
          return DateTime.parse(value);
        }
        return DateTime.parse(value);
      } catch (e) {
        print('Error parsing date: $value');
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String().split('T')[0], // Send date only
      'notes': notes,
    };
  }

  Expense copyWith({
    String? id,
    double? amount,
    String? category,
    String? description,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ExpenseCategory {
  static const String food = 'Food';
  static const String transport = 'Transport';
  static const String shopping = 'Shopping';
  static const String entertainment = 'Entertainment';
  static const String bills = 'Bills';
  static const String health = 'Health';
  static const String education = 'Education';
  static const String others = 'Others';

  static List<String> getAllCategories() {
    return [
      food,
      transport,
      shopping,
      entertainment,
      bills,
      health,
      education,
      others,
    ];
  }

  static String getEmoji(String category) {
    switch (category) {
      case food:
        return '🍔';
      case transport:
        return '🚗';
      case shopping:
        return '🛍️';
      case entertainment:
        return '🎬';
      case bills:
        return '💡';
      case health:
        return '⚕️';
      case education:
        return '📚';
      default:
        return '💰';
    }
  }
}