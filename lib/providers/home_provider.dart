import 'package:flutter/material.dart';
import '../models/stats_model.dart';
import '../services/home_service.dart';

class HomeProvider with ChangeNotifier {
  final HomeService _homeService = HomeService();
  
  // ALL-TIME DATA (from /api/stats)
  Stats _allTimeStats = Stats.empty();
  
  // THIS MONTH DATA (calculated from filtered data)
  Map<String, dynamic> _monthSummary = {
    'income': 0.0,
    'expense': 0.0,
    'balance': 0.0,
  };
  
  List<CategoryExpense> _top3Categories = [];
  
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Stats get allTimeStats => _allTimeStats;
  Map<String, dynamic> get monthSummary => _monthSummary;
  List<CategoryExpense> get top3Categories => _top3Categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 🏠 LOAD HOME PAGE DATA
  Future<void> loadHomeData(List incomes, List expenses) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {      
      // Get ALL-TIME stats from backend
      final statsResponse = await _homeService.getHomeData();
      
      if (statsResponse.success && statsResponse.data != null) {
        _allTimeStats = statsResponse.data!;
      }

      // Calculate THIS MONTH summary
      final monthResponse = await _homeService.getThisMonthSummary(incomes, expenses);
      if (monthResponse.success && monthResponse.data != null) {
        _monthSummary = monthResponse.data!;
      }

      // Get TOP 3 categories for current month
      final top3Response = await _homeService.getTop3Categories(expenses);
      if (top3Response.success && top3Response.data != null) {
        _top3Categories = top3Response.data!;
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error loading home data: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 🔄 REFRESH
  Future<void> refresh(List incomes, List expenses) async {
    await loadHomeData(incomes, expenses);
  }

  /// 🗑️ CLEAR DATA (on logout)
  void clearData() {
    _allTimeStats = Stats.empty();
    _monthSummary = {
      'income': 0.0,
      'expense': 0.0,
      'balance': 0.0,
    };
    _top3Categories = [];
    _errorMessage = null;
    notifyListeners();
  }
}