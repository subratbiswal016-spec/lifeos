import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class MemberCard extends StatelessWidget {
  final String name;
  final String relation;
  final String age;
  final String? photoUrl;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const MemberCard({
    super.key,
    required this.name,
    required this.relation,
    required this.age,
    this.photoUrl,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color cardColor = const Color(0xFF2D6A4F); // GharLog Deep Green

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cardColor,
              cardColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: cardColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Builder(
              builder: (context) {
                Uint8List? photoBytes;
                if (photoUrl != null && photoUrl!.startsWith('data:image')) {
                  try {
                    final b64 = photoUrl!.split(',').last;
                    photoBytes = base64Decode(b64);
                  } catch (_) {}
                }
                return Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    image: photoBytes != null
                        ? DecorationImage(image: MemoryImage(photoBytes), fit: BoxFit.cover)
                        : null,
                  ),
                  child: photoBytes == null
                      ? const Icon(Iconsax.user, color: Colors.white, size: 30)
                      : null,
                );
              }
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$relation • $age Yrs',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
