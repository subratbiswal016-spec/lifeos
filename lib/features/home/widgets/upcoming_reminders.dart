import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/widgets/glass_container.dart';

class UpcomingReminders extends StatelessWidget {
  final ThemeData theme;
  final List<dynamic> reminders;

  const UpcomingReminders({
    super.key, 
    required this.theme,
    this.reminders = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Reminders',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87),
        ),
        const SizedBox(height: 16),
        if (reminders.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('No upcoming reminders today.', style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white60 : Colors.black54)),
          )
        else
          ...reminders.map((r) {
            IconData icon = Iconsax.health;
            Color color = const Color(0xFFF44336);
            if (r['type'] == 'study') {
              icon = Iconsax.book;
              color = const Color(0xFF6C63FF);
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildReminderItem(
                context, 
                r['title'] ?? 'Reminder', 
                r['time'] ?? 'Soon', 
                icon, 
                color,
              ),
            );
          }),
      ],
    );
  }

  Widget _buildReminderItem(BuildContext context, String title, String time, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white60 : Colors.black54;

    return GlassContainer(
      onTap: () {
        context.push('/reminder_details/$title');
      },
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                const SizedBox(height: 4),
                Text(time, style: TextStyle(color: subtitleColor)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: subtitleColor)
        ],
      ),
    );
  }
}
