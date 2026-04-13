import 'package:flutter/foundation.dart';

import 'package:fittracker_source/Screens/active_screen/journal/services/journal_service.dart';
import 'package:fittracker_source/models/meal.dart';
import 'package:fittracker_source/models/meal_type.dart';

class JournalController extends ChangeNotifier {
  JournalData? _data;
  bool _isLoading = false;
  String? _errorMessage;

  JournalData? get data => _data;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _data = await JournalService.loadJournalData();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load journal: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Meal mealOf(MealType type) => _data?.meals[type] ?? Meal.empty(type);

  Map<String, int> targetsOf(MealType type) => _data?.mealTargets[type] ?? const <String, int>{};

  int get totalCaloriesConsumed {
    if (_data == null) return 0;
    return _data!.meals.values.fold(0, (sum, meal) => sum + meal.totalCalories);
  }

  int get totalProteinConsumed {
    if (_data == null) return 0;
    return _data!.meals.values.fold(0, (sum, meal) => sum + meal.totalProtein);
  }

  int get totalFatConsumed {
    if (_data == null) return 0;
    return _data!.meals.values.fold(0, (sum, meal) => sum + meal.totalFat);
  }

  int get totalCarbsConsumed {
    if (_data == null) return 0;
    return _data!.meals.values.fold(0, (sum, meal) => sum + meal.totalCarbs);
  }

  int get totalFiberConsumed {
    if (_data == null) return 0;
    return _data!.meals.values.fold(0, (sum, meal) => sum + meal.totalFiber);
  }

  int get cupsDrank => _data?.cupsDrank ?? 0;

  int get totalCupsGoal {
    final goal = _data?.waterGoalLiters ?? 2.0;
    return (goal / JournalService.cupVolumeLiters).ceil();
  }

  double get waterDrankLiters => cupsDrank * JournalService.cupVolumeLiters;

  Future<void> setWaterCups(int value) async {
    if (_data == null) return;
    final sanitized = value.clamp(0, totalCupsGoal);
    _data = JournalData(
      displayName: _data!.displayName,
      dailyCaloriesTarget: _data!.dailyCaloriesTarget,
      dailyMacroTargets: _data!.dailyMacroTargets,
      mealTargets: _data!.mealTargets,
      meals: _data!.meals,
      waterGoalLiters: _data!.waterGoalLiters,
      cupsDrank: sanitized,
      allFoods: _data!.allFoods,
    );
    notifyListeners();
    await JournalService.saveWaterCups(sanitized);
  }

  Future<void> incrementWater() => setWaterCups(cupsDrank + 1);
  Future<void> decrementWater() => setWaterCups(cupsDrank - 1);
}
