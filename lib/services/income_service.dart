import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/income_model.dart';
import '../models/api_response.dart';

class IncomeService {
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

  // Get all incomes
  Future<ApiResponse<List<Income>>> getIncomes({int page = 1, int limit = 20}) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl${AppConfig.incomeEndpoint}/all'),
        headers: _getHeaders(token),
      );


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Handle both array and object responses
        List<dynamic> incomeList;
        if (data is List) {
          incomeList = data;
        } else if (data is Map && data['data'] != null) {
          incomeList = data['data'] as List;
        } else {
          incomeList = [];
        }
        
        final incomes = incomeList
            .map((json) {
              try {
                return Income.fromJson(json);
              } catch (e) {
                return null;
              }
            })
            .whereType<Income>()
            .toList();
        
        return ApiResponse.success(
          message: 'Incomes loaded successfully',
          data: incomes,
        );
      } else {
        return ApiResponse.error(
          message: 'Failed to load incomes (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Add income
  Future<ApiResponse<Income>> addIncome({
    required double amount,
    required String source,
    required String description,
    required DateTime date,
    String? notes,
  }) async {
    try {
      final token = await _getToken();
      
      // Backend expects: title, category, description, amount, date
      final requestBody = {
        'title': description,
        'category': source,
        'description': notes ?? description,
        'amount': amount,
        'date': date.toIso8601String().split('T')[0], // Send as YYYY-MM-DD
      };


      final response = await http.post(
        Uri.parse('$baseUrl${AppConfig.incomeEndpoint}'),
        headers: _getHeaders(token),
        body: jsonEncode(requestBody),
      );


      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Backend might return the income directly or wrapped in 'data'
        final incomeData = data is Map && data.containsKey('data') ? data['data'] : data;
        
        final income = Income.fromJson(incomeData);
        
        return ApiResponse.success(
          message: 'Income added successfully',
          data: income,
        );
      } else {
        final errorData = jsonDecode(response.body);
        return ApiResponse.error(
          message: errorData['message'] ?? 'Failed to add income',
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Update income
  Future<ApiResponse<Income>> updateIncome({
    required String id,
    required double amount,
    required String source,
    required String description,
    required DateTime date,
    String? notes,
  }) async {
    try {
      final token = await _getToken();
      
      final requestBody = {
        'title': description,
        'category': source,
        'description': notes ?? description,
        'amount': amount,
        'date': date.toIso8601String().split('T')[0],
      };


      final response = await http.put(
        Uri.parse('$baseUrl${AppConfig.incomeEndpoint}/$id'),
        headers: _getHeaders(token),
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final incomeData = data is Map && data.containsKey('data') ? data['data'] : data;
        final income = Income.fromJson(incomeData);
        
        return ApiResponse.success(
          message: 'Income updated successfully',
          data: income,
        );
      } else {
        final errorData = jsonDecode(response.body);
        return ApiResponse.error(
          message: errorData['message'] ?? 'Failed to update income',
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Delete income
  Future<ApiResponse<void>> deleteIncome(String id) async {
    try {
      final token = await _getToken();
            
      final response = await http.delete(
        Uri.parse('$baseUrl${AppConfig.incomeEndpoint}/$id'),
        headers: _getHeaders(token),
      );


      if (response.statusCode == 200) {
        return ApiResponse.success(
          message: 'Income deleted successfully',
        );
      } else {
        return ApiResponse.error(
          message: 'Failed to delete income (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Get incomes by date range
  Future<ApiResponse<List<Income>>> getIncomesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final token = await _getToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl${AppConfig.incomeEndpoint}/all'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> incomeList;
        if (data is List) {
          incomeList = data;
        } else if (data is Map && data['data'] != null) {
          incomeList = data['data'] as List;
        } else {
          incomeList = [];
        }
        
        final allIncomes = incomeList
            .map((json) {
              try {
                return Income.fromJson(json);
              } catch (e) {
                return null;
              }
            })
            .whereType<Income>()
            .toList();
        
        // Filter by date range on client side
        final filteredIncomes = allIncomes.where((income) {
          final incomeDate = income.date;
          return (incomeDate.isAfter(startDate.subtract(const Duration(days: 1))) ||
                  incomeDate.isAtSameMomentAs(startDate)) &&
                 (incomeDate.isBefore(endDate.add(const Duration(days: 1))) ||
                  incomeDate.isAtSameMomentAs(endDate));
        }).toList();
        
        return ApiResponse.success(
          message: 'Incomes loaded successfully',
          data: filteredIncomes,
        );
      } else {
        return ApiResponse.error(
          message: 'Failed to load incomes',
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}