import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fittracker_source/core/health/health_goal_helper.dart';
import 'package:fittracker_source/core/session/session_store.dart';
import 'package:fittracker_source/services/user_service.dart';

class UserProfileService {
  UserProfileService._();

  static Future<Map<String, dynamic>> loadEffectiveProfile({String? userId}) async {
    final resolvedUserId = userId ?? await SessionStore.getUserId();
    final local = await UserService.getUserInfo() ?? <String, dynamic>{};
    final remote = await _loadRemoteProfile(resolvedUserId);

    final profile = <String, dynamic>{...local, ...remote};

    final goal = profile['healthGoal'] ?? profile['goal'];
    if (goal != null) {
      final normalizedGoal = HealthGoalHelper.normalize(goal);
      profile['healthGoal'] = normalizedGoal;
      profile['goal'] = normalizedGoal;
    }

    profile.remove('password');
    profile.remove('legacyAuth');
    profile.remove('authProvider');
    profile.remove('authMigrationStatus');

    profile['userId'] = resolvedUserId ?? profile['userId'] ?? profile['userid'] ?? profile['user_id'];
    if (profile['username'] == null || profile['username'].toString().trim().isEmpty) {
      profile['username'] = await SessionStore.getUsername();
    }

    return profile;
  }

  static String? resolveUserIdFromArgs(Map<String, dynamic>? args) {
    if (args == null) return null;
    return args['userId']?.toString() ?? args['userid']?.toString() ?? args['user_id']?.toString();
  }

  static String? firstMissingField(Map<String, dynamic> profile) {
    const order = [
      'name',
      'gender',
      'age',
      'height',
      'weight',
      'lifestyle',
      'hasDietaryRestrictions',
      'healthGoal',
      'targetWeight',
    ];

    for (final key in order) {
      final value = key == 'healthGoal' ? (profile['healthGoal'] ?? profile['goal']) : profile[key];
      if (value == null) return key;
      if (value is String && value.trim().isEmpty) return key;
      if (value is num && value <= 0) return key;
    }
    return null;
  }

  static bool isProfileComplete(Map<String, dynamic> profile) {
    return firstMissingField(profile) == null;
  }

  static int stepIndexForMissingField(String? field) {
    switch (field) {
      case 'gender':
      case 'age':
      case 'height':
      case 'weight':
        return 1;
      case 'lifestyle':
        return 2;
      case 'hasDietaryRestrictions':
        return 3;
      case 'healthGoal':
        return 6;
      case 'targetWeight':
        return 7;
      case 'name':
      default:
        return 1;
    }
  }

  static Future<Map<String, dynamic>> _loadRemoteProfile(String? userId) async {
    if (userId == null || userId.isEmpty) return <String, dynamic>{};
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return doc.data() ?? <String, dynamic>{};
  }
}
