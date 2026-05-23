import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onBackground),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 4,
                  ),
                  image: const DecorationImage(
                    image: NetworkImage('https://i.pravatar.cc/150?img=11'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Name and Email
              Text(
                'Namaste User',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'user@example.com',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 32),
              
              // Profile Options
              _buildProfileOption(
                context,
                icon: Iconsax.user_edit,
                title: 'Edit Profile',
                onTap: () {
                  context.push('/profile/edit');
                },
              ),
              _buildProfileOption(
                context,
                icon: Iconsax.notification,
                title: 'Notifications',
                onTap: () {
                  context.push('/profile/notifications');
                },
              ),
              _buildProfileOption(
                context,
                icon: Iconsax.moon,
                title: 'Dark Mode',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dark Mode toggled!')),
                  );
                },
                trailing: Switch(
                  value: true,
                  onChanged: (val) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dark Mode toggled!')),
                    );
                  },
                  activeColor: theme.colorScheme.primary,
                ),
              ),
              _buildProfileOption(
                context,
                icon: Iconsax.lock,
                title: 'Privacy & Security',
                onTap: () {
                  context.push('/profile/privacy');
                },
              ),
              const SizedBox(height: 32),
              
              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Implement Logout logic
                    context.go('/login');
                  },
                  icon: const Icon(Iconsax.logout, color: Colors.white),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF44336), // Error Red
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.onBackground.withOpacity(0.05),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              trailing ??
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.onBackground.withOpacity(0.3),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
