import 'package:flutter/material.dart';
import 'package:fittracker_source/core/app_colors.dart';

class DailyProgressSection extends StatelessWidget {
  final int consumedCalories;
  final int targetCalories;

  const DailyProgressSection({
    super.key,
    required this.consumedCalories,
    required this.targetCalories,
  });

  @override
  Widget build(BuildContext context) {
    // Determine calories left. Using safe min of 0 for UI.
    final calLeft = (targetCalories - consumedCalories).clamp(0, targetCalories);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Eaten
        Column(
          children: [
            Text(
              consumedCalories.toString(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            const Text(
              'Eaten',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkText),
            ),
          ],
        ),

        // Calories Left Circle
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF91B8AA), // Darker mint green for the circle
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                calLeft.toString(),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Text(
                'Cal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
              ),
              const Text(
                'left',
                style: TextStyle(fontSize: 14, color: AppColors.darkText),
              ),
            ],
          ),
        ),

        // Burned (Mocked as 0 for now as there's no explicitly passed burned calories)
        Column(
          children: [
            const Text(
              '0',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            const Text(
              'Burned',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkText),
            ),
          ],
        ),
      ],
    );
  }
}
