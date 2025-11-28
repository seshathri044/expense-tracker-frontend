import 'package:flutter/material.dart';
import '../models/income_model.dart';
import '../services/income_service.dart';

class IncomeProvider with ChangeNotifier {
  final IncomeService _incomeService = IncomeService();
  
  List<Income> _incomes = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  List<Income> get incomes => _incomes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  // 🔥 CRITICAL FIX: Clear all data (call on logout/login)
  void clearData() {
    _incomes = [];
    _isLoading = false;
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }

  // Get all incomes
  Future<void> getIncomes({int page = 1, int limit = 20}) async {
    if (page == 1) {
      _isLoading = true;
      _incomes = [];
    }
    
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _incomeService.getIncomes(page: page, limit: limit);
      
      if (response.success && response.data != null) {
        if (page == 1) {
          _incomes = response.data!;
        } else {
          _incomes.addAll(response.data!);
        }
        _currentPage = page;
        _hasMore = response.data!.length >= limit;
      } else {
        _errorMessage = response.message ?? 'Failed to load incomes';
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('IncomeProvider getIncomes error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load more incomes
  Future<void> loadMore() async {
    if (!_isLoading && _hasMore) {
      await getIncomes(page: _currentPage + 1);
    }
  }

  // Add income
  Future<bool> addIncome({
    required double amount,
    required String source,
    required String description,
    required DateTime date,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _incomeService.addIncome(
        amount: amount,
        source: source,
        description: description,
        date: date,
        notes: notes,
      );
      
      if (response.success && response.data != null) {
        _incomes.insert(0, response.data!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to add income';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('IncomeProvider addIncome error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update income
  Future<bool> updateIncome({
    required String id,
    required double amount,
    required String source,
    required String description,
    required DateTime date,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _incomeService.updateIncome(
        id: id,
        amount: amount,
        source: source,
        description: description,
        date: date,
        notes: notes,
      );
      
      if (response.success && response.data != null) {
        final index = _incomes.indexWhere((i) => i.id == id);
        if (index != -1) {
          _incomes[index] = response.data!;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to update income';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('IncomeProvider updateIncome error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete income
  Future<bool> deleteIncome(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _incomeService.deleteIncome(id);
      
      if (response.success) {
        _incomes.removeWhere((i) => i.id == id);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to delete income';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('IncomeProvider deleteIncome error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get incomes by date range
  Future<void> getIncomesByDateRange(DateTime startDate, DateTime endDate) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _incomeService.getIncomesByDateRange(startDate, endDate);
      
      if (response.success && response.data != null) {
        _incomes = response.data!;
      } else {
        _errorMessage = response.message ?? 'Failed to load incomes';
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('IncomeProvider getIncomesByDateRange error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get recent incomes
  List<Income> getRecentIncomes({int limit = 5}) {
    return _incomes.take(limit).toList();
  }

  // Get total income amount
  double getTotalIncome() {
    return _incomes.fold(0, (sum, income) => sum + income.amount);
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh incomes
  Future<void> refresh() async {
    await getIncomes(page: 1);
  }
}