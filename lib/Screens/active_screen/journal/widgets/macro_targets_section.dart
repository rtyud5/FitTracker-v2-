import 'package:flutter/material.dart';

class MacroTargetsSection extends StatelessWidget {
  final int protein;
  final int fat;
  final int carbs;
  final int fiber;
  final Map<String, int> targets;

  const MacroTargetsSection({
    super.key,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.fiber,
    required this.targets,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      {'label': 'Protein', 'value': protein, 'target': targets['protein'] ?? 0},
      {'label': 'Fat', 'value': fat, 'target': targets['fat'] ?? 0},
      {'label': 'Carbs', 'value': carbs, 'target': targets['carbs'] ?? 0},
      {'label': 'Fiber', 'value': fiber, 'target': targets['fiber'] ?? 0},
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
            'Macro targets',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...rows.map(
            (row) {
              final value = row['value']! as int;
              final target = row['target']! as int;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(row['label']! as String),
                        Text('$value / $target g'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: target == 0 ? 0 : (value / target).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.teal,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
