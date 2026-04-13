import 'package:flutter/material.dart';

import 'package:fittracker_source/Screens/active_screen/journal/journal_screen.dart';

import 'package:fittracker_source/Screens/initial_screen/welcome_screen.dart';
import 'package:fittracker_source/core/session/session_store.dart';


class AppBootstrapScreen extends StatefulWidget {
  const AppBootstrapScreen({super.key});

  @override
  State<AppBootstrapScreen> createState() => _AppBootstrapScreenState();
}

class _AppBootstrapScreenState extends State<AppBootstrapScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      await SessionStore.migrateLegacySession();
      final hasSession = await SessionStore.hasActiveSession();
      if (!mounted) return;

      if (!hasSession) {
        _replaceWith(const WelcomeScreen());
        return;
      }

      final userId = await SessionStore.getUserId();
      final username = await SessionStore.getUsername();

      _replaceWith(
        const JournalScreen(),
        arguments: {'userId': userId, 'username': username},
      );
    } catch (e) {
      debugPrint('Bootstrap error: $e');
      if (!mounted) return;
      _replaceWith(const WelcomeScreen());
    }
  }

  void _replaceWith(Widget screen, {Map<String, dynamic>? arguments}) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => screen,
        settings: RouteSettings(arguments: arguments),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
