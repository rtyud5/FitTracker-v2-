import 'package:shared_preferences/shared_preferences.dart';

import 'session_keys.dart';

class SessionStore {
  SessionStore._();

  static Future<void> migrateLegacySession() async {
    final prefs = await SharedPreferences.getInstance();

    final userId = _firstString(prefs, SessionKeys.userId, SessionKeys.legacyUserIds);
    final username = _firstString(
      prefs,
      SessionKeys.username,
      SessionKeys.legacyUsernames,
    );
    final hasLoggedOnce = _firstBool(
      prefs,
      SessionKeys.hasLoggedOnce,
      SessionKeys.legacyHasLoggedOnce,
    );

    if (userId != null && userId.isNotEmpty) {
      await prefs.setString(SessionKeys.userId, userId);
    }
    if (username != null && username.isNotEmpty) {
      await prefs.setString(SessionKeys.username, username);
    }
    if (hasLoggedOnce != null) {
      await prefs.setBool(SessionKeys.hasLoggedOnce, hasLoggedOnce);
    }
  }

  static Future<void> saveAuthenticatedSession({
    required String userId,
    required String username,
    String loginMode = 'legacy_firestore',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(SessionKeys.userId, userId),
      prefs.setString(SessionKeys.username, username),
      prefs.setString(SessionKeys.loginMode, loginMode),
      prefs.setBool(SessionKeys.hasLoggedOnce, true),
      // backward compatibility for old code that might still read legacy keys
      prefs.setString('userid', userId),
      prefs.setString('user_id', userId),
      prefs.setString('username', username),
      prefs.setString('lastUsername', username),
      prefs.setBool('hasLoggedOnce', true),
    ]);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return _firstString(prefs, SessionKeys.userId, SessionKeys.legacyUserIds);
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return _firstString(prefs, SessionKeys.username, SessionKeys.legacyUsernames);
  }

  static Future<bool> hasLoggedInBefore() async {
    final prefs = await SharedPreferences.getInstance();
    return _firstBool(prefs, SessionKeys.hasLoggedOnce, SessionKeys.legacyHasLoggedOnce) ?? false;
  }

  static Future<bool> hasActiveSession() async {
    final userId = await getUserId();
    return userId != null && userId.isNotEmpty;
  }

  static Future<void> clearSession({bool keepHasLoggedOnce = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final futures = <Future<bool>>[
      prefs.remove(SessionKeys.userId),
      prefs.remove(SessionKeys.username),
      prefs.remove(SessionKeys.loginMode),
      prefs.remove('userid'),
      prefs.remove('user_id'),
      prefs.remove('username'),
      prefs.remove('lastUsername'),
    ];
    if (!keepHasLoggedOnce) {
      futures.add(prefs.remove(SessionKeys.hasLoggedOnce));
      futures.add(prefs.remove('hasLoggedOnce'));
    }
    await Future.wait(futures);
  }

  static String? _firstString(
    SharedPreferences prefs,
    String canonicalKey,
    List<String> legacyKeys,
  ) {
    final direct = prefs.getString(canonicalKey);
    if (direct != null && direct.isNotEmpty) return direct;
    for (final key in legacyKeys) {
      final value = prefs.getString(key);
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static bool? _firstBool(
    SharedPreferences prefs,
    String canonicalKey,
    List<String> legacyKeys,
  ) {
    if (prefs.containsKey(canonicalKey)) {
      return prefs.getBool(canonicalKey);
    }
    for (final key in legacyKeys) {
      if (prefs.containsKey(key)) {
        return prefs.getBool(key);
      }
    }
    return null;
  }
}
