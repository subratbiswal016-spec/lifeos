import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class ReminderDetailsScreen extends StatelessWidget {
  final String title;

  const ReminderDetailsScreen({super.key, this.title = 'Reminder Details'});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Reminder Details', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Iconsax.edit), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Icon(Iconsax.notification, size: 64, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('Today at 02:00 PM', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Notes', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Please remember to take this medication after lunch. Do not take it on an empty stomach.', style: theme.textTheme.bodyLarge),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminder Marked as Done!')));
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF4CAF50), // Green for done
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('Mark as Done', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
