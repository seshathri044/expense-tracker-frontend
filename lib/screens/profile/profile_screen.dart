// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/income_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/theme_provider.dart';
import 'widgets/profile_header_widget.dart';
import 'widgets/stats_cards_widget.dart';
import 'widgets/balance_card_widget.dart';
import 'widgets/menu_section_widget.dart';
import 'widgets/logout_button_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  Future<void> _loadProfileData() async {
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final incomeProvider = Provider.of<IncomeProvider>(context, listen: false);
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);

    // Load expenses and incomes if needed
    if (expenseProvider.expenses.isEmpty || incomeProvider.incomes.isEmpty) {
      await Future.wait([
        expenseProvider.getExpenses(page: 1, limit: 50),
        incomeProvider.getIncomes(page: 1, limit: 50),
      ]);
    }

    // Load home data for ALL-TIME stats
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Profile',
          style: TextStyle(
            color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
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
            child: const Icon(Icons.arrow_back, color: AppTheme.primaryColor, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          return SingleChildScrollView(
            child: Column(
              children: [
                // USER INFO SECTION
                ProfileHeaderWidget(
                  user: user,
                  isDarkMode: isDarkMode,
                ),

                const SizedBox(height: 24),

                // INCOME & EXPENSE CARDS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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

                      return StatsCardsWidget(
                        stats: homeProvider.allTimeStats,
                        isDarkMode: isDarkMode,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // BALANCE CARD
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Consumer<HomeProvider>(
                    builder: (context, homeProvider, child) {
                      return BalanceCardWidget(
                        balance: homeProvider.allTimeStats.balance,
                        isDarkMode: isDarkMode,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 28),

                // MENU ITEMS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: MenuSectionWidget(isDarkMode: isDarkMode),
                ),

                const SizedBox(height: 28),

                // LOGOUT BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: LogoutButtonWidget(isDarkMode: isDarkMode),
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}