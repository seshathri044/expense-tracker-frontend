// stats_model.dart
class Stats {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final List<CategoryExpense> categoryBreakdown;
  final List<MonthlyData> monthlyData;

  Stats({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.categoryBreakdown,
    required this.monthlyData,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {    
    // Parse category breakdown safely
    List<CategoryExpense> categories = [];
    if (json['categoryBreakdown'] != null) {
      final categoryList = json['categoryBreakdown'] as List;
      categories = categoryList
          .map((item) => CategoryExpense.fromJson(item))
          .where((cat) => cat.amount > 0) // Filter out zero amounts
          .toList();
    }

    // Parse monthly data safely
    List<MonthlyData> monthly = [];
    if (json['monthlyData'] != null) {
      final monthlyList = json['monthlyData'] as List;
      monthly = monthlyList
          .map((item) => MonthlyData.fromJson(item))
          .toList();
    }

    final income = _safeDouble(json['income']);
    final expense = _safeDouble(json['expense']);
    final balance = _safeDouble(json['balance']);


    return Stats(
      totalIncome: income,
      totalExpense: expense,
      balance: balance,
      categoryBreakdown: categories,
      monthlyData: monthly,
    );
  }

  static double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  factory Stats.empty() {
    return Stats(
      totalIncome: 0.0,
      totalExpense: 0.0,
      balance: 0.0,
      categoryBreakdown: [],
      monthlyData: [],
    );
  }

  // Helper: Get top N categories
  List<CategoryExpense> getTopCategories({int limit = 8}) {
    final sorted = List<CategoryExpense>.from(categoryBreakdown)
      ..sort((a, b) => b.amount.compareTo(a.amount));
    
    if (sorted.length <= limit) return sorted;
    
    // Take top N-1 and combine rest into "Others"
    final top = sorted.take(limit - 1).toList();
    final others = sorted.skip(limit - 1);
    
    if (others.isNotEmpty) {
      final othersTotal = others.fold(0.0, (sum, cat) => sum + cat.amount);
      final othersCount = others.fold(0, (sum, cat) => sum + cat.count);
      final othersPercentage = others.fold(0.0, (sum, cat) => sum + cat.percentage);
      
      top.add(CategoryExpense(
        category: 'Others',
        amount: othersTotal,
        count: othersCount,
        percentage: othersPercentage,
      ));
    }
    
    return top;
  }

  // Helper: Get highest spending month
  MonthlyData? getHighestSpendingMonth() {
    if (monthlyData.isEmpty) return null;
    return monthlyData.reduce((a, b) => a.expense > b.expense ? a : b);
  }

  // Helper: Get best savings month
  MonthlyData? getBestSavingsMonth() {
    if (monthlyData.isEmpty) return null;
    return monthlyData.reduce((a, b) => a.savings > b.savings ? a : b);
  }

  // Helper: Get average monthly expense
  double getAverageMonthlyExpense() {
    if (monthlyData.isEmpty) return 0.0;
    final total = monthlyData.fold(0.0, (sum, month) => sum + month.expense);
    return total / monthlyData.length;
  }

  // Helper: Get top 3 expense categories
  List<CategoryExpense> getTop3Categories() {
    final sorted = List<CategoryExpense>.from(categoryBreakdown)
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return sorted.take(3).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'balance': balance,
      'categoryBreakdown': categoryBreakdown.map((e) => e.toJson()).toList(),
      'monthlyData': monthlyData.map((e) => e.toJson()).toList(),
    };
  }

  Stats copyWith({
    double? totalIncome,
    double? totalExpense,
    double? balance,
    List<CategoryExpense>? categoryBreakdown,
    List<MonthlyData>? monthlyData,
  }) {
    return Stats(
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      balance: balance ?? this.balance,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      monthlyData: monthlyData ?? this.monthlyData,
    );
  }
}

class CategoryExpense {
  final String category;
  final double amount;
  final int count;
  final double percentage;

  CategoryExpense({
    required this.category,
    required this.amount,
    required this.count,
    required this.percentage,
  });

  factory CategoryExpense.fromJson(Map<String, dynamic> json) {
    return CategoryExpense(
      category: json['category']?.toString() ?? 'Unknown',
      amount: _safeDouble(json['amount']),
      count: _safeInt(json['count']),
      percentage: _safeDouble(json['percentage']),
    );
  }

  static double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'amount': amount,
      'count': count,
      'percentage': percentage,
    };
  }

  // Helper: Format amount with proper spacing
  String get formattedAmount => '₹${amount.toStringAsFixed(0)}';
  
  // Helper: Format percentage
  String get formattedPercentage => '${percentage.toStringAsFixed(1)}%';
}

class MonthlyData {
  final String month;
  final double income;
  final double expense;
  final double savings;

  MonthlyData({
    required this.month,
    required this.income,
    required this.expense,
    required this.savings,
  });

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      month: json['month']?.toString() ?? '',
      income: _safeDouble(json['income']),
      expense: _safeDouble(json['expense']),
      savings: _safeDouble(json['savings']),
    );
  }

  static double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'income': income,
      'expense': expense,
      'savings': savings,
    };
  }

  // Helper: Get short month name (e.g., "Jan", "Feb")
  String get shortMonth {
    if (month.length <= 3) return month;
    return month.substring(0, 3);
  }

  // Helper: Format amounts
  String get formattedIncome => '₹${income.toStringAsFixed(0)}';
  String get formattedExpense => '₹${expense.toStringAsFixed(0)}';
  String get formattedSavings => '₹${savings.toStringAsFixed(0)}';
}
