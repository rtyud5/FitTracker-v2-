import 'package:flutter/material.dart';

class EditProfileResult {
  final String name;
  final String goal;
  final double currentWeightLbs;
  final double targetWeightLbs;

  const EditProfileResult({
    required this.name,
    required this.goal,
    required this.currentWeightLbs,
    required this.targetWeightLbs,
  });
}

class EditProfileSheet extends StatefulWidget {
  final String initialName;
  final String initialGoal;
  final double initialCurrentWeightLbs;
  final double initialTargetWeightLbs;

  const EditProfileSheet({
    super.key,
    required this.initialName,
    required this.initialGoal,
    required this.initialCurrentWeightLbs,
    required this.initialTargetWeightLbs,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _goalController;
  late final TextEditingController _currentWeightController;
  late final TextEditingController _targetWeightController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _goalController = TextEditingController(text: widget.initialGoal);
    _currentWeightController = TextEditingController(text: widget.initialCurrentWeightLbs.toStringAsFixed(1));
    _targetWeightController = TextEditingController(text: widget.initialTargetWeightLbs.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Edit profile',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _goalController,
            decoration: const InputDecoration(labelText: 'Goal'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _currentWeightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Current weight (lbs)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _targetWeightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Target weight (lbs)'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(
                  EditProfileResult(
                    name: _nameController.text.trim(),
                    goal: _goalController.text.trim(),
                    currentWeightLbs: double.tryParse(_currentWeightController.text.trim()) ?? widget.initialCurrentWeightLbs,
                    targetWeightLbs: double.tryParse(_targetWeightController.text.trim()) ?? widget.initialTargetWeightLbs,
                  ),
                );
              },
              child: const Text('Save changes'),
            ),
          ),
        ],
      ),
    );
  }
}
