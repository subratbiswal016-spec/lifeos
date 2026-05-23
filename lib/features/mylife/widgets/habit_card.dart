import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class HabitCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String progress;
  final bool isCompleted;

  const HabitCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.isCompleted,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isCompleted ? const Color(0xFF4CAF50) : const Color(0xFFFF6B35);

    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? theme.colorScheme.surface.withOpacity(0.5) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(isCompleted ? 0.4 : 0.1)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Iconsax.tick_circle : Iconsax.timer_1,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? Colors.grey : theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              progress,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          )
        ],
      ),
      ),
    );
  }
}
