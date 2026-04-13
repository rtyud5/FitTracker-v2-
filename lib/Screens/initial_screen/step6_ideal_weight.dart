import 'package:flutter/material.dart';

import 'package:fittracker_source/core/health/health_goal_helper.dart';
import 'package:fittracker_source/core/health/health_metrics_service.dart';
import 'package:fittracker_source/services/user_profile_service.dart';
import 'package:fittracker_source/services/user_service.dart';

class Step6IdealWeight extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const Step6IdealWeight({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<Step6IdealWeight> createState() => _Step6IdealWeightState();
}

class _Step6IdealWeightState extends State<Step6IdealWeight> {
  double? bmi;
  double? minIdealWeight;
  double? maxIdealWeight;
  double? suggestedWeight;
  double? height;
  double? weight;
  String? goal;
  String? _userId;
  bool _loading = true;
  bool _didResolveArgs = false;

  final TextEditingController _targetWeightController = TextEditingController();

  @override
  void dispose() {
    _targetWeightController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didResolveArgs) return;
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _userId = UserProfileService.resolveUserIdFromArgs(args);
    _didResolveArgs = true;
    _loadUserDataAndCalculate();
  }

  Future<void> _loadUserDataAndCalculate() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final profile = await UserProfileService.loadEffectiveProfile(userId: _userId);
    height = _toDouble(profile['height']);
    weight = _toDouble(profile['weight']);
    goal = HealthGoalHelper.displayLabel(profile['healthGoal'] ?? profile['goal']);

    final localTargetWeight = await UserService.getTargetWeight();
    if (localTargetWeight != null && localTargetWeight > 0) {
      _targetWeightController.text = localTargetWeight.toString();
    }

    if (height != null && weight != null && height! > 0) {
      final metrics = HealthMetricsService.calculateBmi(heightCm: height, weightKg: weight);
      bmi = metrics;

      final heightInMeters = height! / 100;
      minIdealWeight = 18.5 * heightInMeters * heightInMeters;
      maxIdealWeight = 24.9 * heightInMeters * heightInMeters;

      switch (HealthGoalHelper.normalize(goal)) {
        case HealthGoalHelper.weightGain:
          suggestedWeight = maxIdealWeight! - 1;
          break;
        case HealthGoalHelper.weightLoss:
          suggestedWeight = minIdealWeight! + 1;
          break;
        case HealthGoalHelper.muscleBuilding:
          suggestedWeight = minIdealWeight! + 2;
          break;
        default:
          suggestedWeight = (minIdealWeight! + maxIdealWeight!) / 2;
          break;
      }
      suggestedWeight = double.parse(suggestedWeight!.toStringAsFixed(1));
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim());
  }

  Future<void> _goToNext() async {
    final targetWeight = double.tryParse(_targetWeightController.text.trim());
    if (targetWeight == null || targetWeight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid target weight')),
      );
      return;
    }

    await UserService.updateTargetWeight(targetWeight);
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orangePrimary = Colors.orange;
    final orangeLight = Colors.orange.shade50;
    final orangeDarker = Colors.orange.shade800;
    final greenLight = Colors.green.shade50;
    final greenDark = Colors.green.shade800;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ideal Weight'),
        centerTitle: true,
        backgroundColor: orangeLight,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: orangeLight,
              shadowColor: orangePrimary.withValues(alpha: 0.4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Row(
                  children: [
                    Icon(Icons.monitor_weight, size: 48, color: orangePrimary),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your BMI',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: orangeDarker,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            bmi != null ? bmi!.toStringAsFixed(1) : '--',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: orangePrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 36),
            Text(
              'Ideal weight range for your height (${height != null ? height!.toInt() : '--'} cm):',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(color: greenLight, borderRadius: BorderRadius.circular(16)),
              child: Text(
                minIdealWeight != null && maxIdealWeight != null
                    ? '${minIdealWeight!.toStringAsFixed(1)} kg – ${maxIdealWeight!.toStringAsFixed(1)} kg'
                    : '-- kg – -- kg',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: greenDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 36),
            Text(
              'Based on your goal (${goal ?? '--'}):',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(color: orangeLight, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Icon(Icons.flag, color: orangePrimary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.titleMedium?.copyWith(color: Colors.black87),
                        children: [
                          const TextSpan(text: 'Suggested target weight: ', style: TextStyle(fontWeight: FontWeight.w700)),
                          TextSpan(
                            text: suggestedWeight != null ? '$suggestedWeight kg' : '-- kg',
                            style: TextStyle(fontWeight: FontWeight.bold, color: orangeDarker),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Text(
              'Enter your desired target weight:',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _targetWeightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: suggestedWeight != null ? '$suggestedWeight' : '',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: orangePrimary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                suffixText: 'kg',
                suffixStyle: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 56),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: widget.onPrevious,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                  ),
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: _goToNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orangePrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                  ),
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
