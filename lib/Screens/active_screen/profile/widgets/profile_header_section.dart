import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fittracker_source/core/app_colors.dart';

class ProfileHeaderSection extends StatelessWidget {
  final String name;
  final String goal;
  final DateTime? accountCreatedDate;
  final File? avatarFile;
  final VoidCallback onPickAvatar;
  final VoidCallback onOpenSettings;
  final VoidCallback? onEditProfile;

  const ProfileHeaderSection({
    super.key,
    required this.name,
    required this.goal,
    required this.accountCreatedDate,
    required this.avatarFile,
    required this.onPickAvatar,
    required this.onOpenSettings,
    this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFF1ABC9C), // App-like green color for avatar background
              backgroundImage: avatarFile != null ? FileImage(avatarFile!) : null,
              child: avatarFile == null
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    )
                  : null,
            ),
            Positioned(
              right: -4,
              bottom: -4,
              child: InkWell(
                onTap: onPickAvatar,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.grey, size: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkText),
                    ),
                    const SizedBox(width: 8),
                    if (onEditProfile != null)
                      InkWell(
                        onTap: onEditProfile,
                        child: const Icon(Icons.edit, size: 16, color: AppColors.darkText),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  goal,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF10463A), // Dark Green for goal
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: onOpenSettings,
          icon: const Icon(Icons.settings, color: AppColors.darkText),
        ),
      ],
    );
  }
}
