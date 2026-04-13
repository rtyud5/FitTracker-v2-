import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fittracker_source/core/health/health_goal_helper.dart';
import 'package:fittracker_source/core/health/health_metrics_service.dart';
import 'package:fittracker_source/core/session/session_store.dart';
import 'package:fittracker_source/services/user_service.dart';

class ProfileData {
  final Map<String, dynamic> rawProfile;
  final String displayName;
  final String goalLabel;
  final int dailyCalories;
  final double? bmi;
  final DateTime? accountCreatedDate;
  final double startWeightLbs;
  final double currentWeightLbs;
  final double goalWeightLbs;
  final Map<String, int> macroTargets;
  final Map<String, double> weightHistoryMap;
  final String? avatarPath;

  const ProfileData({
    required this.rawProfile,
    required this.displayName,
    required this.goalLabel,
    required this.dailyCalories,
    required this.bmi,
    required this.accountCreatedDate,
    required this.startWeightLbs,
    required this.currentWeightLbs,
    required this.goalWeightLbs,
    required this.macroTargets,
    required this.weightHistoryMap,
    required this.avatarPath,
  });
}

class ProfileService {
  ProfileService._();

  static const _avatarPathKey = 'profile_avatar_path';
  static const _weightHistoryKey = 'weight_history_map_json';

  static Future<ProfileData?> loadProfile() async {
    final remote = await _loadRemoteProfile();
    final local = await UserService.getUserInfo();
    final profile = <String, dynamic>{...?local, ...?remote};
    if (profile.isEmpty) return null;

    final prefs = await SharedPreferences.getInstance();
    final accountCreatedDate = _parseAccountCreatedDate(profile['registeredAt']);
    final metrics = HealthMetricsService.calculateFromProfile(profile);
    final currentWeightKg = _toDouble(profile['weight']) ?? 70.0;
    final goalWeightKg = _toDouble(profile['targetWeight']) ?? currentWeightKg;
    final currentWeightLbs = _kgToLbs(currentWeightKg);

    final history = _loadWeightHistory(prefs);
    history[_dateKey(DateTime.now())] = currentWeightLbs;
    await _saveWeightHistory(prefs, history);

    final sortedEntries = history.entries.toList()
      ..sort((a, b) => _parseDateKey(a.key).compareTo(_parseDateKey(b.key)));
    final firstWeight = sortedEntries.isEmpty ? currentWeightLbs : sortedEntries.first.value;

    return ProfileData(
      rawProfile: profile,
      displayName: profile['name']?.toString().trim().isNotEmpty == true
          ? profile['name'].toString().trim()
          : (profile['username']?.toString() ?? 'User'),
      goalLabel: HealthGoalHelper.displayLabel(profile['healthGoal'] ?? profile['goal']),
      dailyCalories: metrics?.dailyCalories ?? 2000,
      bmi: metrics?.bmi,
      accountCreatedDate: accountCreatedDate,
      startWeightLbs: firstWeight,
      currentWeightLbs: currentWeightLbs,
      goalWeightLbs: _kgToLbs(goalWeightKg),
      macroTargets: metrics?.macroTargets ?? const {
        'protein': 75,
        'fat': 56,
        'carbs': 300,
        'fiber': 25,
      },
      weightHistoryMap: history,
      avatarPath: prefs.getString(_avatarPathKey),
    );
  }

  static Future<void> updateProfile({
    required String name,
    required String goal,
    required double currentWeightLbs,
    required double targetWeightLbs,
  }) async {
    final uid = await SessionStore.getUserId();
    final currentWeightKg = _lbsToKg(currentWeightLbs);
    final targetWeightKg = _lbsToKg(targetWeightLbs);
    final canonicalGoal = HealthGoalHelper.normalize(goal);

    await UserService.updateName(name);
    await UserService.updateGoal(canonicalGoal);
    await UserService.updateWeight(currentWeightKg);
    await UserService.updateTargetWeight(targetWeightKg);

    if (uid != null && uid.isNotEmpty) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'goal': canonicalGoal,
        'healthGoal': canonicalGoal,
        'weight': currentWeightKg,
        'targetWeight': targetWeightKg,
      }, SetOptions(merge: true));
    }

    await addWeightEntry(currentWeightLbs);
  }

  static Future<void> addWeightEntry(double weightLbs) async {
    final prefs = await SharedPreferences.getInstance();
    final history = _loadWeightHistory(prefs);
    history[_dateKey(DateTime.now())] = weightLbs;
    await _saveWeightHistory(prefs, history);

    final weightKg = _lbsToKg(weightLbs);
    await UserService.updateWeight(weightKg);

    final uid = await SessionStore.getUserId();
    if (uid != null && uid.isNotEmpty) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'weight': weightKg,
      }, SetOptions(merge: true));
    }
  }

  static Future<void> saveAvatarPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarPathKey, path);
  }

  static Future<Map<String, dynamic>?> _loadRemoteProfile() async {
    final uid = await SessionStore.getUserId();
    if (uid == null || uid.isEmpty) return null;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data();
  }

  static Map<String, double> _loadWeightHistory(SharedPreferences prefs) {
    final savedJson = prefs.getString(_weightHistoryKey);
    if (savedJson == null || savedJson.trim().isEmpty) return {};

    try {
      if (savedJson.trim().startsWith('{')) {
        final decoded = jsonDecode(savedJson) as Map<String, dynamic>;
        return decoded.map((key, value) => MapEntry(key, _toDouble(value) ?? 0));
      }

      final result = <String, double>{};
      for (final pair in savedJson.split('|')) {
        if (pair.trim().isEmpty || !pair.contains(':')) continue;
        final parts = pair.split(':');
        if (parts.length < 2) continue;
        final key = parts.first.trim();
        final value = _toDouble(parts.sublist(1).join(':'));
        if (value != null) result[key] = value;
      }
      return result;
    } catch (_) {
      return {};
    }
  }

  static Future<void> _saveWeightHistory(
    SharedPreferences prefs,
    Map<String, double> history,
  ) async {
    await prefs.setString(_weightHistoryKey, jsonEncode(history));
  }

  static DateTime? _parseAccountCreatedDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }



  static String _dateKey(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  static DateTime _parseDateKey(String key) {
    final now = DateTime.now();
    final parts = key.split('/');
    if (parts.length != 2) return now;
    final day = int.tryParse(parts[0]) ?? now.day;
    final month = int.tryParse(parts[1]) ?? now.month;
    return DateTime(now.year, month, day);
  }

  static double _kgToLbs(double kg) => kg * 2.20462;
  static double _lbsToKg(double lbs) => lbs / 2.20462;

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim().replaceAll(',', '.'));
  }
}
