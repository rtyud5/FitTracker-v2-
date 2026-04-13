import 'package:flutter/material.dart';

class WaterTrackerSection extends StatelessWidget {
  final int cupsDrank;
  final int totalCupsGoal;
  final double waterDrankLiters;
  final double goalLiters;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const WaterTrackerSection({
    super.key,
    required this.cupsDrank,
    required this.totalCupsGoal,
    required this.waterDrankLiters,
    required this.goalLiters,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Water tracker',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            '${waterDrankLiters.toStringAsFixed(2)} / ${goalLiters.toStringAsFixed(2)} L',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: totalCupsGoal == 0 ? 0 : (cupsDrank / totalCupsGoal).clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: Colors.grey.shade200,
            color: Colors.lightBlue,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(onPressed: onDecrease, icon: const Icon(Icons.remove_circle_outline)),
              Text('$cupsDrank / $totalCupsGoal cups'),
              const SizedBox(width: 8),
              IconButton(onPressed: onIncrease, icon: const Icon(Icons.add_circle_outline)),
            ],
          ),
        ],
      ),
    );
  }
}
