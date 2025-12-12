// lib/screens/statistics/statistics_screen.dart
// ✅ REFACTORED: Main screen with month dropdown filter

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/statistics_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/expense_provider.dart';
import '../../models/expense_model.dart';
import 'monthwidgets/month_selector_dropdown.dart';
import 'monthwidgets/month_header_card.dart';
import 'monthwidgets/stats_summary_cards.dart';
import 'monthwidgets/expense_pie_chart.dart';
import 'monthwidgets/category_breakdown_list.dart';

class StatisticsScreen extends StatefulWidget {
  final bool showAppBar;
  
  const StatisticsScreen({
    super.key,
    this.showAppBar = false,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime _selectedMonth = DateTime.now();
  List<DateTime> _availableMonths = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    if (!mounted) return;
    
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    
    // Load expenses if empty
    if (expenseProvider.expenses.isEmpty) {
      await expenseProvider.getExpenses(page: 1, limit: 100);
    }
    
    // Calculate available months from user's expense data
    _calculateAvailableMonths(expenseProvider.expenses);
    
    // Load selected month statistics
    await _loadMonthStatistics(_selectedMonth);
  }

  void _calculateAvailableMonths(List<Expense> expenses) {
    if (expenses.isEmpty) {
      setState(() {
        _availableMonths = [DateTime.now()];
      });
      return;
    }

    // Get unique year-month combinations
    final Set<String> uniqueMonths = {};
    for (var expense in expenses) {
      final monthKey = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      uniqueMonths.add(monthKey);
    }

    // Convert to DateTime list and sort (newest first)
    final months = uniqueMonths.map((key) {
      final parts = key.split('-');
      return DateTime(int.parse(parts[0]), int.parse(parts[1]));
    }).toList()
      ..sort((a, b) => b.compareTo(a));

    setState(() {
      _availableMonths = months;
      // Ensure selected month exists in available months
      if (!months.any((m) => _isSameMonth(m, _selectedMonth))) {
        _selectedMonth = months.first;
      }
    });
  }

  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  Future<void> _loadMonthStatistics(DateTime month) async {
    if (!mounted) return;
    
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final statisticsProvider = Provider.of<StatisticsProvider>(context, listen: false);
    
    // Filter expenses for selected month only
    final monthExpenses = expenseProvider.expenses.where((expense) =>
      expense.date.year == month.year && expense.date.month == month.month
    ).toList();
        
    await statisticsProvider.loadThisMonthStats(monthExpenses);
  }

  Future<void> _onMonthSelected(DateTime month) async {
    if (_isSameMonth(month, _selectedMonth)) return;
    
    setState(() {
      _selectedMonth = month;
    });
    
    await _loadMonthStatistics(month);
  }

  Future<void> _onRefresh() async {
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    await expenseProvider.refresh();
    _calculateAvailableMonths(expenseProvider.expenses);
    await _loadMonthStatistics(_selectedMonth);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    
    if (widget.showAppBar) {
      return Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF5F7FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            'Monthly Statistics',
            style: TextStyle(
              color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _buildContent(isDarkMode),
      );
    }
    
    return _buildContent(isDarkMode);
  }

  Widget _buildContent(bool isDarkMode) {
    return Consumer<StatisticsProvider>(
      builder: (context, statsProvider, child) {
        if (statsProvider.isLoading && statsProvider.categories.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }

        final totalExpense = statsProvider.totalExpense;
        final categories = statsProvider.categories;
        final hasData = totalExpense > 0 && categories.isNotEmpty;

        return RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month Dropdown Selector
                MonthSelectorDropdown(
                  selectedMonth: _selectedMonth,
                  availableMonths: _availableMonths,
                  onMonthSelected: _onMonthSelected,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 24),
                
                // Month Header Card
                MonthHeaderCard(
                  selectedMonth: _selectedMonth,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 24),
                
                if (hasData) ...[
                  // Stats Summary Cards
                  StatsSummaryCards(
                    totalExpense: totalExpense,
                    categoryCount: categories.length,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 24),
                  
                  // Pie Chart
                  ExpensePieChart(
                    categories: categories,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 24),
                  
                  // Category Breakdown
                  CategoryBreakdownList(
                    categories: categories,
                    isDarkMode: isDarkMode,
                  ),
                ] else
                  _buildEmptyState(isDarkMode),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF16213E) : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pie_chart_outline,
                size: 64,
                color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No expenses this month',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? AppTheme.darkTextSecondary : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start adding expenses to see statistics',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[600] : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}