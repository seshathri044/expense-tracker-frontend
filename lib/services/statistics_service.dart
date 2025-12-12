import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/stats_model.dart';
import '../models/api_response.dart';

class StatisticsService {
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

  /// 📊 THIS MONTH STATISTICS (Pie Chart + Categories)
  /// Filters current month data from /api/stats response
  Future<ApiResponse<Map<String, dynamic>>> getThisMonthStats(
    List expenses,
  ) async {
    try {
      final now = DateTime.now();
      
      // Filter current month expenses only
      final monthExpenses = expenses.where((expense) =>
        expense.date.year == now.year && expense.date.month == now.month
      ).toList();

      if (monthExpenses.isEmpty) {
        return ApiResponse.success(
          message: 'No expenses this month',
          data: {
            'totalExpense': 0.0,
            'categories': <CategoryExpense>[],
          },
        );
      }

      // Group expenses by category
      final Map<String, double> categoryTotals = {};
      final Map<String, int> categoryCounts = {};
      double totalExpense = 0;

      for (var expense in monthExpenses) {
        final category = expense.category;
        categoryTotals[category] = (categoryTotals[category] ?? 0) + expense.amount;
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
        totalExpense += expense.amount;
      }

      // Convert to CategoryExpense list
      final categories = categoryTotals.entries.map((entry) {
        final category = entry.key;
        final amount = entry.value;
        final count = categoryCounts[category] ?? 0;
        final percentage = totalExpense > 0 
          ? (amount / totalExpense) * 100 
          : 0.0;
        
        return CategoryExpense(
          category: category,
          amount: amount,
          count: count,
          percentage: percentage,
        );
      }).toList();

      // Sort by amount (highest first)
      categories.sort((a, b) => b.amount.compareTo(a.amount));

  

      return ApiResponse.success(
        message: 'Month statistics loaded',
        data: {
          'totalExpense': totalExpense,
          'categories': categories,
        },
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Error loading statistics: ${e.toString()}',
      );
    }
  }

  /// 📈 YEAR REPORT DATA (Specific Year Jan-Dec)
  /// Filters specific year data with optional year parameter
  Future<ApiResponse<Map<String, dynamic>>> getYearReportData(
    List incomes,
    List expenses, {
    int? year,
  }) async {
    try {
      final targetYear = year ?? DateTime.now().year;
      
      // Filter specific year data only
      final yearIncomes = incomes.where((income) =>
        income.date.year == targetYear
      ).toList();

      final yearExpenses = expenses.where((expense) =>
        expense.date.year == targetYear
      ).toList();

      // Generate monthly data for specified year (Jan-Dec)
      final monthlyData = <MonthlyData>[];
      final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                         'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

      for (int month = 1; month <= 12; month++) {
        double monthIncome = 0;
        double monthExpense = 0;

        // Sum incomes for this month
        for (var income in yearIncomes) {
          if (income.date.month == month) {
            monthIncome += income.amount;
          }
        }

        // Sum expenses for this month
        for (var expense in yearExpenses) {
          if (expense.date.month == month) {
            monthExpense += expense.amount;
          }
        }

        monthlyData.add(MonthlyData(
          month: monthNames[month - 1],
          income: monthIncome,
          expense: monthExpense,
          savings: monthIncome - monthExpense,
        ));
      }

      // Category breakdown for the entire year
      final Map<String, double> categoryTotals = {};
      final Map<String, int> categoryCounts = {};
      double totalYearExpense = 0;

      for (var expense in yearExpenses) {
        final category = expense.category;
        categoryTotals[category] = (categoryTotals[category] ?? 0) + expense.amount;
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
        totalYearExpense += expense.amount;
      }

      final categories = categoryTotals.entries.map((entry) {
        final category = entry.key;
        final amount = entry.value;
        final count = categoryCounts[category] ?? 0;
        final percentage = totalYearExpense > 0 
          ? (amount / totalYearExpense) * 100 
          : 0.0;
        
        return CategoryExpense(
          category: category,
          amount: amount,
          count: count,
          percentage: percentage,
        );
      }).toList();

      categories.sort((a, b) => b.amount.compareTo(a.amount));


      return ApiResponse.success(
        message: 'Year report loaded',
        data: {
          'monthlyData': monthlyData,
          'categories': categories,
          'totalIncome': yearIncomes.fold(0.0, (sum, i) => sum + i.amount),
          'totalExpense': totalYearExpense,
        },
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Error loading year report: ${e.toString()}',
      );
    }
  }
}