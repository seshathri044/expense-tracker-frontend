// lib/screens/statistics/monthwidgets/month_selector_dropdown.dart
// ✅ Month Dropdown Selector with proper filtering

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';

class MonthSelectorDropdown extends StatelessWidget {
  final DateTime selectedMonth;
  final List<DateTime> availableMonths;
  final Function(DateTime) onMonthSelected;
  final bool isDarkMode;

  const MonthSelectorDropdown({
    super.key,
    required this.selectedMonth,
    required this.availableMonths,
    required this.onMonthSelected,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    if (availableMonths.isEmpty) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF16213E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'No data available',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? AppTheme.darkTextSecondary : Colors.grey[600],
            ),
          ),
        ),
      );
    }

    // 🔥 FIX: Find matching month in availableMonths list
    DateTime dropdownValue = selectedMonth;
    if (!availableMonths.any((m) => _isSameMonth(m, selectedMonth))) {
      dropdownValue = availableMonths.first;
    } else {
      dropdownValue = availableMonths.firstWhere((m) => _isSameMonth(m, selectedMonth));
    }

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DateTime>(
          value: dropdownValue,
          isExpanded: true,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.calendar_month,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          dropdownColor: isDarkMode ? const Color(0xFF16213E) : Colors.white,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
          items: availableMonths.map((DateTime month) {
            final bool isSelected = _isSameMonth(month, selectedMonth);
            final bool isCurrent = _isSameMonth(month, DateTime.now());
            
            return DropdownMenuItem<DateTime>(
              value: month,
              child: Row(
                children: [
                  Text(
                    DateFormat('MMM yyyy').format(month),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.incomeGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Current',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.incomeGreen,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
          onChanged: (DateTime? newMonth) {
            if (newMonth != null) {
              onMonthSelected(newMonth);
            }
          },
        ),
      ),
    );
  }

  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }
}