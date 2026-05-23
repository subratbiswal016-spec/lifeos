import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool pushEnabled = true;
  bool emailEnabled = false;
  bool smsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildSwitch(theme, 'Push Notifications', 'Receive alerts on your device', pushEnabled, (v) => setState(() => pushEnabled = v)),
          const SizedBox(height: 16),
          _buildSwitch(theme, 'Email Notifications', 'Receive weekly summaries via email', emailEnabled, (v) => setState(() => emailEnabled = v)),
          const SizedBox(height: 16),
          _buildSwitch(theme, 'SMS Alerts', 'Important health reminders via SMS', smsEnabled, (v) => setState(() => smsEnabled = v)),
        ],
      ),
    );
  }

  Widget _buildSwitch(ThemeData theme, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6))),
        value: value,
        onChanged: onChanged,
        activeColor: theme.colorScheme.primary,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
