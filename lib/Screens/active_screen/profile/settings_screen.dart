import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fittracker_source/Screens/initial_screen/welcome_screen.dart';
import 'package:fittracker_source/services/auth_service.dart';
import 'package:fittracker_source/services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _waterNotification = false;
  bool _mealNotification = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _waterNotification = prefs.getBool('water_notification') ?? false;
      _mealNotification = prefs.getBool('meal_notification') ?? false;
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _toggleWater(bool value) async {
    setState(() => _waterNotification = value);
    await _saveBool('water_notification', value);

    if (value) {
      const times = [
        [8, 0],
        [10, 0],
        [12, 0],
        [14, 0],
        [16, 0],
        [18, 0],
        [20, 0],
        [22, 0],
      ];
      for (int i = 0; i < times.length; i++) {
        await NotificationService.scheduleDailyNotification(
          id: 200 + i,
          title: 'Time to drink water',
          body: 'Stay hydrated! Log your water intake.',
          hour: times[i][0],
          minute: times[i][1],
        );
      }
    } else {
      for (int i = 0; i < 8; i++) {
        await NotificationService.cancel(200 + i);
      }
    }
  }

  Future<void> _toggleMeal(bool value) async {
    setState(() => _mealNotification = value);
    await _saveBool('meal_notification', value);

    if (value) {
      await NotificationService.scheduleDailyNotification(
        id: 101,
        title: 'Log your breakfast',
        body: 'Have you recorded your breakfast today?',
        hour: 8,
        minute: 0,
      );
      await NotificationService.scheduleDailyNotification(
        id: 102,
        title: 'Log your lunch',
        body: 'Don’t forget to log your lunch.',
        hour: 12,
        minute: 0,
      );
      await NotificationService.scheduleDailyNotification(
        id: 103,
        title: 'Log your dinner',
        body: 'Remember to log your dinner before the day ends.',
        hour: 18,
        minute: 0,
      );
    } else {
      await NotificationService.cancel(101);
      await NotificationService.cancel(102);
      await NotificationService.cancel(103);
    }
  }

  Future<void> _logOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await AuthService.logout();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Notification Preferences',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Water Log Reminder'),
            value: _waterNotification,
            onChanged: _toggleWater,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Meal Log Reminder'),
            value: _mealNotification,
            onChanged: _toggleMeal,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _logOut,
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
