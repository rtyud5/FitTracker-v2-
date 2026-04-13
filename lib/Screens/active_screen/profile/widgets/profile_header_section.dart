import 'dart:io';

import 'package:flutter/material.dart';

class ProfileHeaderSection extends StatelessWidget {
  final String name;
  final String goal;
  final DateTime? accountCreatedDate;
  final File? avatarFile;
  final VoidCallback onPickAvatar;
  final VoidCallback onOpenSettings;

  const ProfileHeaderSection({
    super.key,
    required this.name,
    required this.goal,
    required this.accountCreatedDate,
    required this.avatarFile,
    required this.onPickAvatar,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final joinedText = accountCreatedDate == null
        ? 'Welcome back'
        : 'Joined ${accountCreatedDate!.day.toString().padLeft(2, '0')}/${accountCreatedDate!.month.toString().padLeft(2, '0')}/${accountCreatedDate!.year}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: Colors.teal.shade100,
                backgroundImage: avatarFile != null ? FileImage(avatarFile!) : null,
                child: avatarFile == null
                    ? const Icon(Icons.person, size: 38, color: Colors.teal)
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: InkWell(
                  onTap: onPickAvatar,
                  child: const CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.black87,
                    child: Icon(Icons.edit, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  goal,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.teal.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  joinedText,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onOpenSettings,
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
    );
  }
}
