// lib/config/routes.dart
import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/verify_otp_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/expense/add_expense_screen.dart';
import '../screens/expense/expense_list_screen.dart';
import '../screens/income/add_income_screen.dart';
import '../screens/income/income_list_screen.dart';
import '../screens/transactions/all_transaction_screen.dart';
import '../screens/statistics/statistics_screen.dart'; // ✅ Month Stats
import '../screens/statistics/all_stats_screen.dart'; // ✅ Year Report
import '../screens/profile/profile_screen.dart';

class AppRoutes {
  // 🔐 Auth Routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyOtp = '/verify-otp';
  static const String resetPassword = '/reset-password';

  // 🏠 Main Routes
  static const String home = '/home';

  // 💸 Expense Routes
  static const String addExpense = '/add-expense';
  static const String expenseList = '/expense-list';

  // 💰 Income Routes
  static const String addIncome = '/add-income';
  static const String incomeList = '/income-list';

  // 📊 Transaction Routes
  static const String allTransactions = '/all-transactions';

  // 📈 Statistics Routes
  static const String statistics = '/statistics'; // ✅ This Month (used by bottom nav)
  static const String allStats = '/all-stats'; // ✅ Year Report (used by profile)

  // 👤 Profile Routes
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      onboarding: (context) => const OnboardingScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      verifyOtp: (context) => const VerifyOtpScreen(),
      resetPassword: (context) => const ResetPasswordScreen(),
      home: (context) => const HomeScreen(),
      addExpense: (context) => const AddExpenseScreen(),
      expenseList: (context) => const ExpenseListScreen(),
      addIncome: (context) => const AddIncomeScreen(),
      incomeList: (context) => const IncomeListScreen(),
      allTransactions: (context) => const AllTransactionsScreen(),
      statistics: (context) => const StatisticsScreen(showAppBar: true),// Month stats
      // statistics: (context) => const StatisticsScreen(),
      allStats: (context) => const AllStatsScreen(), // Year report
      profile: (context) => const ProfileScreen(),
    };
  }
}