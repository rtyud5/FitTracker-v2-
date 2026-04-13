import 'package:flutter/material.dart';

import 'package:fittracker_source/Screens/active_screen/journal/journal_screen.dart';
import 'package:fittracker_source/Screens/active_screen/profile/controllers/profile_controller.dart';
import 'package:fittracker_source/Screens/active_screen/profile/widgets/edit_profile_sheet.dart';
import 'package:fittracker_source/Screens/active_screen/profile/widgets/nutrition_targets_section.dart';
import 'package:fittracker_source/Screens/active_screen/profile/widgets/profile_actions_section.dart';
import 'package:fittracker_source/Screens/active_screen/profile/widgets/profile_header_section.dart';
import 'package:fittracker_source/Screens/active_screen/profile/widgets/profile_summary_cards.dart';
import 'package:fittracker_source/Screens/active_screen/profile/widgets/weight_chart_section.dart';
import 'package:fittracker_source/Screens/active_screen/profile/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController()..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openEditProfile() async {
    final data = _controller.data;
    if (data == null) return;

    final result = await showModalBottomSheet<EditProfileResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => EditProfileSheet(
        initialName: data.displayName,
        initialGoal: data.goalLabel,
        initialCurrentWeightLbs: data.currentWeightLbs,
        initialTargetWeightLbs: data.goalWeightLbs,
      ),
    );

    if (result == null) return;
    await _controller.updateProfile(
      name: result.name,
      goal: result.goal,
      currentWeightLbs: result.currentWeightLbs,
      targetWeightLbs: result.targetWeightLbs,
    );
  }

  Future<void> _openAddWeightDialog() async {
    final controller = TextEditingController(
      text: _controller.data?.currentWeightLbs.toStringAsFixed(1) ?? '',
    );
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add weight entry'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Weight (lbs)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, double.tryParse(controller.text.trim())),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == null) return;
    await _controller.addWeightEntry(result);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final data = _controller.data;
        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : data == null
                  ? Center(
                      child: Text(_controller.errorMessage ?? 'No profile data found'),
                    )
                  : RefreshIndicator(
                      onRefresh: _controller.load,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          ProfileHeaderSection(
                            name: data.displayName,
                            goal: data.goalLabel,
                            accountCreatedDate: data.accountCreatedDate,
                            avatarFile: _controller.avatarFile,
                            onPickAvatar: () { _controller.pickAvatar(); },
                            onOpenSettings: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SettingsScreen()),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          ProfileSummaryCards(
                            startWeightLbs: data.startWeightLbs,
                            currentWeightLbs: data.currentWeightLbs,
                            goalWeightLbs: data.goalWeightLbs,
                            bmi: data.bmi,
                            dailyCalories: data.dailyCalories,
                          ),
                          const SizedBox(height: 16),
                          WeightChartSection(
                            selectedRangeDays: _controller.selectedRangeDays,
                            labels: _controller.chartLabels,
                            weights: _controller.chartWeights,
                            onRangeChanged: _controller.setRangeDays,
                          ),
                          const SizedBox(height: 16),
                          NutritionTargetsSection(
                            dailyCalories: data.dailyCalories,
                            macroTargets: data.macroTargets,
                          ),
                          const SizedBox(height: 16),
                          ProfileActionsSection(
                            onAddWeight: () { _openAddWeightDialog(); },
                            onEditProfile: () { _openEditProfile(); },
                            onOpenSettings: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SettingsScreen()),
                              );
                            },
                            onOpenJournal: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const JournalScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 1,
            onTap: (index) {
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const JournalScreen()),
                );
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Journal'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}
