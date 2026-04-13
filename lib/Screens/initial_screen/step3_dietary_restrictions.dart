import 'package:flutter/material.dart';
import 'package:fittracker_source/services/user_service.dart';

class Step3DietaryRestriction extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Function(int) onSkipToStep;
  final Function(bool) onDecision;

  const Step3DietaryRestriction({
    Key? key,
    required this.onNext,
    required this.onBack,
    required this.onSkipToStep,
    required this.onDecision,
  }) : super(key: key);

  @override
  State<Step3DietaryRestriction> createState() =>
      _Step3DietaryRestrictionState();
}

class _Step3DietaryRestrictionState extends State<Step3DietaryRestriction> {
  String? selectedOption;

  bool get isOptionSelected => selectedOption != null;

  @override
  void initState() {
    super.initState();
    _loadSelectedOption();
  }

  Future<void> _loadSelectedOption() async {
    final saved = await UserService.getHasDietaryRestrictions();
    if (saved != null && (saved == 'Yes' || saved == 'No')) {
      setState(() {
        selectedOption = saved;
      });
    }
  }

  Future<void> _saveSelectedOption() async {
    if (selectedOption != null) {
      await UserService.updateHasDietaryRestrictions(selectedOption!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Image.asset(
                    'Assets/Images/imagePage6.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Do you have any dietary restrictions or food allergies?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: ["Yes", "No"].map((item) {
                      final isSelected = selectedOption == item;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedOption = item;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                              right: item == "Yes" ? 8 : 0,
                              left: item == "No" ? 8 : 0,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFFF0D9)
                                  : const Color(0xFFF7F9FB),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey[800],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              Positioned(
                bottom: 20,
                left: 0,
                child: ElevatedButton(
                  onPressed: widget.onBack,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Back",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),

              if (isOptionSelected)
                Positioned(
                  bottom: 20,
                  right: 0,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _saveSelectedOption(); // Lưu vào user_service khi ấn Next
                      final shouldSkip = selectedOption == 'No';
                      widget.onDecision(shouldSkip);
                      widget.onNext();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      backgroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Next",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
