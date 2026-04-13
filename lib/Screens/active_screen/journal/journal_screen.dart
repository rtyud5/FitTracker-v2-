import 'package:flutter/material.dart';

import 'package:fittracker_source/Screens/active_screen/journal/controllers/journal_controller.dart';
import 'package:fittracker_source/Screens/active_screen/journal/food_search_screen.dart';
import 'package:fittracker_source/Screens/active_screen/journal/widgets/daily_progress_section.dart';
import 'package:fittracker_source/Screens/active_screen/journal/widgets/journal_actions_section.dart';
import 'package:fittracker_source/Screens/active_screen/journal/widgets/journal_header_section.dart';
import 'package:fittracker_source/Screens/active_screen/journal/widgets/macro_targets_section.dart';
import 'package:fittracker_source/Screens/active_screen/journal/widgets/meal_cards_section.dart';
import 'package:fittracker_source/Screens/active_screen/journal/widgets/water_tracker_section.dart';
import 'package:fittracker_source/Screens/active_screen/profile/profile_screen.dart';
import 'package:fittracker_source/Screens/initial_screen/ai_agent_screen.dart';
import 'package:fittracker_source/models/meal.dart';
import 'package:fittracker_source/models/meal_type.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late final JournalController _controller;

  @override
  void initState() {
    super.initState();
    _controller = JournalController()..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openMeal(MealType mealType) async {
    final shouldRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => SearchFoodScreen(mealType: mealType)),
    );
    if (shouldRefresh == true) {
      await _controller.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final data = _controller.data;
        return Scaffold(
          backgroundColor: const Color(0xFFCEE8E0), // Mint Background
          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : data == null
                  ? Center(child: Text(_controller.errorMessage ?? 'No journal data found'))
                  : SafeArea(
                      child: RefreshIndicator(
                        onRefresh: _controller.load,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            JournalHeaderSection(
                              userName: data.displayName,
                              onOpenProfile: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            DailyProgressSection(
                              consumedCalories: _controller.totalCaloriesConsumed,
                              targetCalories: data.dailyCaloriesTarget,
                            ),
                            const SizedBox(height: 24),
                            MacroTargetsSection(
                              protein: _controller.totalProteinConsumed,
                              fat: _controller.totalFatConsumed,
                              carbs: _controller.totalCarbsConsumed,
                              fiber: _controller.totalFiberConsumed,
                              targets: data.dailyMacroTargets,
                            ),
                            const SizedBox(height: 16),
                            MealCardsSection(
                              meals: {
                                for (final type in MealType.values)
                                  type: data.meals[type] ?? Meal.empty(type),
                              },
                              mealTargets: data.mealTargets,
                              onOpenMeal: _openMeal,
                            ),
                            const SizedBox(height: 16),
                            WaterTrackerSection(
                              cupsDrank: _controller.cupsDrank,
                              totalCupsGoal: _controller.totalCupsGoal,
                              waterDrankLiters: _controller.waterDrankLiters,
                              goalLiters: data.waterGoalLiters,
                              onDecrease: () { _controller.decrementWater(); },
                              onIncrease: () { _controller.incrementWater(); },
                            ),
                            const SizedBox(height: 16),
                            JournalActionsSection(
                              onOpenAiAssistant: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AIAgentScreen()),
                                );
                              },
                              onOpenProfile: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF10463A), // Primary Action
            unselectedItemColor: Colors.grey.shade400,
            currentIndex: 0,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
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
    );
  }
}
