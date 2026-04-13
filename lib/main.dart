import 'package:firebase_core/firebase_core.dart';
// Trigger deploy with new secrets
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:fittracker_source/Screens/initial_screen/app_bootstrap_screen.dart';
import 'package:fittracker_source/firebase_options.dart';
import 'package:fittracker_source/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    tz.initializeTimeZones();
  }

  String? startupError;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService.initialize();
  } catch (e) {
    startupError = 'Firebase bootstrap failed: $e';
    debugPrint(startupError);
  }

  runApp(MyApp(startupError: startupError));
}

class MyApp extends StatelessWidget {
  final String? startupError;

  const MyApp({super.key, this.startupError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitTracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: startupError == null
          ? const AppBootstrapScreen()
          : _StartupErrorScreen(message: startupError!),
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  final String message;

  const _StartupErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 72, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text(
                'FitTracker could not connect to Firebase.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              const Text(
                'For web, make sure the Firebase web app is configured and redeploy the app.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
