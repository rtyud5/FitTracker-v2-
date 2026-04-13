import 'package:flutter/material.dart';

import 'package:fittracker_source/models/meal.dart';
import 'package:fittracker_source/models/meal_type.dart';

class MealCardsSection extends StatelessWidget {
  final Map<MealType, Meal> meals;
  final Map<MealType, Map<String, int>> mealTargets;
  final ValueChanged<MealType> onOpenMeal;

  const MealCardsSection({
    super.key,
    required this.meals,
    required this.mealTargets,
    required this.onOpenMeal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: MealType.values.map((mealType) {
        final meal = meals[mealType] ?? Meal.empty(mealType);
        final targetCalories = mealTargets[mealType]?['calories'] ?? 0;
        final subtitle = meal.foodNames.isEmpty
            ? 'No food added yet'
            : meal.foodNames.join(', ');
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: CircleAvatar(
              backgroundColor: Colors.orange.shade50,
              child: Icon(_iconFor(mealType), color: Colors.orange),
            ),
            title: Text(meal.label, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${meal.totalCalories} / $targetCalories Cal'),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onOpenMeal(mealType),
          ),
        );
      }).toList(),
    );
  }

  IconData _iconFor(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.free_breakfast_outlined;
      case MealType.lunch:
        return Icons.lunch_dining_outlined;
      case MealType.dinner:
        return Icons.dinner_dining_outlined;
    }
  }
}
