import 'package:flutter/material.dart';
import 'package:fittracker_source/services/user_service.dart';
import 'enter_name_screen.dart';

class Step1UserInfo extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step1UserInfo({super.key, required this.onNext, required this.onBack});

  @override
  State<Step1UserInfo> createState() => _Step1UserInfoState();
}

class _Step1UserInfoState extends State<Step1UserInfo> {
  String gender = '';
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  bool get isGenderSelected => gender.isNotEmpty;
  bool get isAgeEntered => ageController.text.isNotEmpty;
  bool get isHeightEntered => heightController.text.isNotEmpty;
  bool get isWeightEntered => weightController.text.isNotEmpty;
  bool get isAllCompleted =>
      isGenderSelected && isAgeEntered && isHeightEntered && isWeightEntered;

  @override
  void initState() {
    super.initState();
    ageController.addListener(() => setState(() {}));
    heightController.addListener(() => setState(() {}));
    weightController.addListener(() => setState(() {}));
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final savedGender = await UserService.getGender();
    final savedAge = await UserService.getAge();
    final savedHeight = await UserService.getHeight();
    final savedWeight = await UserService.getWeight();

    if (mounted) {
      setState(() {
        if (savedGender != null) gender = savedGender;
        if (savedAge != null) ageController.text = savedAge.toString();
        if (savedHeight != null) heightController.text = savedHeight.toString();
        if (savedWeight != null) weightController.text = savedWeight.toString();
      });
    }
  }

  @override
  void dispose() {
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "What is your gender?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Row(
                children: ["Male", "Female", "Non binary"].map((value) {
                  final isSelected = gender == value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(value),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          gender = value;
                        });
                      },
                      selectedColor: const Color(0xFFFFF0D9),
                      backgroundColor: Colors.grey.shade200,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.grey[700],
                      ),
                    ),
                  );
                }).toList(),
              ),

              if (isGenderSelected) ...[
                const SizedBox(height: 24),
                const Text(
                  "How old are you (years)?",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                _customInputField(controller: ageController),
              ],
              if (isGenderSelected && isAgeEntered) ...[
                const SizedBox(height: 20),
                const Text(
                  "What is your height (cm)?",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                _customInputField(controller: heightController),
              ],
              if (isGenderSelected && isAgeEntered && isHeightEntered) ...[
                const SizedBox(height: 20),
                const Text(
                  "What is your current weight (kg)?",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                _customInputField(controller: weightController),
              ],
            ],
          ),
        ),

        // Back button
        Positioned(
          left: 16,
          bottom: 30,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => EnterNameScreen()),
              );
            },
          ),
        ),

        // Next button
        if (isAllCompleted)
          Positioned(
            bottom: 30,
            right: 24,
            child: ElevatedButton(
              onPressed: () async {
                final age = int.tryParse(ageController.text);
                final height = double.tryParse(heightController.text);
                final weight = double.tryParse(weightController.text);

                if (age == null || height == null || weight == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter valid numbers!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                await Future.wait([
                  UserService.updateGender(gender),
                  UserService.updateAge(age),
                  UserService.updateHeight(height),
                  UserService.updateWeight(weight),
                ]);

                widget.onNext();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Next",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _customInputField({required TextEditingController controller}) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFFFF0D9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }
}