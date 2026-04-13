import 'package:flutter/material.dart';

import 'package:fittracker_source/models/meal.dart';
import 'package:fittracker_source/models/meal_type.dart';
import 'package:fittracker_source/core/app_colors.dart';

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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.darkText),
              const SizedBox(width: 8),
              const Text(
                'Today',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...MealType.values.map((mealType) {
            final meal = meals[mealType] ?? Meal.empty(mealType);
            final targetCalories = mealTargets[mealType]?['calories'] ?? 0;
            return Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(_iconFor(mealType), color: Colors.orange, size: 28),
                  title: Text(
                    meal.label,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkText),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '${meal.totalCalories} / $targetCalories Cal',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                  trailing: GestureDetector(
                    onTap: () => onOpenMeal(mealType),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.darkText,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  ),
                ),
                // Divider beneath all items except the last
                if (mealType != MealType.values.last)
                  const Divider(color: Color(0xFFEEEEEE), thickness: 1, height: 24),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  IconData _iconFor(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.local_cafe;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.ramen_dining;
    }
  }
}
