class SessionKeys {
  SessionKeys._();

  static const String hasLoggedOnce = 'has_logged_once';
  static const String userId = 'session_user_id';
  static const String username = 'session_username';
  static const String loginMode = 'session_login_mode';

  static const List<String> legacyHasLoggedOnce = ['hasLoggedOnce'];
  static const List<String> legacyUserIds = ['userid', 'user_id'];
  static const List<String> legacyUsernames = ['username', 'lastUsername'];
}
