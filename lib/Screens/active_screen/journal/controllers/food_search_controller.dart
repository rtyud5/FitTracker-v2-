import 'package:flutter/foundation.dart';

import 'package:fittracker_source/Screens/active_screen/journal/services/journal_service.dart';
import 'package:fittracker_source/models/food.dart';
import 'package:fittracker_source/models/meal.dart';
import 'package:fittracker_source/models/meal_entry.dart';
import 'package:fittracker_source/models/meal_type.dart';

class FoodSearchController extends ChangeNotifier {
  FoodSearchController({required this.mealType});

  final MealType mealType;

  bool _isLoading = false;
  bool _isSaving = false;
  String _keyword = '';
  List<Food> _allFoods = [];
  Map<String, int> _selectedQuantities = {};
  Map<String, int> _mealTargets = const {};

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String get keyword => _keyword;
  Map<String, int> get mealTargets => _mealTargets;

  List<Food> get visibleFoods {
    if (_keyword.trim().isEmpty) return _allFoods;
    final query = _keyword.trim().toLowerCase();
    return _allFoods.where((food) {
      return food.name.toLowerCase().contains(query) ||
          food.description.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    final data = await JournalService.loadJournalData();
    _allFoods = data.allFoods;
    _mealTargets = data.mealTargets[mealType] ?? const {};
    final meal = data.meals[mealType] ?? Meal.empty(mealType);
    _selectedQuantities = {
      for (final entry in meal.entries) entry.food.id: entry.quantity,
    };
    _isLoading = false;
    notifyListeners();
  }

  void updateKeyword(String value) {
    _keyword = value;
    notifyListeners();
  }

  int quantityOf(String foodId) => _selectedQuantities[foodId] ?? 0;

  void increase(Food food) {
    _selectedQuantities[food.id] = quantityOf(food.id) + 1;
    notifyListeners();
  }

  void decrease(Food food) {
    final current = quantityOf(food.id);
    if (current <= 1) {
      _selectedQuantities.remove(food.id);
    } else {
      _selectedQuantities[food.id] = current - 1;
    }
    notifyListeners();
  }

  List<MealEntry> get selectedEntries {
    final foodMap = {for (final food in _allFoods) food.id: food};
    final entries = <MealEntry>[];
    for (final item in _selectedQuantities.entries) {
      final food = foodMap[item.key];
      if (food != null && item.value > 0) {
        entries.add(MealEntry(food: food, quantity: item.value));
      }
    }
    return entries;
  }

  Meal get currentMeal => Meal(type: mealType, entries: selectedEntries);

  Future<void> saveSelection() async {
    _isSaving = true;
    notifyListeners();
    await JournalService.saveMealEntries(mealType: mealType, entries: selectedEntries);
    _isSaving = false;
    notifyListeners();
  }
}
