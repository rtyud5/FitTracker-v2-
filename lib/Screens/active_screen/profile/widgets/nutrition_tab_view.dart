import 'package:flutter/material.dart';
import 'package:fittracker_source/Screens/active_screen/profile/services/profile_service.dart';
import 'package:fittracker_source/Screens/active_screen/profile/controllers/profile_controller.dart';
import 'package:fittracker_source/Screens/active_screen/profile/widgets/weight_chart_section.dart'; // We can reuse the chart widget logic visually
import 'package:fittracker_source/core/app_colors.dart';

class NutritionTabView extends StatelessWidget {
  final ProfileData data;
  final ProfileController controller;

  const NutritionTabView({
    super.key,
    required this.data,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Using existing WeightChartSection visually as it matches the standard chart layout
        // For 'Calories History', we just change the header visually or refactor the widget locally
        const Text(
          'Calories History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
        ),
        const SizedBox(height: 12),
        // Just reusing the segmented control and chart from weight chart section for calories simulation
        WeightChartSection(
          selectedRangeDays: controller.selectedRangeDays,
          labels: controller.chartLabels,
          weights: controller.chartWeights, // Mock using weights array to render a chart
          onRangeChanged: controller.setRangeDays,
        ),
        const SizedBox(height: 30),
        const Text(
          'Meal Grade',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFE2F3ED),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Center(
            child: Text(
              'No meal grade yet.',
              style: TextStyle(color: Color(0xFF10463A), fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
