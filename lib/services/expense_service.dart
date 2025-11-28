import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/expense_model.dart';
import '../models/api_response.dart';

class ExpenseService {
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

  // 🔥 FIXED: Get all expenses (changed endpoint to /expense/all)
  Future<ApiResponse<List<Expense>>> getExpenses({int page = 1, int limit = 20}) async {
    try {
      final token = await _getToken();
      
      // ✅ FIXED: Backend endpoint is /expense/all (not /expense with params)
      final response = await http.get(
        Uri.parse('$baseUrl${AppConfig.expenseEndpoint}/all'),
        headers: _getHeaders(token),
      );

      print('📥 Get expenses response: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Backend returns array directly or wrapped in {data: [...]}
        List<dynamic> expenseList;
        if (data is List) {
          expenseList = data;
        } else if (data is Map && data['data'] != null) {
          expenseList = data['data'] as List;
        } else {
          expenseList = [];
        }
        
        final expenses = expenseList
            .map((json) {
              try {
                return Expense.fromJson(json);
              } catch (e) {
                print('❌ Error parsing expense: $e');
                return null;
              }
            })
            .whereType<Expense>()
            .toList();
        
        return ApiResponse.success(
          message: 'Expenses loaded successfully',
          data: expenses,
        );
      } else {
        final errorData = jsonDecode(response.body);
        return ApiResponse.error(
          message: errorData['message'] ?? 'Failed to load expenses',
        );
      }
    } catch (e) {
      print('❌ Get expenses error: $e');
      return ApiResponse.error(
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Add expense
  Future<ApiResponse<Expense>> addExpense({
    required double amount,
    required String category,
    required String description,
    required DateTime date,
    String? notes,
  }) async {
    try {
      final token = await _getToken();
      
      final requestBody = {
        'amount': amount,
        'category': category,
        'description': description,
        'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
        if (notes != null) 'notes': notes,
      };

      print('📤 Add expense request: $requestBody');

      final response = await http.post(
        Uri.parse('$baseUrl${AppConfig.expenseEndpoint}'),
        headers: _getHeaders(token),
        body: jsonEncode(requestBody),
      );

      print('📥 Add expense response: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Backend might return expense directly or wrapped in 'data'
        final expenseData = data is Map && data.containsKey('data') ? data['data'] : data;
        
        return ApiResponse.success(
          message: data['message'] ?? 'Expense added successfully',
          data: Expense.fromJson(expenseData),
        );
      } else {
        final errorData = jsonDecode(response.body);
        return ApiResponse.error(
          message: errorData['message'] ?? 'Failed to add expense',
        );
      }
    } catch (e) {
      print('❌ Add expense error: $e');
      return ApiResponse.error(
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Update expense
  Future<ApiResponse<Expense>> updateExpense({
    required String id,
    required double amount,
    required String category,
    required String description,
    required DateTime date,
    String? notes,
  }) async {
    try {
      final token = await _getToken();
      
      final requestBody = {
        'amount': amount,
        'category': category,
        'description': description,
        'date': date.toIso8601String().split('T')[0],
        if (notes != null) 'notes': notes,
      };

      print('📤 Update expense request: $requestBody');

      final response = await http.put(
        Uri.parse('$baseUrl${AppConfig.expenseEndpoint}/$id'),
        headers: _getHeaders(token),
        body: jsonEncode(requestBody),
      );

      print('📥 Update expense response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final expenseData = data is Map && data.containsKey('data') ? data['data'] : data;
        
        return ApiResponse.success(
          message: data['message'] ?? 'Expense updated successfully',
          data: Expense.fromJson(expenseData),
        );
      } else {
        final errorData = jsonDecode(response.body);
        return ApiResponse.error(
          message: errorData['message'] ?? 'Failed to update expense',
        );
      }
    } catch (e) {
      print('❌ Update expense error: $e');
      return ApiResponse.error(
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Delete expense
  Future<ApiResponse<void>> deleteExpense(String id) async {
    try {
      final token = await _getToken();
      
      print('📤 Delete expense: $id');
      
      final response = await http.delete(
        Uri.parse('$baseUrl${AppConfig.expenseEndpoint}/$id'),
        headers: _getHeaders(token),
      );

      print('📥 Delete expense response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return ApiResponse.success(
          message: 'Expense deleted successfully',
        );
      } else {
        return ApiResponse.error(
          message: 'Failed to delete expense',
        );
      }
    } catch (e) {
      print('❌ Delete expense error: $e');
      return ApiResponse.error(
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Get expenses by date range
  Future<ApiResponse<List<Expense>>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final token = await _getToken();
      
      // Since backend doesn't have date-range endpoint, get all and filter client-side
      final response = await http.get(
        Uri.parse('$baseUrl${AppConfig.expenseEndpoint}/all'),
        headers: _getHeaders(token),
      );

      print('📥 Get expenses by date range response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> expenseList;
        if (data is List) {
          expenseList = data;
        } else if (data is Map && data['data'] != null) {
          expenseList = data['data'] as List;
        } else {
          expenseList = [];
        }
        
        final allExpenses = expenseList
            .map((json) {
              try {
                return Expense.fromJson(json);
              } catch (e) {
                return null;
              }
            })
            .whereType<Expense>()
            .toList();
        
        // Filter by date range on client side
        final filteredExpenses = allExpenses.where((expense) {
          final expenseDate = expense.date;
          return (expenseDate.isAfter(startDate.subtract(const Duration(days: 1))) ||
                  expenseDate.isAtSameMomentAs(startDate)) &&
                 (expenseDate.isBefore(endDate.add(const Duration(days: 1))) ||
                  expenseDate.isAtSameMomentAs(endDate));
        }).toList();
        
        return ApiResponse.success(
          message: 'Expenses loaded successfully',
          data: filteredExpenses,
        );
      } else {
        return ApiResponse.error(
          message: 'Failed to load expenses',
        );
      }
    } catch (e) {
      print('❌ Get expenses by date range error: $e');
      return ApiResponse.error(
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}