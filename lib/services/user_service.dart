import 'package:shared_preferences/shared_preferences.dart';

import 'package:fittracker_source/core/health/health_goal_helper.dart';
import 'package:fittracker_source/core/health/health_metrics_service.dart';
import 'package:fittracker_source/core/session/session_store.dart';

class UserService {
  UserService._();

  static const String _keyName = 'user_name';
  static const String _keyGender = 'user_gender';
  static const String _keyAge = 'user_age';
  static const String _keyHeight = 'user_height';
  static const String _keyWeight = 'user_weight';
  static const String _keyLifestyle = 'user_lifestyle';
  static const String _keyHasDietaryRestrictions = 'has_dietary_restrictions';
  static const String _keyDietaryRestrictionsList = 'dietary_restrictions_list';
  static const String _keyGoal = 'user_goal';
  static const String _keyTargetWeight = 'user_target_weight';
  static const String _keyIsSetupComplete = 'is_setup_complete';

  static Future<bool> saveUserInfo({
    String? name,
    required String gender,
    required int age,
    required double height,
    required double weight,
    required String lifestyle,
    required String hasDietaryRestrictions,
    required String dietaryRestrictionsList,
    required String goal,
    required double targetWeight,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final futures = <Future<bool>>[
        prefs.setString(_keyGender, gender),
        prefs.setInt(_keyAge, age),
        prefs.setDouble(_keyHeight, height),
        prefs.setDouble(_keyWeight, weight),
        prefs.setString(_keyLifestyle, lifestyle),
        prefs.setString(_keyHasDietaryRestrictions, hasDietaryRestrictions),
        prefs.setString(_keyDietaryRestrictionsList, dietaryRestrictionsList),
        prefs.setString(_keyGoal, HealthGoalHelper.normalize(goal)),
        prefs.setDouble(_keyTargetWeight, targetWeight),
        prefs.setBool(_keyIsSetupComplete, true),
      ];
      if (name != null && name.trim().isNotEmpty) {
        futures.add(prefs.setString(_keyName, name.trim()));
      }
      await Future.wait(futures);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> setSetupComplete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_keyIsSetupComplete, value);
  }

  static Future<bool> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_keyName, name.trim());
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName);
  }

  static Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final isSetupComplete = prefs.getBool(_keyIsSetupComplete) ?? false;
    final username = await SessionStore.getUsername();

    final savedGoal = prefs.getString(_keyGoal);

    final profile = <String, dynamic>{
      'username': username,
      'name': prefs.getString(_keyName),
      'gender': prefs.getString(_keyGender),
      'age': prefs.getInt(_keyAge),
      'height': prefs.getDouble(_keyHeight),
      'weight': prefs.getDouble(_keyWeight),
      'lifestyle': prefs.getString(_keyLifestyle),
      'hasDietaryRestrictions': prefs.getString(_keyHasDietaryRestrictions),
      'dietaryRestrictionsList': prefs.getString(_keyDietaryRestrictionsList),
      'goal': savedGoal == null ? null : HealthGoalHelper.normalize(savedGoal),
      'healthGoal': savedGoal == null ? null : HealthGoalHelper.normalize(savedGoal),
      'targetWeight': prefs.getDouble(_keyTargetWeight),
      'isSetupComplete': isSetupComplete,
    };

    final hasAnyProfileValue = profile.entries.any(
      (entry) => entry.key != 'isSetupComplete' && entry.value != null,
    );

    if (!isSetupComplete && !hasAnyProfileValue) {
      return null;
    }

    return profile;
  }

  static Future<bool> isSetupComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsSetupComplete) ?? false;
  }

  static Future<String?> getGender() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyGender);
  }

  static Future<int?> getAge() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyAge);
  }

  static Future<double?> getHeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyHeight);
  }

  static Future<double?> getWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyWeight);
  }

  static Future<String?> getLifestyle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLifestyle);
  }

  static Future<String?> getDietaryRestrictions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyHasDietaryRestrictions);
  }

  static Future<String?> getHasDietaryRestrictions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyHasDietaryRestrictions);
  }

  static Future<String?> getDietaryRestrictionsList() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDietaryRestrictionsList);
  }

  static Future<String?> getGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyGoal);
    return value == null ? null : HealthGoalHelper.normalize(value);
  }

  static Future<double?> getTargetWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyTargetWeight);
  }

  static Future<bool> updateName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_keyName, name.trim());
  }

  static Future<bool> updateGender(String gender) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_keyGender, gender);
  }

  static Future<bool> updateAge(int age) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setInt(_keyAge, age);
  }

  static Future<bool> updateHeight(double height) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setDouble(_keyHeight, height);
  }

  static Future<bool> updateWeight(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setDouble(_keyWeight, weight);
  }

  static Future<bool> updateLifestyle(String lifestyle) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_keyLifestyle, lifestyle);
  }

  static Future<bool> updateDietaryRestrictions(String restrictions) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_keyHasDietaryRestrictions, restrictions);
  }

  static Future<bool> updateHasDietaryRestrictions(String hasRestrictions) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_keyHasDietaryRestrictions, hasRestrictions);
  }

  static Future<bool> updateDietaryRestrictionsList(String restrictionsList) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_keyDietaryRestrictionsList, restrictionsList);
  }

  static Future<bool> updateGoal(String goal) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_keyGoal, HealthGoalHelper.normalize(goal));
  }

  static Future<bool> updateTargetWeight(double targetWeight) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setDouble(_keyTargetWeight, targetWeight);
  }

  static Future<bool> clearUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_keyName),
        prefs.remove(_keyGender),
        prefs.remove(_keyAge),
        prefs.remove(_keyHeight),
        prefs.remove(_keyWeight),
        prefs.remove(_keyLifestyle),
        prefs.remove(_keyHasDietaryRestrictions),
        prefs.remove(_keyDietaryRestrictionsList),
        prefs.remove(_keyGoal),
        prefs.remove(_keyTargetWeight),
        prefs.remove(_keyIsSetupComplete),
      ]);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<double?> calculateBMI() async {
    return HealthMetricsService.calculateBmi(
      heightCm: await getHeight(),
      weightKg: await getWeight(),
    );
  }

  static Future<int?> calculateDailyCalories() async {
    return HealthMetricsService.calculateDailyCalories(
      gender: await getGender(),
      age: await getAge(),
      heightCm: await getHeight(),
      weightKg: await getWeight(),
      lifestyle: await getLifestyle(),
    );
  }

  static Future<Map<String, int>?> calculateMacroTargets() async {
    return HealthMetricsService.calculateMacroTargets(
      dailyCalories: await calculateDailyCalories(),
    );
  }


  static Future<bool> hasCompleteData() async {
    final userInfo = await getUserInfo();
    if (userInfo == null) return false;
    const requiredFields = [
      'gender',
      'age',
      'height',
      'weight',
      'lifestyle',
      'goal',
    ];
    return requiredFields.every(
      (field) => userInfo[field] != null && userInfo[field].toString().trim().isNotEmpty,
    );
  }
}
