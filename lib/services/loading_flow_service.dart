import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fittracker_source/core/health/health_metrics_service.dart';
import 'package:fittracker_source/core/session/session_store.dart';
import 'package:fittracker_source/services/user_profile_service.dart';
import 'package:fittracker_source/services/user_service.dart';

class LoadingFlowResult {
  final bool isSuccess;
  final Map<String, dynamic>? profile;
  final String? error;

  const LoadingFlowResult._({
    required this.isSuccess,
    this.profile,
    this.error,
  });

  const LoadingFlowResult.success(Map<String, dynamic> profile)
      : this._(isSuccess: true, profile: profile);

  const LoadingFlowResult.failure(String error)
      : this._(isSuccess: false, error: error);
}

class LoadingFlowService {
  LoadingFlowService._();

  static Future<Map<String, dynamic>> buildLocalProfilePatch() async {
    final local = await UserService.getUserInfo();
    if (local == null) return {};

    final patch = <String, dynamic>{};
    final allowedKeys = {
      'name',
      'gender',
      'age',
      'height',
      'weight',
      'lifestyle',
      'hasDietaryRestrictions',
      'dietaryRestrictionsList',
      'healthGoal',
      'goal',
      'targetWeight',
    };

    for (final entry in local.entries) {
      if (!allowedKeys.contains(entry.key)) continue;
      final value = entry.value;
      if (value == null) continue;
      if (value is String && value.trim().isEmpty) continue;
      patch[entry.key] = value;
    }

    patch['isSetupComplete'] = true;
    return patch;
  }

  static Future<void> syncLocalProfileToRemote(String userId) async {
    final patch = await buildLocalProfilePatch();
    if (patch.isEmpty) return;

    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      ...patch,
      'userId': userId,
      'isSetupComplete': true,
    }, SetOptions(merge: true));

    await UserService.clearUserInfo();
  }

  static Future<LoadingFlowResult> run() async {
    final userId = await SessionStore.getUserId();
    if (userId == null || userId.isEmpty) {
      return const LoadingFlowResult.failure('Error: No active session found.');
    }

    await syncLocalProfileToRemote(userId);

    final profile = await UserProfileService.loadEffectiveProfile(userId: userId);
    if (profile.isEmpty) {
      return const LoadingFlowResult.failure('Error: Remote profile not found.');
    }

    final metrics = HealthMetricsService.calculateFromProfile(profile);
    if (metrics != null) {
      profile['bmi'] = metrics.bmi;
      profile['dailyCalories'] = metrics.dailyCalories;
      profile['macroTargets'] = metrics.macroTargets;
    }

    return LoadingFlowResult.success(profile);
  }
}
