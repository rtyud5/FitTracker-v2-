import 'package:flutter/material.dart';

class JournalActionsSection extends StatelessWidget {
  final VoidCallback onOpenAiAssistant;
  final VoidCallback onOpenProfile;

  const JournalActionsSection({
    super.key,
    required this.onOpenAiAssistant,
    required this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onOpenAiAssistant,
            icon: const Icon(Icons.smart_toy_outlined),
            label: const Text('AI assistant'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onOpenProfile,
            icon: const Icon(Icons.person_outline),
            label: const Text('Profile'),
          ),
        ),
      ],
    );
  }
}
