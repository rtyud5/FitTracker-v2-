import 'package:flutter/material.dart';
import 'package:fittracker_source/Screens/active_screen/profile/services/profile_service.dart';
import 'package:fittracker_source/Screens/active_screen/profile/controllers/profile_controller.dart';
import 'package:fittracker_source/Screens/active_screen/profile/widgets/weight_chart_section.dart';

class WeightTabView extends StatelessWidget {
  final ProfileData data;
  final ProfileController controller;
  final VoidCallback onAddWeight;

  const WeightTabView({
    super.key,
    required this.data,
    required this.controller,
    required this.onAddWeight,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  '${data.startWeightLbs.toStringAsFixed(1)} lbs',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('Start weight', style: TextStyle(color: Colors.grey)),
              ],
            ),
            Column(
              children: [
                Text(
                  '${data.currentWeightLbs.toStringAsFixed(1)} lbs',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('Current weight', style: TextStyle(color: Colors.grey)),
              ],
            ),
            Column(
              children: [
                Text(
                  '${data.goalWeightLbs.toStringAsFixed(1)} lbs',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('Goal weight', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: onAddWeight,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10463A), // Dark Actions
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('Add a weight entry', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 24),
        WeightChartSection(
          selectedRangeDays: controller.selectedRangeDays,
          labels: controller.chartLabels,
          weights: controller.chartWeights,
          onRangeChanged: controller.setRangeDays,
        ),
      ],
    );
  }
}
