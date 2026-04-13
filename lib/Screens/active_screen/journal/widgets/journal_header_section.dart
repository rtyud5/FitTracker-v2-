import 'package:flutter/material.dart';

class JournalHeaderSection extends StatelessWidget {
  final String userName;
  final VoidCallback onOpenProfile;

  const JournalHeaderSection({
    super.key,
    required this.userName,
    required this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateLabel = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $userName',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(dateLabel, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
        IconButton(
          onPressed: onOpenProfile,
          icon: const Icon(Icons.person_outline),
        ),
      ],
    );
  }
}
