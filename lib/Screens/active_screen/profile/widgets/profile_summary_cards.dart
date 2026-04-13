import 'package:flutter/material.dart';
import 'package:fittracker_source/core/app_colors.dart';

class ProfileSummaryCards extends StatelessWidget {
  final double startWeightLbs; // Kept for compatibility but unused here
  final double currentWeightLbs; // Kept for compatibility but unused here
  final double goalWeightLbs; // Kept for compatibility but unused here
  final double? bmi;
  final int dailyCalories;

  const ProfileSummaryCards({
    super.key,
    required this.startWeightLbs,
    required this.currentWeightLbs,
    required this.goalWeightLbs,
    required this.bmi,
    required this.dailyCalories,
  });

  String _getBmiLabel(double bmiVal) {
    if (bmiVal < 18.5) return 'Underweight';
    if (bmiVal < 25) return 'Normal';
    if (bmiVal < 30) return 'Overweight';
    return 'Obese';
  }

  @override
  Widget build(BuildContext context) {
    String bmiString = bmi?.toStringAsFixed(1) ?? '-';
    String bmiLabel = bmi != null ? ' (${_getBmiLabel(bmi!)})' : '';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$dailyCalories Cal / d',
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkText, fontSize: 14),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFCBE3DB), // Very light mint
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'BMI $bmiString$bmiLabel',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10463A), fontSize: 14),
          ),
        ),
      ],
    );
  }
}
