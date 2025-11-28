// lib/screens/statistics/widgets/bar_chart_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../models/stats_model.dart';
import '../../../providers/theme_provider.dart';

class BarChartWidget extends StatelessWidget {
  final List<MonthlyData> monthlyData;

  const BarChartWidget({super.key, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    
    if (monthlyData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No data available',
            style: TextStyle(
              color: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
            ),
          ),
        ),
      );
    }

    final maxY = _getMaxY() * 1.2;
    final interval = _getInterval(maxY);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Spending Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Compare your income and expenses month by month',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDarkMode ? AppTheme.darkTextSecondary : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String label = rodIndex == 0 ? 'Income' : 'Expense';
                        return BarTooltipItem(
                          '$label\n₹${NumberFormat('#,##,##0').format(rod.toY)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < monthlyData.length) {
                            final month = monthlyData[value.toInt()].month;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                month.length > 3 ? month.substring(0, 3) : month,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 65,
                        interval: interval,
                        getTitlesWidget: (value, meta) {
                          // CRITICAL FIX: Only show labels at interval boundaries
                          final remainder = value % interval;
                          if (remainder.abs() > 0.001 && (interval - remainder).abs() > 0.001) {
                            return const SizedBox.shrink();
                          }
                          
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              _formatYAxisLabel(value),
                              style: TextStyle(
                                fontSize: 10,
                                color: isDarkMode ? AppTheme.darkTextPrimary : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: monthlyData.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.income,
                          color: AppTheme.incomeGreen,
                          width: 12,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: entry.value.expense,
                          color: AppTheme.expenseRed,
                          width: 12,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend(AppTheme.incomeGreen, 'Income', isDarkMode),
                const SizedBox(width: 24),
                _buildLegend(AppTheme.expenseRed, 'Expenses', isDarkMode),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label, bool isDarkMode) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  String _formatYAxisLabel(double value) {
    if (value == 0) return '₹0';
    
    if (value >= 100000) {
      // For lakhs
      double lakhs = value / 100000;
      if (lakhs == lakhs.roundToDouble()) {
        return '₹${lakhs.toInt()}L';
      }
      return '₹${lakhs.toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      // For thousands
      double thousands = value / 1000;
      if (thousands == thousands.roundToDouble()) {
        return '₹${thousands.toInt()}K';
      }
      return '₹${thousands.toStringAsFixed(1)}K';
    } else {
      return '₹${value.toInt()}';
    }
  }

  double _getMaxY() {
    double max = 0;
    for (var data in monthlyData) {
      if (data.income > max) max = data.income;
      if (data.expense > max) max = data.expense;
    }
    return max > 0 ? max : 1000;
  }

  double _getInterval(double maxY) {
    // Smart interval calculation for clean Y-axis
    if (maxY >= 1000000) {
      return 200000; // 2L intervals for very large values
    } else if (maxY >= 500000) {
      return 100000; // 1L intervals
    } else if (maxY >= 250000) {
      return 50000; // 50K intervals
    } else if (maxY >= 120000) {
      return 30000; // 30K intervals
    } else if (maxY >= 60000) {
      return 20000; // 20K intervals
    } else if (maxY >= 30000) {
      return 10000; // 10K intervals
    } else if (maxY >= 12000) {
      return 5000; // 5K intervals
    } else if (maxY >= 6000) {
      return 2000; // 2K intervals
    } else {
      return 1000; // 1K intervals
    }
  }
}