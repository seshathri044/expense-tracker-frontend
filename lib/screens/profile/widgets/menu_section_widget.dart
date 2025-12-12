// lib/screens/profile/widgets/menu_section_widget.dart
import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../config/routes.dart';

class MenuSectionWidget extends StatelessWidget {
  final bool isDarkMode;

  const MenuSectionWidget({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            'Manage Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF16213E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildMenuItem(
                context,
                icon: Icons.receipt_long_rounded,
                title: 'All Expenses',
                subtitle: 'View, edit & delete expenses',
                iconColor: AppTheme.expenseRed,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.expenseList);
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                context,
                icon: Icons.account_balance_wallet_rounded,
                title: 'All Income',
                subtitle: 'View, edit & delete income',
                iconColor: AppTheme.incomeGreen,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.incomeList);
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                context,
                icon: Icons.bar_chart_rounded,
                title: 'Year Report',
                subtitle: 'Charts, trends & insights',
                iconColor: AppTheme.primaryColor,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.allStats);
                },
              ),
              _buildDivider(),

            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode ? AppTheme.darkTextSecondary : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: iconColor.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
      ),
    );
  }
}