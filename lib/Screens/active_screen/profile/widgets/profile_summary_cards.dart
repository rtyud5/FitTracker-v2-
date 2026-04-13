import 'package:flutter/material.dart';

class ProfileSummaryCards extends StatelessWidget {
  final double startWeightLbs;
  final double currentWeightLbs;
  final double goalWeightLbs;
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

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _StatCard(title: 'Start weight', value: '${startWeightLbs.toStringAsFixed(1)} lbs'),
        _StatCard(title: 'Current weight', value: '${currentWeightLbs.toStringAsFixed(1)} lbs'),
        _StatCard(title: 'Goal weight', value: '${goalWeightLbs.toStringAsFixed(1)} lbs'),
        _StatCard(title: 'BMI / Calories', value: '${bmi?.toStringAsFixed(1) ?? '-'} / $dailyCalories'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
