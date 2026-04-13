import 'package:flutter/material.dart';

class NutritionTargetsSection extends StatelessWidget {
  final int dailyCalories;
  final Map<String, int> macroTargets;

  const NutritionTargetsSection({
    super.key,
    required this.dailyCalories,
    required this.macroTargets,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'label': 'Calories', 'value': dailyCalories.toString(), 'unit': 'kcal'},
      {'label': 'Protein', 'value': (macroTargets['protein'] ?? 0).toString(), 'unit': 'g'},
      {'label': 'Fat', 'value': (macroTargets['fat'] ?? 0).toString(), 'unit': 'g'},
      {'label': 'Carbs', 'value': (macroTargets['carbs'] ?? 0).toString(), 'unit': 'g'},
      {'label': 'Fiber', 'value': (macroTargets['fiber'] ?? 0).toString(), 'unit': 'g'},
    ];

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
            'Daily nutrition targets',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['label']!, style: const TextStyle(fontSize: 15)),
                  Text(
                    '${item['value']} ${item['unit']}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
