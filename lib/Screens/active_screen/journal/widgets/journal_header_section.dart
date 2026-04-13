import 'package:flutter/material.dart';
import 'package:fittracker_source/core/app_colors.dart';

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.smart_toy_outlined, color: AppColors.darkText, size: 28),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_fire_department, color: AppColors.fireIconColor, size: 20),
              const SizedBox(width: 4),
              Text(
                '0',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.darkText),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
