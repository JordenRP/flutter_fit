import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ProgressChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String measurementType;
  final Color lineColor;

  const ProgressChart({
    Key? key,
    required this.data,
    required this.measurementType,
    required this.lineColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('Нет данных для отображения'));
    }

    final spots = data.asMap().entries.map((entry) {
      final measurement = entry.value[measurementType] as double;
      return FlSpot(entry.key.toDouble(), measurement);
    }).toList();

    final minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1;

    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < data.length) {
                      final date = DateTime.parse(data[value.toInt()]['date']);
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('dd.MM').format(date),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: true),
            minX: 0,
            maxX: (data.length - 1).toDouble(),
            minY: minY - padding,
            maxY: maxY + padding,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: lineColor,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: lineColor.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 