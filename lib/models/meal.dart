import 'food.dart';
import 'meal_entry.dart';
import 'meal_type.dart';

class Meal {
  final MealType type;
  final List<MealEntry> entries;

  const Meal({required this.type, required this.entries});

  String get key => type.key;
  String get label => type.label;
  bool get isEmpty => entries.isEmpty;
  List<String> get foodNames => entries.map((entry) => entry.food.name).toList();

  int get totalCalories => entries.fold(0, (sum, entry) => sum + entry.totalCalories);
  int get totalProtein => entries.fold(0, (sum, entry) => sum + entry.totalProtein.round());
  int get totalFat => entries.fold(0, (sum, entry) => sum + entry.totalFat.round());
  int get totalCarbs => entries.fold(0, (sum, entry) => sum + entry.totalCarbs.round());
  int get totalFiber => entries.fold(0, (sum, entry) => sum + entry.totalFiber.round());

  Map<String, int> toFirestoreMap() {
    final map = <String, int>{};
    for (final entry in entries) {
      if (entry.quantity > 0) {
        map[entry.food.id] = entry.quantity;
      }
    }
    return map;
  }

  Meal copyWith({MealType? type, List<MealEntry>? entries}) {
    return Meal(
      type: type ?? this.type,
      entries: entries ?? this.entries,
    );
  }

  static Meal empty(MealType type) => Meal(type: type, entries: const []);

  factory Meal.fromFirestore({
    required MealType type,
    required Map<String, dynamic>? raw,
    required Map<String, Food> foodsById,
  }) {
    final entries = <MealEntry>[];
    final source = raw ?? const <String, dynamic>{};
    source.forEach((foodId, quantityRaw) {
      final food = foodsById[foodId];
      final quantity = _toInt(quantityRaw);
      if (food != null && quantity > 0) {
        entries.add(MealEntry(food: food, quantity: quantity));
      }
    });

    return Meal(type: type, entries: entries);
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
