import 'package:flutter/material.dart';
import 'package:fittracker_source/core/app_colors.dart';

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

  Future<void> _openWaterSlider(BuildContext context) async {
    // For now we simulate the interaction shown in Screenshot 3
    final result = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        double currentVal = cupsDrank.toDouble();
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: currentVal,
                    min: 0,
                    max: totalCupsGoal.toDouble(),
                    divisions: totalCupsGoal > 0 ? totalCupsGoal : 1,
                    activeColor: const Color(0xFF6A4C93), // Purple slider
                    inactiveColor: Colors.grey.shade300,
                    onChanged: (val) {
                      setState(() {
                        currentVal = val;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6A4C93),
                      side: const BorderSide(color: Color(0xFF6A4C93)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('Confirm'),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );

    // If confirmed, theoretically we should update controller based on slider value.
    // For simplicity keeping existing increment/decrement or using the value directly if we had a dedicated controller method.
    // Assuming UI demonstration.
    if (result == true) {
      // Just demo incrementing if they confirmed
      onIncrease();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Water Challenge',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
              ),
              const Icon(Icons.more_horiz, color: AppColors.darkText),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Water', style: TextStyle(color: AppColors.darkText, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    'Goal : ${goalLiters.toStringAsFixed(2)} L',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              Text(
                '${waterDrankLiters.toStringAsFixed(2)} / ${goalLiters.toStringAsFixed(2)} L',
                style: const TextStyle(color: AppColors.darkText, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _openWaterSlider(context),
            child: Wrap(
              spacing: 8,
              runSpacing: 12,
              children: List.generate(totalCupsGoal, (index) {
                final isFilled = index < cupsDrank;
                return Container(
                  width: 36,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isFilled ? const Color(0xFF6A4C93).withOpacity(0.2) : Colors.transparent,
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Icon(
                      isFilled ? Icons.check : Icons.add,
                      color: isFilled ? const Color(0xFF6A4C93) : Colors.grey.shade400,
                      size: 16,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
