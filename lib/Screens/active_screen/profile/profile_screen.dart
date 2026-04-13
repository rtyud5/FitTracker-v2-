import 'package:flutter/material.dart';

import 'package:fittracker_source/Screens/active_screen/journal/journal_screen.dart';
import 'package:fittracker_source/Screens/active_screen/profile/controllers/profile_controller.dart';
import 'package:fittracker_source/Screens/active_screen/profile/widgets/edit_profile_sheet.dart';
import 'package:fittracker_source/Screens/active_screen/profile/widgets/profile_header_section.dart';
import 'package:fittracker_source/Screens/active_screen/profile/widgets/profile_summary_cards.dart';
import 'package:fittracker_source/Screens/active_screen/profile/widgets/nutrition_tab_view.dart';
import 'package:fittracker_source/Screens/active_screen/profile/widgets/weight_tab_view.dart';
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
    return DefaultTabController(
      length: 2,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final data = _controller.data;
          
          if (_controller.isLoading) {
            return const Scaffold(
              backgroundColor: Color(0xFFCEE8E0),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (data == null) {
            return Scaffold(
              backgroundColor: const Color(0xFFCEE8E0),
              body: Center(child: Text(_controller.errorMessage ?? 'No profile data found')),
            );
          }

          return Scaffold(
            backgroundColor: const Color(0xFFCEE8E0), // Mint Background for top area
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top section (Mint Green Background)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
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
                          onEditProfile: _openEditProfile,
                        ),
                        const SizedBox(height: 16),
                        ProfileSummaryCards(
                          startWeightLbs: data.startWeightLbs,
                          currentWeightLbs: data.currentWeightLbs,
                          goalWeightLbs: data.goalWeightLbs,
                          bmi: data.bmi,
                          dailyCalories: data.dailyCalories,
                        ),
                      ],
                    ),
                  ),

                  // Bottom section (White Background with Tabs)
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: TabBar(
                              labelColor: Color(0xFF10463A), // Dark Green
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: Color(0xFF10463A),
                              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              tabs: [
                                Tab(text: 'Weight'),
                                Tab(text: 'Nutrition'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                // Weight Tab
                                WeightTabView(
                                  data: data,
                                  controller: _controller,
                                  onAddWeight: _openAddWeightDialog,
                                ),
                                // Nutrition Tab
                                NutritionTabView(
                                  data: data,
                                  controller: _controller,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF10463A), // Primary Action
              unselectedItemColor: Colors.grey.shade400,
              currentIndex: 1,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const JournalScreen()),
                  );
                }
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Journal'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              ],
            ),
          );
        },
      ),
    );
  }
}
