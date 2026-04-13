import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:fittracker_source/core/health/health_goal_helper.dart';

import 'auth_gateway.dart';
import 'user_service.dart';

class LegacyFirestoreAuthGateway implements AuthGateway {
  static const _authProvider = 'legacy_firestore';
  static const _migrationStatus = 'pending_firebase_auth_migration';

  CollectionReference<Map<String, dynamic>> get _users =>
      FirebaseFirestore.instance.collection('users');

  CollectionReference<Map<String, dynamic>> get _usernames =>
      FirebaseFirestore.instance.collection('usernames');

  DocumentReference<Map<String, dynamic>> get _counterRef =>
      FirebaseFirestore.instance.collection('_system').doc('user_counter');

  @override
  Future<AuthGatewayLoginResult> login({
    required String username,
    required String password,
  }) async {
    final trimmedUsername = username.trim();
    final trimmedPassword = password.trim();
    final doc = await _findUserDocumentByUsername(trimmedUsername);

    if (doc == null || !doc.exists) {
      return const AuthGatewayLoginResult(
        isSuccess: false,
        message: 'User not found',
      );
    }

    final userData = Map<String, dynamic>.from(
      doc.data() ?? const <String, dynamic>{},
    );

    final storedPassword = _extractLegacyPassword(userData);
    if (storedPassword == null || storedPassword != trimmedPassword) {
      return const AuthGatewayLoginResult(
        isSuccess: false,
        message: 'Wrong password',
      );
    }

    await _ensureUsernameIndex(trimmedUsername, doc.id);
    await _migrateLegacyAuthShape(
      userRef: doc.reference,
      userData: userData,
      verifiedPassword: trimmedPassword,
    );

    final sanitized = _sanitizeUserData(doc.id, userData, trimmedUsername);

    return AuthGatewayLoginResult(
      isSuccess: true,
      userId: doc.id,
      username: trimmedUsername,
      userData: sanitized,
    );
  }

  @override
  Future<AuthGatewayRegisterResult> register({
    required String username,
    required String password,
    required Map<String, dynamic> localProfile,
  }) async {
    final trimmedUsername = username.trim();
    final trimmedPassword = password.trim();
    final usernameKey = _usernameKey(trimmedUsername);
    final userDocRef = _users.doc();
    final usernameRef = _usernames.doc(usernameKey);
    final template = await _loadProfileTemplate();
    final mergedLocalProfile = await _buildMergedLocalProfile(localProfile);

    late final String displayId;

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final usernameSnap = await transaction.get(usernameRef);
        if (usernameSnap.exists) {
          throw StateError('USERNAME_ALREADY_EXISTS');
        }

        final counterSnap = await transaction.get(_counterRef);
        final lastDisplayId =
            (counterSnap.data()?['lastDisplayId'] as num?)?.toInt() ?? 0;
        final nextDisplayId = lastDisplayId + 1;
        displayId = nextDisplayId.toString().padLeft(3, '0');

        final dataToSave = _composeRemoteUserDocument(
          template: template,
          mergedLocalProfile: mergedLocalProfile,
          documentId: userDocRef.id,
          displayId: displayId,
          username: trimmedUsername,
          password: trimmedPassword,
        );

        transaction.set(_counterRef, {
          'lastDisplayId': nextDisplayId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        transaction.set(userDocRef, dataToSave, SetOptions(merge: true));

        transaction.set(usernameRef, {
          'userRef': userDocRef.id,
          'username': trimmedUsername,
          'displayId': displayId,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });
    } on StateError catch (e) {
      if (e.message == 'USERNAME_ALREADY_EXISTS') {
        return const AuthGatewayRegisterResult(
          isSuccess: false,
          message: 'Username already exists!',
        );
      }

      return AuthGatewayRegisterResult(isSuccess: false, message: e.toString());
    }

    await UserService.clearUserInfo();

    return AuthGatewayRegisterResult(
      isSuccess: true,
      userId: userDocRef.id,
      username: trimmedUsername,
    );
  }

  @override
  Future<void> logout() async {}

  Future<DocumentSnapshot<Map<String, dynamic>>?> _findUserDocumentByUsername(
    String username,
  ) async {
    final usernameKey = _usernameKey(username);
    final usernameDoc = await _usernames.doc(usernameKey).get();

    final indexedUserRef = usernameDoc.data()?['userRef']?.toString();
    if (indexedUserRef != null && indexedUserRef.isNotEmpty) {
      final indexedUserDoc = await _users.doc(indexedUserRef).get();
      if (indexedUserDoc.exists) return indexedUserDoc;
    }

    final fallbackQuery = await _users
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (fallbackQuery.docs.isEmpty) return null;
    return fallbackQuery.docs.first;
  }

  Future<void> _ensureUsernameIndex(String username, String userId) async {
    final usernameKey = _usernameKey(username);
    final usernameRef = _usernames.doc(usernameKey);
    final usernameDoc = await usernameRef.get();

    if (usernameDoc.exists &&
        usernameDoc.data()?['userRef']?.toString() == userId) {
      return;
    }

    await usernameRef.set({
      'userRef': userId,
      'username': username,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _migrateLegacyAuthShape({
    required DocumentReference<Map<String, dynamic>> userRef,
    required Map<String, dynamic> userData,
    required String verifiedPassword,
  }) async {
    final updates = <String, dynamic>{
      'userId': userRef.id,
      'authProvider': _authProvider,
      'authMigrationStatus': _migrationStatus,
    };

    final legacyAuth = userData['legacyAuth'];
    final nestedPassword = legacyAuth is Map
        ? legacyAuth['password']?.toString()
        : null;
    final topLevelPassword = userData['password']?.toString();

    if ((nestedPassword == null || nestedPassword.isEmpty) &&
        verifiedPassword.isNotEmpty) {
      updates['legacyAuth'] = {
        'password': verifiedPassword,
        'algorithm': 'plaintext_legacy',
        'migratedAt': FieldValue.serverTimestamp(),
      };
    }

    if (topLevelPassword != null && topLevelPassword.isNotEmpty) {
      updates['password'] = FieldValue.delete();
    }

    final displayId = userData['displayId']?.toString().trim();
    final legacyUserCode = userData['userid']?.toString().trim();

    if ((displayId == null || displayId.isEmpty) &&
        legacyUserCode != null &&
        legacyUserCode.isNotEmpty) {
      updates['displayId'] = legacyUserCode;
      updates['userid'] = legacyUserCode;
    }

    if (updates.length > 3 || userData['userId']?.toString() != userRef.id) {
      await userRef.set(updates, SetOptions(merge: true));
    }
  }

  Map<String, dynamic> _sanitizeUserData(
    String documentId,
    Map<String, dynamic> raw,
    String username,
  ) {
    final sanitized = Map<String, dynamic>.from(raw);
    sanitized.remove('password');
    sanitized.remove('legacyAuth');
    sanitized['userId'] = documentId;
    sanitized['username'] = username;

    final normalizedGoal = HealthGoalHelper.normalize(
      sanitized['healthGoal'] ?? sanitized['goal'],
    );
    sanitized['healthGoal'] = normalizedGoal;
    sanitized['goal'] = normalizedGoal;

    return sanitized;
  }

  String? _extractLegacyPassword(Map<String, dynamic> userData) {
    final legacyAuth = userData['legacyAuth'];
    if (legacyAuth is Map) {
      final nested = legacyAuth['password']?.toString();
      if (nested != null && nested.isNotEmpty) return nested;
    }

    final topLevel = userData['password']?.toString();
    if (topLevel != null && topLevel.isNotEmpty) return topLevel;

    return null;
  }

  String _usernameKey(String username) => username.trim().toLowerCase();

  Future<Map<String, dynamic>> _loadProfileTemplate() async {
    try {
      final raw = await rootBundle.loadString('Assets/user_profile.json');
      final parsed = jsonDecode(raw);
      if (parsed is Map<String, dynamic>) return parsed;
    } catch (_) {}

    return {
      'userId': null,
      'userid': null,
      'displayId': null,
      'username': null,
      'name': null,
      'gender': null,
      'age': null,
      'height': null,
      'weight': null,
      'lifestyle': null,
      'hasDietaryRestrictions': null,
      'dietaryRestrictionsList': null,
      'healthGoal': null,
      'goal': null,
      'targetWeight': null,
      'isSetupComplete': false,
      'registeredAt': null,
    };
  }

  Future<Map<String, dynamic>> _buildMergedLocalProfile(
    Map<String, dynamic> localProfile,
  ) async {
    final merged = <String, dynamic>{...localProfile};

    final name = await UserService.getName();
    final gender = await UserService.getGender();
    final age = await UserService.getAge();
    final height = await UserService.getHeight();
    final weight = await UserService.getWeight();
    final lifestyle = await UserService.getLifestyle();
    final hasRestrictions = await UserService.getHasDietaryRestrictions();
    final restrictionList = await UserService.getDietaryRestrictionsList();
    final goal = await UserService.getGoal();
    final targetWeight = await UserService.getTargetWeight();

    if (name != null && name.isNotEmpty) merged['name'] = name;
    if (gender != null && gender.isNotEmpty) merged['gender'] = gender;
    if (age != null) merged['age'] = age;
    if (height != null) merged['height'] = height;
    if (weight != null) merged['weight'] = weight;
    if (lifestyle != null && lifestyle.isNotEmpty) {
      merged['lifestyle'] = lifestyle;
    }
    if (hasRestrictions != null) {
      merged['hasDietaryRestrictions'] = hasRestrictions;
    }
    if (restrictionList != null && restrictionList.isNotEmpty) {
      merged['dietaryRestrictionsList'] = restrictionList;
    }
    if (goal != null && goal.isNotEmpty) {
      final normalizedGoal = HealthGoalHelper.normalize(goal);
      merged['healthGoal'] = normalizedGoal;
      merged['goal'] = normalizedGoal;
    }
    if (targetWeight != null) merged['targetWeight'] = targetWeight;

    return merged;
  }

  Map<String, dynamic> _composeRemoteUserDocument({
    required Map<String, dynamic> template,
    required Map<String, dynamic> mergedLocalProfile,
    required String documentId,
    required String displayId,
    required String username,
    required String password,
  }) {
    final dataToSave = <String, dynamic>{};

    for (final entry in template.entries) {
      switch (entry.key) {
        case 'userId':
        case 'userid':
        case 'displayId':
        case 'username':
        case 'registeredAt':
        case 'isSetupComplete':
        case 'password':
          continue;
        default:
          dataToSave[entry.key] = mergedLocalProfile[entry.key] ?? entry.value;
      }
    }

    final normalizedGoal = HealthGoalHelper.normalize(
      mergedLocalProfile['healthGoal'] ?? mergedLocalProfile['goal'],
    );

    dataToSave['userId'] = documentId;
    dataToSave['userid'] = displayId;
    dataToSave['displayId'] = displayId;
    dataToSave['username'] = username;
    dataToSave['authProvider'] = _authProvider;
    dataToSave['authMigrationStatus'] = _migrationStatus;
    dataToSave['legacyAuth'] = {
      'password': password,
      'algorithm': 'plaintext_legacy',
      'requiresMigration': true,
    };
    dataToSave['healthGoal'] = normalizedGoal;
    dataToSave['goal'] = normalizedGoal;
    dataToSave['age'] = _toInt(mergedLocalProfile['age']);
    dataToSave['height'] = _toDouble(mergedLocalProfile['height']);
    dataToSave['weight'] = _toDouble(mergedLocalProfile['weight']);
    dataToSave['targetWeight'] = _toDouble(mergedLocalProfile['targetWeight']);
    dataToSave['registeredAt'] = FieldValue.serverTimestamp();
    dataToSave['isSetupComplete'] = _isSetupComplete(dataToSave);

    return dataToSave;
  }

  bool _isSetupComplete(Map<String, dynamic> data) {
    const required = [
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

    for (final key in required) {
      final value = key == 'healthGoal'
          ? (data['healthGoal'] ?? data['goal'])
          : data[key];

      if (value == null) return false;
      if (value is String && value.trim().isEmpty) return false;
      if (value is num && value <= 0) return false;
    }

    return true;
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString().trim());
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim().replaceAll(',', '.'));
  }
}
