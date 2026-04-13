import 'package:flutter/material.dart';
import 'package:fittracker_source/services/user_service.dart';

class Step4ListDietaryRestrictions extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step4ListDietaryRestrictions({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<Step4ListDietaryRestrictions> createState() =>
      _Step4ListDietaryRestrictionsState();
}

class _Step4ListDietaryRestrictionsState
    extends State<Step4ListDietaryRestrictions> {
  List<String> selectedRestrictions = [];

  final List<String> options = [
    "Veganism",
    "Vegetarianism",
    "Pescetarianism",
    "Gluten-Free",
    "Lactose intolerant",
    "Nut allergy",
    "Seafood or Shellfish",
    "Other",
    "None",
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedRestrictions();
  }

  Future<void> _loadSavedRestrictions() async {
    final savedRestrictions = await UserService.getDietaryRestrictionsList();
    if (savedRestrictions != null && savedRestrictions.isNotEmpty) {
      if (mounted) {
        setState(() {
          selectedRestrictions = savedRestrictions
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        });
      }
    }
  }

  Future<void> _saveRestrictions() async {
    final restrictionsString = selectedRestrictions.join(', ');
    await UserService.updateDietaryRestrictionsList(
      restrictionsString,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(30, 40, 30, 20),
            child: Text(
              "Which restrictions/allergies do you have?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: options.map((item) {
                  final isSelected = selectedRestrictions.contains(item);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedRestrictions.remove(item);
                        } else {
                          selectedRestrictions.add(item);
                        }
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
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
                      child: Row(
                        children: [
                          Expanded(
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
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.green
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? Colors.green : Colors.grey,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: widget.onBack,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.grey[200],
                  ),
                  child: const Text(
                    "Back",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: selectedRestrictions.isEmpty
                      ? null
                      : () async {
                          await _saveRestrictions();
                          widget.onNext();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
