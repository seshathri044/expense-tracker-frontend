import 'package:flutter/material.dart';

// Chart Data Models for fl_chart
class ChartData {
  final String label;
  final double value;
  final Color color;

  ChartData({
    required this.label,
    required this.value,
    required this.color,
  });
}

class LineChartData {
  final String label;
  final List<ChartPoint> points;
  final Color color;

  LineChartData({
    required this.label,
    required this.points,
    required this.color,
  });
}

class ChartPoint {
  final double x;
  final double y;
  final String? label;

  ChartPoint({
    required this.x,
    required this.y,
    this.label,
  });
}

class BarChartData {
  final String label;
  final double value;
  final Color color;

  BarChartData({
    required this.label,
    required this.value,
    required this.color,
  });
}