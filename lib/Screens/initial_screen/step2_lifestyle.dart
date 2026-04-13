import 'package:flutter/material.dart';
import 'package:fittracker_source/services/user_service.dart';

class Step2Lifestyle extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step2Lifestyle({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<Step2Lifestyle> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends State<Step2Lifestyle> {
  String selectedLifestyle = "";

  final List<String> options = [
    "Student",
    "Employed part-time",
    "Employed full-time",
    "Not employed",
    "Retired",
  ];

  bool get isLifestyleSelected => selectedLifestyle.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadSavedLifestyle();
  }

  Future<void> _loadSavedLifestyle() async {
    final savedLifestyle = await UserService.getLifestyle();
    if (savedLifestyle != null && savedLifestyle.isNotEmpty) {
      setState(() {
        selectedLifestyle = savedLifestyle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your daily life affects your weight.",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            const Text(
              "How would you describe your lifestyle?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: options.map((item) {
                    final isSelected = selectedLifestyle == item;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedLifestyle = item;
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
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                isSelected ? Colors.black : Colors.grey[800],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Nút Back và Next
            Row(
              children: [
                TextButton(
                  onPressed: widget.onBack,
                  child: const Text(
                    "Back",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const Spacer(),
                if (isLifestyleSelected)
                  ElevatedButton(
                    onPressed: () async {
                      await UserService.updateLifestyle(selectedLifestyle);
                      widget.onNext();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 24,
                      ),
                    ),
                    child: const Text(
                      "Next",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
