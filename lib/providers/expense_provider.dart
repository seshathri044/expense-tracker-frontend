// lib/providers/expense_provider.dart

import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';

class ExpenseProvider with ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();
  
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  // 🔥 CRITICAL FIX: Clear all data (call on logout/login)
  void clearData() {
    _expenses = [];
    _isLoading = false;
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }

  // Get all expenses
  Future<void> getExpenses({int page = 1, int limit = 20}) async {
    if (page == 1) {
      _isLoading = true;
      _expenses = [];
    }
    
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _expenseService.getExpenses(page: page, limit: limit);
      
      if (response.success && response.data != null) {
        if (page == 1) {
          _expenses = response.data!;
        } else {
          _expenses.addAll(response.data!);
        }
        _currentPage = page;
        _hasMore = response.data!.length >= limit;
      } else {
        _errorMessage = response.message ?? 'Failed to load expenses';
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load more expenses
  Future<void> loadMore() async {
    if (!_isLoading && _hasMore) {
      await getExpenses(page: _currentPage + 1);
    }
  }

  // Add expense
  Future<bool> addExpense({
    required double amount,
    required String category,
    required String description,
    required DateTime date,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _expenseService.addExpense(
        amount: amount,
        category: category,
        description: description,
        date: date,
        notes: notes,
      );
      
      if (response.success && response.data != null) {
        _expenses.insert(0, response.data!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to add expense';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update expense
  Future<bool> updateExpense({
    required String id,
    required double amount,
    required String category,
    required String description,
    required DateTime date,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _expenseService.updateExpense(
        id: id,
        amount: amount,
        category: category,
        description: description,
        date: date,
        notes: notes,
      );
      
      if (response.success && response.data != null) {
        final index = _expenses.indexWhere((e) => e.id == id);
        if (index != -1) {
          _expenses[index] = response.data!;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to update expense';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete expense
  Future<bool> deleteExpense(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _expenseService.deleteExpense(id);
      
      if (response.success) {
        _expenses.removeWhere((e) => e.id == id);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to delete expense';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get expenses by date range
  Future<void> getExpensesByDateRange(DateTime startDate, DateTime endDate) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _expenseService.getExpensesByDateRange(startDate, endDate);
      
      if (response.success && response.data != null) {
        _expenses = response.data!;
      } else {
        _errorMessage = response.message ?? 'Failed to load expenses';
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get recent expenses
  List<Expense> getRecentExpenses({int limit = 5}) {
    return _expenses.take(limit).toList();
  }

  // Get total expense amount
  double getTotalExpense() {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh expenses
  Future<void> refresh() async {
    await getExpenses(page: 1);
  }
}