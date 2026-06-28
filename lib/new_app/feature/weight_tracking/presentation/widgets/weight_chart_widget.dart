// lib/features/weight_tracking/presentation/widgets/weight_chart_widget.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/weight_goal_status.dart';

class WeightChartWidget extends StatelessWidget {
  final List<double> chartData;
  final WeightGoalStatus status;

  const WeightChartWidget({
    super.key,
    required this.chartData,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    if (chartData.isEmpty) {
      return _buildEmptyChart(isDark, isTablet);
    }

    final minY = chartData.reduce((a, b) => a < b ? a : b) - 2;
    final maxY = chartData.reduce((a, b) => a > b ? a : b) + 2;

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'تطور الوزن',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: isTablet ? 300 : 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          (value.toInt() + 1).toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        );
                      },
                      interval:
                          chartData.length > 10 ? chartData.length / 5 : 1,
                      reservedSize: 30,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(chartData.length, (index) {
                      return FlSpot(index.toDouble(), chartData[index]);
                    }),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: Colors.teal,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: Colors.teal,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.teal.withOpacity(0.1),
                    ),
                  ),
                  if (status.targetWeight != null)
                    LineChartBarData(
                      spots: List.generate(chartData.length, (index) {
                        return FlSpot(index.toDouble(), status.targetWeight!);
                      }),
                      isCurved: false,
                      color: Colors.orange,
                      barWidth: 2,
                      dashArray: [5, 5],
                      dotData: const FlDotData(show: false),
                    ),
                  if (status.idealWeight != null)
                    LineChartBarData(
                      spots: List.generate(chartData.length, (index) {
                        return FlSpot(index.toDouble(), status.idealWeight!);
                      }),
                      isCurved: false,
                      color: Colors.green,
                      barWidth: 2,
                      dashArray: [5, 5],
                      dotData: const FlDotData(show: false),
                    ),
                ],
                minY: minY.clamp(30, 200),
                maxY: maxY.clamp(30, 200),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toStringAsFixed(1)} كغ',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend('الوزن', Colors.teal),
              const SizedBox(width: 16),
              if (status.targetWeight != null)
                _buildLegend('الهدف', Colors.orange, dashed: true),
              const SizedBox(width: 16),
              if (status.idealWeight != null)
                _buildLegend('المثالي', Colors.green, dashed: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(bool isDark, bool isTablet) {
    return Container(
      height: isTablet ? 300 : 250,
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: isTablet ? 80 : 60,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد بيانات كافية',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أضف قياسات لعرض تطور وزنك',
              style: TextStyle(
                fontSize: isTablet ? 13 : 12,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color, {bool dashed = false}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 2,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}
