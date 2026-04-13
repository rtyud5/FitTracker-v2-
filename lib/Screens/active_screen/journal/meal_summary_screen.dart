import 'package:flutter/material.dart';

import 'package:fittracker_source/models/meal.dart';

class MealSummaryScreen extends StatelessWidget {
  final Meal meal;
  final Map<String, int> mealTargets;
  final VoidCallback? onAddMore;
  final VoidCallback? onDone;

  const MealSummaryScreen({
    super.key,
    required this.meal,
    required this.mealTargets,
    this.onAddMore,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meal.label),
        actions: [
          IconButton(
            onPressed: onDone ?? () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${meal.totalCalories} / ${mealTargets['calories'] ?? 0} Cal',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MacroChip(label: 'Protein', value: meal.totalProtein, target: mealTargets['protein'] ?? 0),
                _MacroChip(label: 'Fat', value: meal.totalFat, target: mealTargets['fat'] ?? 0),
                _MacroChip(label: 'Carbs', value: meal.totalCarbs, target: mealTargets['carbs'] ?? 0),
                _MacroChip(label: 'Fiber', value: meal.totalFiber, target: mealTargets['fiber'] ?? 0),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: meal.entries.isEmpty
                  ? const Center(child: Text('There is nothing here yet! Try to add some food'))
                  : ListView.separated(
                      itemCount: meal.entries.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final entry = meal.entries[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(entry.food.name),
                          subtitle: Text(
                            '${entry.food.calories} Cal each · x${entry.quantity}',
                          ),
                          trailing: Text('${entry.totalCalories} Cal'),
                        );
                      },
                    ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onAddMore ?? () => Navigator.of(context).pop(),
                    child: const Text('Add more food'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onDone ?? () => Navigator.of(context).pop(true),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final int value;
  final int target;

  const _MacroChip({
    required this.label,
    required this.value,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: Text('$label: $value / $target g'),
    );
  }
}
