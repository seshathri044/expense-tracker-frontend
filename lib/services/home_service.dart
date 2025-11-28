import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/stats_model.dart';
import '../models/api_response.dart';

class HomeService {
  final String baseUrl = AppConfig.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.tokenKey);
  }

  Map<String, String> _getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// 🏠 HOME PAGE DATA
  /// Reuses /api/stats but returns ALL-TIME data
  Future<ApiResponse<Stats>> getHomeData() async {
    try {
      final token = await _getToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl${AppConfig.statsEndpoint}'),
        headers: _getHeaders(token),
      );

      print('🏠 Home response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Backend returns data directly, not wrapped
        return ApiResponse.success(
          message: 'Home data loaded successfully',
          data: Stats.fromJson(data),
        );
      } else {
        final errorData = jsonDecode(response.body);
        return ApiResponse.error(
          message: errorData['message'] ?? 'Failed to load home data',
        );
      }
    } catch (e) {
      print('❌ Home service error: $e');
      return ApiResponse.error(
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// 📊 THIS MONTH SUMMARY
  /// Filters current month data from income/expense lists
  Future<ApiResponse<Map<String, dynamic>>> getThisMonthSummary(
    List incomes,
    List expenses,
  ) async {
    try {
      final now = DateTime.now();
      
      double monthIncome = 0;
      double monthExpense = 0;
      
      // Filter current month incomes
      for (var income in incomes) {
        if (income.date.year == now.year && income.date.month == now.month) {
          monthIncome += income.amount;
        }
      }
      
      // Filter current month expenses
      for (var expense in expenses) {
        if (expense.date.year == now.year && expense.date.month == now.month) {
          monthExpense += expense.amount;
        }
      }
      
      final monthBalance = monthIncome - monthExpense;

      return ApiResponse.success(
        message: 'Month summary calculated',
        data: {
          'income': monthIncome,
          'expense': monthExpense,
          'balance': monthBalance,
        },
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Error calculating month summary: ${e.toString()}',
      );
    }
  }

  /// 🏆 TOP 3 CATEGORIES (Current Month)
  /// Filters current month expenses and groups by category
  Future<ApiResponse<List<CategoryExpense>>> getTop3Categories(
    List expenses,
  ) async {
    try {
      final now = DateTime.now();
      
      // Filter current month expenses
      final monthExpenses = expenses.where((expense) =>
        expense.date.year == now.year && expense.date.month == now.month
      ).toList();

      if (monthExpenses.isEmpty) {
        return ApiResponse.success(
          message: 'No expenses this month',
          data: [],
        );
      }

      // Group by category
      final Map<String, double> categoryTotals = {};
      double totalExpense = 0;

      for (var expense in monthExpenses) {
        categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0) + expense.amount;
        totalExpense += expense.amount;
      }

      // Convert to CategoryExpense list
      final categories = categoryTotals.entries.map((entry) {
        final percentage = totalExpense > 0 
          ? (entry.value / totalExpense) * 100 
          : 0.0;
        
        return CategoryExpense(
          category: entry.key,
          amount: entry.value,
          count: monthExpenses.where((e) => e.category == entry.key).length,
          percentage: percentage,
        );
      }).toList();

      // Sort by amount and take top 3
      categories.sort((a, b) => b.amount.compareTo(a.amount));
      final top3 = categories.take(3).toList();

      return ApiResponse.success(
        message: 'Top 3 categories loaded',
        data: top3,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Error getting top categories: ${e.toString()}',
      );
    }
  }
}