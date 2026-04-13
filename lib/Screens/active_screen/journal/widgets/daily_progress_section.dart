import 'package:flutter/material.dart';

class DailyProgressSection extends StatelessWidget {
  final int consumedCalories;
  final int targetCalories;

  const DailyProgressSection({
    super.key,
    required this.consumedCalories,
    required this.targetCalories,
  });

  @override
  Widget build(BuildContext context) {
    final progress = targetCalories <= 0 ? 0.0 : (consumedCalories / targetCalories).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            '$consumedCalories / $targetCalories kcal',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.white,
            color: Colors.teal,
          ),
        ],
      ),
    );
  }
}
