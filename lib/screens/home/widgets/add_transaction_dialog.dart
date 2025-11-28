// lib/screens/home/widgets/add_transaction_dialog.dart
// ✅ DARK MODE FIXED: Text colors are theme-aware!
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../config/routes.dart';
import '../../../providers/theme_provider.dart';

void showAddTransactionDialog({
  required BuildContext context,
  required VoidCallback onExpenseAdded,
  required VoidCallback onIncomeAdded,
}) {
  final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
  
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF16213E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Add Transaction',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _AddOptionTile(
              icon: Icons.trending_down_rounded,
              title: 'Add Expense',
              subtitle: 'Record a new expense',
              color: AppTheme.expenseRed,
              isDarkMode: isDarkMode,
              onTap: () async {
                Navigator.pop(context);
                await Navigator.pushNamed(context, AppRoutes.addExpense);
                onExpenseAdded();
              },
            ),
            const SizedBox(height: 12),
            _AddOptionTile(
              icon: Icons.trending_up_rounded,
              title: 'Add Income',
              subtitle: 'Record a new income',
              color: AppTheme.incomeGreen,
              isDarkMode: isDarkMode,
              onTap: () async {
                Navigator.pop(context);
                await Navigator.pushNamed(context, AppRoutes.addIncome);
                onIncomeAdded();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}

class _AddOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _AddOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.08),
              color.withOpacity(0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.25), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      // ✅ FIX: Theme-aware text color
                      color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      // ✅ FIX: Theme-aware subtitle color
                      color: isDarkMode ? AppTheme.darkTextSecondary : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}