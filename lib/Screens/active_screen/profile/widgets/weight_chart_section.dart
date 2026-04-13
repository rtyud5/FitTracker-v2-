import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeightChartSection extends StatelessWidget {
  final int selectedRangeDays;
  final List<String> labels;
  final List<double> weights;
  final ValueChanged<int> onRangeChanged;

  const WeightChartSection({
    super.key,
    required this.selectedRangeDays,
    required this.labels,
    required this.weights,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final safeWeights = weights.isEmpty ? [0.0] : weights;
    final highest = safeWeights.reduce((a, b) => a > b ? a : b);
    final lowest = safeWeights.reduce((a, b) => a < b ? a : b);
    final maxY = (highest + 5).toDouble();
    final minY = (lowest - 5).clamp(0, maxY).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weight trend',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [7, 30, 90]
                .map(
                  (days) => ChoiceChip(
                    label: Text('$days days'),
                    selected: selectedRangeDays == days,
                    onSelected: (_) => onRangeChanged(days),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval: ((maxY - minY) / 4).clamp(1, 100).toDouble(),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: labels.length > 6 ? (labels.length / 4).floorToDouble() : 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            labels[index],
                            style: const TextStyle(fontSize: 10, color: Colors.black54),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: Colors.teal,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.teal.withValues(alpha: 0.15),
                    ),
                    spots: List.generate(
                      safeWeights.length,
                      (index) => FlSpot(index.toDouble(), safeWeights[index]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
