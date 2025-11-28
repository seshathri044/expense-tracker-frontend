// lib/screens/home/home_screen.dart
// ✅ FIXED: Navigation to /statistics route
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/theme_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/income_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/statistics_provider.dart';
import 'widgets/home_tab.dart';
import 'widgets/add_transaction_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final incomeProvider = Provider.of<IncomeProvider>(context, listen: false);
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);

    // Load expenses and incomes first
    await Future.wait([
      expenseProvider.getExpenses(page: 1, limit: 50),
      incomeProvider.getIncomes(page: 1, limit: 50),
    ]);

    // Load home data
    await homeProvider.loadHomeData(
      incomeProvider.incomes,
      expenseProvider.expenses,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF5F7FA),
      appBar: _buildAppBar(isDarkMode),
      body: HomeTab(onRefresh: _loadData),
      floatingActionButton: _buildFAB(),
      bottomNavigationBar: _buildBottomNav(isDarkMode),
    );
  }

  AppBar _buildAppBar(bool isDarkMode) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(
        'Expense Tracker',
        style: TextStyle(
          color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
      ),
      actions: [
        // Theme Toggle
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.2),
                  AppTheme.primaryColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
              color: AppTheme.primaryColor,
              size: 22,
            ),
          ),
          onPressed: () {
            Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
          },
        ),
        // Profile Button
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.2),
                  AppTheme.primaryColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: AppTheme.primaryColor, size: 22),
          ),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.profile);
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildBottomNav(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF16213E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) async {
            if (index == 1) {
              // ✅ Navigate to /statistics route
              await Navigator.pushNamed(context, AppRoutes.statistics);
              // Keep home tab selected after returning
              setState(() {
                _selectedIndex = 0;
              });
            } else {
              setState(() {
                _selectedIndex = index;
              });
              _loadData();
            }
          },
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 26),
              activeIcon: Icon(Icons.home, size: 26),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_outline, size: 26),
              activeIcon: Icon(Icons.pie_chart, size: 26),
              label: 'This Month',
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showAddTransactionDialog(
      context: context,
      onExpenseAdded: () async {
        await _loadData();
      },
      onIncomeAdded: () async {
        await _loadData();
      },
    );
  }
}