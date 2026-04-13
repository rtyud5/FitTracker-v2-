import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fittracker_source/core/health/health_metrics_service.dart';
import 'package:fittracker_source/core/session/session_store.dart';
import 'package:fittracker_source/models/food.dart';
import 'package:fittracker_source/models/meal.dart';
import 'package:fittracker_source/models/meal_entry.dart';
import 'package:fittracker_source/models/meal_type.dart';

class JournalData {
  final String displayName;
  final int dailyCaloriesTarget;
  final Map<String, int> dailyMacroTargets;
  final Map<MealType, Map<String, int>> mealTargets;
  final Map<MealType, Meal> meals;
  final double waterGoalLiters;
  final int cupsDrank;
  final List<Food> allFoods;

  const JournalData({
    required this.displayName,
    required this.dailyCaloriesTarget,
    required this.dailyMacroTargets,
    required this.mealTargets,
    required this.meals,
    required this.waterGoalLiters,
    required this.cupsDrank,
    required this.allFoods,
  });
}

class JournalService {
  JournalService._();

  static const double cupVolumeLiters = 0.21;

  static Future<JournalData> loadJournalData() async {
    final uid = await SessionStore.getUserId();
    final userDoc = uid == null || uid.isEmpty
        ? null
        : await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final userInfo = userDoc?.data() ?? const <String, dynamic>{};
    final metrics = HealthMetricsService.calculateFromProfile(userInfo);
    final foodsSnapshot = await FirebaseFirestore.instance.collection('list_food').get();
    final allFoods = foodsSnapshot.docs.map((doc) => Food.fromMap(doc.data())).toList();
    final foodsById = {for (final food in allFoods) food.id: food};

    final dailyCalories = metrics?.dailyCalories ?? 2000;
    final macroTargets = metrics?.macroTargets ?? const {
      'protein': 75,
      'fat': 56,
      'carbs': 300,
      'fiber': 25,
    };
    final mealTargetsRaw = HealthMetricsService.calculateMealTargets(
      dailyCalories: dailyCalories,
      macroTargets: macroTargets,
    );

    final rawMeals = userInfo['meals'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final meals = {
      for (final mealType in MealType.values)
        mealType: Meal.fromFirestore(
          type: mealType,
          raw: rawMeals[mealType.key] as Map<String, dynamic>?,
          foodsById: foodsById,
        ),
    };

    final waterGoalLiters = HealthMetricsService.calculateHydrationGoalLiters(
      weightKg: _toDouble(userInfo['weight']),
    );
    final cupsDrank = await _loadWaterCups(uid ?? 'guest');

    return JournalData(
      displayName: userInfo['name']?.toString().trim().isNotEmpty == true
          ? userInfo['name'].toString().trim()
          : (await SessionStore.getUsername() ?? 'User'),
      dailyCaloriesTarget: dailyCalories,
      dailyMacroTargets: macroTargets,
      mealTargets: {
        MealType.breakfast: mealTargetsRaw['breakfast'] ?? const <String, int>{},
        MealType.lunch: mealTargetsRaw['lunch'] ?? const <String, int>{},
        MealType.dinner: mealTargetsRaw['dinner'] ?? const <String, int>{},
      },
      meals: meals,
      waterGoalLiters: waterGoalLiters,
      cupsDrank: cupsDrank,
      allFoods: allFoods,
    );
  }

  static Future<void> saveMealEntries({
    required MealType mealType,
    required List<MealEntry> entries,
  }) async {
    final uid = await SessionStore.getUserId();
    if (uid == null || uid.isEmpty) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
    final snapshot = await userDoc.get();
    final currentMeals = Map<String, dynamic>.from(snapshot.data()?['meals'] ?? const <String, dynamic>{});

    final meal = Meal(type: mealType, entries: entries);
    final payload = meal.toFirestoreMap();
    if (payload.isEmpty) {
      currentMeals.remove(mealType.key);
    } else {
      currentMeals[mealType.key] = payload;
    }

    await userDoc.set({'meals': currentMeals}, SetOptions(merge: true));
  }

  static Future<List<Food>> searchFoods(String keyword) async {
    final snapshot = await FirebaseFirestore.instance.collection('list_food').get();
    final allFoods = snapshot.docs.map((doc) => Food.fromMap(doc.data())).toList();
    if (keyword.trim().isEmpty) return allFoods;
    final query = keyword.trim().toLowerCase();
    return allFoods.where((food) {
      return food.name.toLowerCase().contains(query) ||
          food.description.toLowerCase().contains(query);
    }).toList();
  }

  static Future<void> saveWaterCups(int cups) async {
    final uid = await SessionStore.getUserId() ?? 'guest';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_waterKey(uid), cups);
  }

  static Future<int> _loadWaterCups(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_waterKey(uid)) ?? 0;
  }

  static String _waterKey(String uid) {
    final now = DateTime.now();
    final yyyy = now.year.toString().padLeft(4, '0');
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    return 'water_cups_${uid}_${yyyy}$mm$dd';
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim().replaceAll(',', '.'));
  }
}
