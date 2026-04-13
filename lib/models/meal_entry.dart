import 'food.dart';

class MealEntry {
  final Food food;
  final int quantity;

  const MealEntry({required this.food, required this.quantity});

  int get totalCalories => food.calories * quantity;
  double get totalProtein => food.protein * quantity;
  double get totalFat => food.fat * quantity;
  double get totalCarbs => food.carb * quantity;
  double get totalFiber => food.fiber * quantity;

  MealEntry copyWith({Food? food, int? quantity}) {
    return MealEntry(
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toFirestoreMap() => {food.id: quantity};
}
