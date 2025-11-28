// lib/screens/statistics/widgets/line_chart_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart' as charts;
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../models/stats_model.dart';
import '../../../providers/theme_provider.dart';

class LineChartWidget extends StatelessWidget {
  final List<MonthlyData> monthlyData;

  const LineChartWidget({super.key, required this.monthlyData});

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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Income vs Expenses',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: charts.LineChart(
                charts.LineChartData(
                  minY: 0,
                  maxY: _getMaxY() * 1.2,
                  gridData: charts.FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _getMaxY() / 5,
                    getDrawingHorizontalLine: (value) {
                      return charts.FlLine(
                        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: charts.FlTitlesData(
                    leftTitles: charts.AxisTitles(
                      sideTitles: charts.SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        interval: _getMaxY() / 4,
                        getTitlesWidget: (value, meta) {
                          if (value >= 100000) {
                            return Text(
                              '₹${(value / 100000).toStringAsFixed(1)}L',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                              ),
                            );
                          } else if (value >= 1000) {
                            return Text(
                              '₹${(value / 1000).toStringAsFixed(0)}K',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                              ),
                            );
                          } else {
                            return Text(
                              '₹${value.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    bottomTitles: charts.AxisTitles(
                      sideTitles: charts.SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (value == index.toDouble() && index >= 0 && index < monthlyData.length) {
                            return Text(
                              monthlyData[index].month,
                              style: TextStyle(
                                fontSize: 10,
                                color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const charts.AxisTitles(
                      sideTitles: charts.SideTitles(showTitles: false),
                    ),
                    topTitles: const charts.AxisTitles(
                      sideTitles: charts.SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: charts.FlBorderData(show: false),
                  lineBarsData: [
                    // Income line
                    charts.LineChartBarData(
                      spots: monthlyData.asMap().entries.map((entry) {
                        return charts.FlSpot(
                          entry.key.toDouble(),
                          entry.value.income,
                        );
                      }).toList(),
                      isCurved: true,
                      color: AppTheme.incomeGreen,
                      barWidth: 3,
                      dotData: const charts.FlDotData(show: true),
                      belowBarData: charts.BarAreaData(
                        show: true,
                        color: AppTheme.incomeGreen.withOpacity(0.1),
                      ),
                    ),
                    // Expense line
                    charts.LineChartBarData(
                      spots: monthlyData.asMap().entries.map((entry) {
                        return charts.FlSpot(
                          entry.key.toDouble(),
                          entry.value.expense,
                        );
                      }).toList(),
                      isCurved: true,
                      color: AppTheme.expenseRed,
                      barWidth: 3,
                      dotData: const charts.FlDotData(show: true),
                      belowBarData: charts.BarAreaData(
                        show: true,
                        color: AppTheme.expenseRed.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppTheme.incomeGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Income',
                      style: TextStyle(
                        color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppTheme.expenseRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Expenses',
                      style: TextStyle(
                        color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxY() {
    double max = 0;
    for (var data in monthlyData) {
      if (data.income > max) max = data.income;
      if (data.expense > max) max = data.expense;
    }
    return max > 0 ? max : 1000;
  }
}