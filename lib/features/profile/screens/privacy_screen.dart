import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Privacy & Security', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildActionItem(theme, Iconsax.password_check, 'Change Password', 'Update your account password'),
          const SizedBox(height: 16),
          _buildActionItem(theme, Icons.fingerprint, 'Biometric Login', 'Enable fingerprint or face unlock'),
          const SizedBox(height: 32),
          Text('Data Management', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildActionItem(theme, Iconsax.document_download, 'Download My Data', 'Get a copy of all your health logs'),
          const SizedBox(height: 16),
          _buildActionItem(theme, Iconsax.trash, 'Delete Account', 'Permanently remove your account and data', isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildActionItem(ThemeData theme, IconData icon, String title, String subtitle, {bool isDestructive = false}) {
    final color = isDestructive ? Colors.red : theme.colorScheme.onBackground;
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: isDestructive ? Border.all(color: Colors.red.withOpacity(0.3)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onBackground.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}
