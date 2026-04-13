import 'package:flutter/material.dart';
import 'package:fittracker_source/core/app_colors.dart';

class MacroTargetsSection extends StatefulWidget {
  final int protein;
  final int fat;
  final int carbs;
  final int fiber;
  final Map<String, int> targets;

  const MacroTargetsSection({
    super.key,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.fiber,
    required this.targets,
  });

  @override
  State<MacroTargetsSection> createState() => _MacroTargetsSectionState();
}

class _MacroTargetsSectionState extends State<MacroTargetsSection> {
  bool _isExpanded = false;

  Widget _buildSummaryBar(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(2),
          ),
          // Here you'd ideally use Stack to show actual progress.
          // For now matching the static mockup look.
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkText, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildMacroCircle(String label, int value, int target, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 4),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.darkText),
              ),
              Text(
                '/${target}g',
                style: const TextStyle(fontSize: 10, color: AppColors.darkText),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Summary Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSummaryBar('Fat', AppColors.fatColor),
            _buildSummaryBar('Protein', AppColors.proteinColor),
            _buildSummaryBar('Carbs', AppColors.carbsColor),
            _buildSummaryBar('Fiber', AppColors.fiberColor),
          ],
        ),
        
        // Expand/Collapse Toggle
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppColors.darkText,
            ),
          ),
        ),

        // Expanded Content
        if (_isExpanded)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  'Macronutrients',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMacroCircle('Fat', widget.fat, widget.targets['fat'] ?? 0, AppColors.fatColor),
                    _buildMacroCircle('Protein', widget.protein, widget.targets['protein'] ?? 0, AppColors.proteinColor),
                    _buildMacroCircle('Carbs', widget.carbs, widget.targets['carbs'] ?? 0, AppColors.carbsColor),
                    _buildMacroCircle('Fiber', widget.fiber, widget.targets['fiber'] ?? 0, AppColors.fiberColor),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
