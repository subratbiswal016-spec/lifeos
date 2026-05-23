import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class UpcomingReminders extends StatelessWidget {
  final ThemeData theme;

  const UpcomingReminders({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Reminders',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildReminderItem(context, 'Dolo 650 - Papa', '02:00 PM', Iconsax.health, const Color(0xFFF44336)),
        const SizedBox(height: 12),
        _buildReminderItem(context, 'Study: Modern History', '04:00 PM', Iconsax.book, const Color(0xFF6C63FF)),
      ],
    );
  }

  Widget _buildReminderItem(BuildContext context, String title, String time, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        context.push('/reminder_details/$title');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.onBackground.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(time, style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6))),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onBackground.withOpacity(0.3))
        ],
      ),
      ),
    );
  }
}
