import 'package:flutter/material.dart';

class ProfileActionsSection extends StatelessWidget {
  final VoidCallback onAddWeight;
  final VoidCallback onEditProfile;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenJournal;

  const ProfileActionsSection({
    super.key,
    required this.onAddWeight,
    required this.onEditProfile,
    required this.onOpenSettings,
    required this.onOpenJournal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onAddWeight,
                icon: const Icon(Icons.monitor_weight_outlined),
                label: const Text('Add weight'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onEditProfile,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit profile'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: onOpenSettings,
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Settings'),
              ),
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: onOpenJournal,
                icon: const Icon(Icons.menu_book_outlined),
                label: const Text('Go to journal'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
