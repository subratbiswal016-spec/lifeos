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
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Reminders',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        if (reminders.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Iconsax.notification_bing, color: Colors.grey.withOpacity(0.5), size: 32),
                const SizedBox(width: 12),
                Text(
                  'No reminders today 🎉',
                  style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                ),
              ],
            ),
          )
        else
          ...reminders.map((r) {
            final map = r as Map<String, dynamic>;
            IconData icon = Iconsax.health;
            Color color = const Color(0xFFF44336);
            if (map['type'] == 'study') {
              icon = Iconsax.book;
              color = const Color(0xFF6C63FF);
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildReminderItem(context, map, icon, color),
            );
          }),
      ],
    );
  }

  Widget _buildReminderItem(
    BuildContext context,
    Map<String, dynamic> reminder,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white60 : Colors.black54;
    final title = reminder['title'] ?? 'Reminder';
    final memberName = reminder['memberName'] ?? '';
    final time = reminder['time'] ?? 'Upcoming';
    final isTaken = reminder['isTaken'] == true;

    if (isTaken) {
      color = Colors.grey;
      icon = Icons.check_circle;
    }

    return GlassContainer(
      onTap: () {
        context.push('/reminder_details', extra: reminder);
      },
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      border: isTaken ? Border.all(color: Colors.grey.withOpacity(0.3)) : null,
      color: isTaken ? Colors.grey.withOpacity(0.05) : null,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTaken ? '$title (Taken)' : title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16, 
                    color: isTaken ? subtitleColor : textColor,
                    decoration: isTaken ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (memberName.isNotEmpty)
                  Text(
                    'For: $memberName',
                    style: TextStyle(fontSize: 12, color: subtitleColor),
                  ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Iconsax.clock, size: 12, color: color),
                    const SizedBox(width: 4),
                    Text(time, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          Icon(isTaken ? Icons.check : Icons.arrow_forward_ios, size: 14, color: isTaken ? Colors.green : subtitleColor),
        ],
      ),
    );
  }
}
