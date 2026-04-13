import 'package:flutter/material.dart';

class PolicyAgreementScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const PolicyAgreementScreen({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<PolicyAgreementScreen> createState() => _PolicyAgreementScreenState();
}

class _PolicyAgreementScreenState extends State<PolicyAgreementScreen> {
  bool _isChecked = false;

  void _handleAgreeContinue() {
    if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please accept the terms and privacy policy before continuing.",
          ),
        ),
      );
      return;
    }
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6D0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Image.asset('Assets/Images/door.png', height: 120),
              const SizedBox(height: 24),

              const Text(
                "Your privacy matters",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A2D2F),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              _buildInfoRow(
                icon: 'Assets/Images/tomato.png',
                text:
                    'Your personal data is only used to give you personalized nutritional advice',
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: 'Assets/Images/lock.png',
                text: 'We do not share your personal data with third parties',
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: 'Assets/Images/mask.png',
                text: 'Your data stays between you and us',
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      // mở terms
                    },
                    child: const Text(
                      'Terms & conditions',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const Text('  ·  ', style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: () {
                      // mở policy
                    },
                    child: const Text(
                      'Privacy policy',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    onChanged: (value) {
                      setState(() {
                        _isChecked = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'I have read and accepted the terms and conditions and the privacy policy',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.onPrevious,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text("Back"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleAgreeContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text("Agree & Continue"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required String icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(icon, height: 36, width: 36),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
