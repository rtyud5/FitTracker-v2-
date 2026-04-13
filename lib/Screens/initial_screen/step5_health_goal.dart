import 'package:flutter/material.dart';

import 'package:fittracker_source/core/health/health_goal_helper.dart';
import 'package:fittracker_source/core/health/health_metrics_service.dart';
import 'package:fittracker_source/services/user_profile_service.dart';
import 'package:fittracker_source/services/user_service.dart';

class RangeProgressBar extends StatelessWidget {
  final double minValue;
  final double maxValue;
  final double currentValue;
  final String label;
  final Color barColor;

  const RangeProgressBar({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.currentValue,
    required this.label,
    this.barColor = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    final progress = ((currentValue - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
    final barWidth = MediaQuery.of(context).size.width - 48;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: barColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            Positioned(
              left: (progress * barWidth).clamp(0, barWidth - 20),
              top: -4,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: barColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(minValue.toStringAsFixed(1), style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(maxValue.toStringAsFixed(1), style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class Step5HealthGoal extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;

  const Step5HealthGoal({
    super.key,
    required this.onBack,
    required this.onNext,
  });

  @override
  State<Step5HealthGoal> createState() => _Step5HealthGoalState();
}

class _Step5HealthGoalState extends State<Step5HealthGoal> {
  String? selectedGoal;
  double? bmi;
  bool _loading = true;
  String? _userId;
  bool _didResolveArgs = false;

  final Map<String, List<double>> _bmiRanges = const {
    'Weight loss': [18.5, 24.9],
    'Weight gain': [25.0, 29.9],
    'Muscle building': [20.0, 30.0],
    'Maintain weight': [18.5, 24.9],
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didResolveArgs) return;
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _userId = UserProfileService.resolveUserIdFromArgs(args);
    _didResolveArgs = true;
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final profile = await UserProfileService.loadEffectiveProfile(userId: _userId);
    final goal = profile['healthGoal'] ?? profile['goal'];

    selectedGoal = goal == null ? null : HealthGoalHelper.displayLabel(goal);
    bmi = HealthMetricsService.calculateBmi(
      heightCm: _toDouble(profile['height']),
      weightKg: _toDouble(profile['weight']),
    );

    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _saveGoal() async {
    if (selectedGoal == null || selectedGoal!.isEmpty) return;
    await UserService.updateGoal(selectedGoal!);
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  Widget _goalOption(String label) {
    final isSelected = selectedGoal == label;
    return GestureDetector(
      onTap: () => setState(() => selectedGoal = label),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.orange : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final range = selectedGoal == null ? null : _bmiRanges[selectedGoal!];

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(30, 60, 30, 20),
          child: const Text(
            'What are your health goals?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...HealthGoalHelper.displayOptions.map(_goalOption),
                const SizedBox(height: 20),
                if (bmi != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your BMI: ${bmi!.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        if (range != null) ...[
                          const SizedBox(height: 14),
                          RangeProgressBar(
                            minValue: range[0],
                            maxValue: range[1],
                            currentValue: bmi!,
                            label: 'Recommended BMI range for $selectedGoal',
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: selectedGoal == null
                      ? null
                      : () async {
                          await _saveGoal();
                          widget.onNext();
                        },
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
