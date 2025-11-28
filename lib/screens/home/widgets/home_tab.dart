// lib/screens/home/widgets/home_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../config/routes.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/home_provider.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/income_provider.dart';
import 'balance_cards.dart';
import 'month_summary_card.dart';
import 'top_categories_card.dart';
import 'recent_transaction_card.dart';

class HomeTab extends StatelessWidget {
  final VoidCallback onRefresh;

  const HomeTab({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppTheme.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isDarkMode),
            _buildBalanceSection(context, isDarkMode),
            MonthSummaryCard(isDarkMode: isDarkMode),
            TopCategoriesCard(isDarkMode: isDarkMode),
            _buildRecentTransactions(context, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.05),
            isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final userName = authProvider.user?.name ?? 'User';
              return Text(
                'Hello, $userName!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          Text(
            DateFormat('EEEE, MMMM d').format(DateTime.now()),
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? AppTheme.darkTextSecondary : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSection(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Consumer<HomeProvider>(
        builder: (context, homeProvider, child) {
          if (homeProvider.isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
            );
          }

          return BalanceCards(
            stats: homeProvider.allTimeStats,
            isDarkMode: isDarkMode,
          );
        },
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, AppRoutes.allTransactions);
                  onRefresh();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Consumer2<ExpenseProvider, IncomeProvider>(
            builder: (context, expenseProvider, incomeProvider, child) {
              final allTransactions = <Map<String, dynamic>>[];
              
              for (var expense in expenseProvider.expenses) {
                allTransactions.add({
                  'type': 'expense',
                  'title': expense.description,
                  'category': expense.category,
                  'amount': expense.amount,
                  'date': expense.date,
                });
              }
              
              for (var income in incomeProvider.incomes) {
                allTransactions.add({
                  'type': 'income',
                  'title': income.description,
                  'category': income.source,
                  'amount': income.amount,
                  'date': income.date,
                });
              }
              
              allTransactions.sort((a, b) => 
                (b['date'] as DateTime).compareTo(a['date'] as DateTime)
              );

              final recentTransactions = allTransactions.take(3).toList();

              if (recentTransactions.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(48),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF16213E) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No transactions yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? AppTheme.darkTextSecondary : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: recentTransactions.map((transaction) => 
                  RecentTransactionCard(
                    title: transaction['title'],
                    category: transaction['category'],
                    amount: transaction['amount'],
                    date: transaction['date'],
                    isExpense: transaction['type'] == 'expense',
                  )
                ).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}