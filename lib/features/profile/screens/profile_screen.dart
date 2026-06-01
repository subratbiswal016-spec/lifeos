import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as flutter_secure_storage;
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/premium_background.dart';
import '../../../core/widgets/glass_container.dart';
import 'edit_profile_screen.dart'; // To access profileProvider

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(profileProvider);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        showOrbs: true,
        child: Column(
          children: [
            // Custom App Bar
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Profile',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),
            ),

            Expanded(
              child: profileAsync.when(
                loading: () => Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
                error: (err, stack) => Center(
                  child: Text('Error: $err', style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54)),
                ),
                data: (profileData) {
                  final name = profileData['name'] ?? 'User';
                  final email = profileData['email'] ?? 'user@example.com';

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar with glow
                        FadeInDown(
                          duration: const Duration(milliseconds: 600),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.primary,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                              image: DecorationImage(
                                image: profileData['profilePhotoUrl'] != null 
                                    ? (profileData['profilePhotoUrl'].startsWith('data:image')
                                        ? MemoryImage(base64Decode(profileData['profilePhotoUrl'].split(',').last))
                                        : NetworkImage(profileData['profilePhotoUrl'])) as ImageProvider
                                    : const NetworkImage('https://i.pravatar.cc/150?img=11'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Name
                        FadeInDown(
                          delay: const Duration(milliseconds: 200),
                          child: Text(
                            name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        FadeInDown(
                          delay: const Duration(milliseconds: 300),
                          child: Text(
                            email,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.brightness == Brightness.dark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Options in Glass Card
                        FadeInUp(
                          delay: const Duration(milliseconds: 400),
                          child: GlassContainer(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              children: [
                                _buildOptionTile(
                                  context,
                                  icon: Iconsax.user_edit,
                                  title: 'Edit Profile',
                                  onTap: () => context.push('/profile/edit'),
                                ),
                                _divider(theme),
                                _buildOptionTile(
                                  context,
                                  icon: Iconsax.notification,
                                  title: 'Notifications',
                                  onTap: () => context.push('/profile/notifications'),
                                ),
                                _divider(theme),
                                _buildOptionTile(
                                  context,
                                  icon: isDark ? Iconsax.moon : Iconsax.sun_1,
                                  title: 'Dark Mode',
                                  onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
                                  trailing: Switch(
                                    value: isDark,
                                    onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
                                    activeColor: theme.colorScheme.primary,
                                    activeTrackColor: theme.colorScheme.primary.withOpacity(0.3),
                                  ),
                                ),
                                _divider(theme),
                                _buildOptionTile(
                                  context,
                                  icon: Iconsax.lock,
                                  title: 'Privacy & Security',
                                  onTap: () => context.push('/profile/privacy'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Logout Button
                        FadeInUp(
                          delay: const Duration(milliseconds: 600),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                const storage = flutter_secure_storage.FlutterSecureStorage();
                                await storage.delete(key: 'jwt_token');
                                if (context.mounted) {
                                  context.go('/login');
                                }
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
                                backgroundColor: const Color(0xFFFF3366),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 8,
                                shadowColor: const Color(0xFFFF3366).withOpacity(0.4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(ThemeData theme) {
    return Divider(
      height: 1,
      indent: 56,
      endIndent: 20,
      color: theme.brightness == Brightness.dark
          ? Colors.white.withOpacity(0.06)
          : Colors.black.withOpacity(0.06),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 22),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: theme.brightness == Brightness.dark ? Colors.white30 : Colors.black26,
          ),
      onTap: onTap,
    );
  }
}

