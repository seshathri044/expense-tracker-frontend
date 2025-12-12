// lib/providers/statistics_provider.dart

import 'package:flutter/material.dart';
import '../models/stats_model.dart';
import '../services/statistics_service.dart';

class StatisticsProvider with ChangeNotifier {
  final StatisticsService _statisticsService = StatisticsService();
  
  // THIS MONTH STATISTICS
  double _totalExpense = 0.0;
  List<CategoryExpense> _categories = [];
  
  // YEAR REPORT DATA
  List<MonthlyData> _yearMonthlyData = [];
  List<CategoryExpense> _yearCategories = [];
  double _yearTotalIncome = 0.0;
  double _yearTotalExpense = 0.0;
  
  // YEAR FILTRATION
  int _selectedYear = DateTime.now().year;
  List<int> _availableYears = [];
  
  bool _isLoading = false;
  String? _errorMessage;

  // Getters - THIS MONTH
  double get totalExpense => _totalExpense;
  List<CategoryExpense> get categories => _categories;
  
  // Getters - YEAR REPORT
  List<MonthlyData> get yearMonthlyData => _yearMonthlyData;
  List<CategoryExpense> get yearCategories => _yearCategories;
  double get yearTotalIncome => _yearTotalIncome;
  double get yearTotalExpense => _yearTotalExpense;
  
  // Getters - YEAR FILTRATION
  int get selectedYear => _selectedYear;
  List<int> get availableYears => _availableYears;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 📊 LOAD THIS MONTH STATISTICS (Pie Chart)
  Future<void> loadThisMonthStats(List expenses) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _statisticsService.getThisMonthStats(expenses);
      
      if (response.success && response.data != null) {
        _totalExpense = response.data!['totalExpense'] ?? 0.0;
        _categories = response.data!['categories'] ?? [];
        _errorMessage = null;
      } else {
        _errorMessage = response.message ?? 'Failed to load statistics';
      }
    } catch (e) {
      _errorMessage = 'Error loading statistics: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 📈 LOAD YEAR REPORT DATA (with optional year parameter)
  Future<void> loadYearReport(
    List incomes,
    List expenses, {
    int? year,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Calculate available years from user's data
      _calculateAvailableYears(incomes, expenses);
      
      // Use provided year or default to selected year
      final targetYear = year ?? _selectedYear;
      _selectedYear = targetYear;
      
      final response = await _statisticsService.getYearReportData(
        incomes,
        expenses,
        year: targetYear,
      );
      
      if (response.success && response.data != null) {
        _yearMonthlyData = response.data!['monthlyData'] ?? [];
        _yearCategories = response.data!['categories'] ?? [];
        _yearTotalIncome = response.data!['totalIncome'] ?? 0.0;
        _yearTotalExpense = response.data!['totalExpense'] ?? 0.0;
        _errorMessage = null;
      } else {
        _errorMessage = response.message ?? 'Failed to load year report';
      }
    } catch (e) {
      _errorMessage = 'Error loading year report: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 📅 CALCULATE AVAILABLE YEARS FROM USER DATA
  void _calculateAvailableYears(List incomes, List expenses) {
    final Set<int> years = {};
    
    // Get years from incomes
    for (var income in incomes) {
      years.add(income.date.year);
    }
    
    // Get years from expenses
    for (var expense in expenses) {
      years.add(expense.date.year);
    }
    
    // Convert to sorted list (newest first)
    _availableYears = years.toList()..sort((a, b) => b.compareTo(a));
    
    // If no data, show current year only
    if (_availableYears.isEmpty) {
      _availableYears = [DateTime.now().year];
    }
  }

  /// 🔄 CHANGE SELECTED YEAR
  Future<void> changeYear(int year, List incomes, List expenses) async {
    if (_selectedYear != year) {
      _selectedYear = year;
      await loadYearReport(incomes, expenses, year: year);
    }
  }

  /// 🔄 REFRESH MONTH STATS
  Future<void> refreshMonth(List expenses) async {
    await loadThisMonthStats(expenses);
  }

  /// 🔄 REFRESH YEAR REPORT
  Future<void> refreshYear(List incomes, List expenses) async {
    await loadYearReport(incomes, expenses);
  }

  /// 🗑️ CLEAR DATA (on logout)
  void clearData() {
    _totalExpense = 0.0;
    _categories = [];
    _yearMonthlyData = [];
    _yearCategories = [];
    _yearTotalIncome = 0.0;
    _yearTotalExpense = 0.0;
    _selectedYear = DateTime.now().year;
    _availableYears = [];
    _errorMessage = null;
    notifyListeners();
  }
}