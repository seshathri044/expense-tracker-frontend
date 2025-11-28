// lib/screens/home/widgets/month_summary_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../providers/home_provider.dart';

class MonthSummaryCard extends StatelessWidget {
  final bool isDarkMode;

  const MonthSummaryCard({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Consumer<HomeProvider>(
        builder: (context, homeProvider, child) {
          final summary = homeProvider.monthSummary;

          return Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF16213E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '📊 This Month Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow('Income', summary['income'] ?? 0.0, AppTheme.incomeGreen),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Expense', summary['expense'] ?? 0.0, AppTheme.expenseRed),
                      const SizedBox(height: 12),
                      Divider(color: isDarkMode ? Colors.grey[700] : Colors.grey[300], height: 1),
                      const SizedBox(height: 12),
                      _buildSummaryRow(
                        'Balance',
                        summary['balance'] ?? 0.0,
                        (summary['balance'] ?? 0.0) >= 0 ? AppTheme.incomeGreen : AppTheme.expenseRed,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 15,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: isDarkMode ? AppTheme.darkTextSecondary : Colors.grey[700],
          ),
        ),
        Text(
          '₹${NumberFormat('#,##,##0').format(amount)}',
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}