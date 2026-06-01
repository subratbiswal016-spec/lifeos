import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as flutter_secure_storage;
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/premium_background.dart';
import '../../../core/widgets/glass_container.dart';
import 'edit_profile_screen.dart'; // profileProvider

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(profileProvider);
    final currentColorTheme = ref.watch(themeProvider);
    final currentLanguage = ref.watch(languageProvider);
    final isDark = ref.read(themeProvider.notifier).isDark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        showOrbs: true,
        child: Column(
          children: [
            // App Bar
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Profile',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),

            Expanded(
              child: profileAsync.when(
                loading: () => Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
                error: (err, stack) => Center(
                  child: Text('Error: $err', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                ),
                data: (profileData) {
                  final name = profileData['name'] ?? 'User';
                  final email = profileData['email'] ?? 'user@example.com';

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar
                        FadeInDown(
                          duration: const Duration(milliseconds: 600),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.colorScheme.primary, width: 3),
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

                        FadeInDown(
                          delay: const Duration(milliseconds: 200),
                          child: Text(
                            name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        FadeInDown(
                          delay: const Duration(milliseconds: 300),
                          child: Text(
                            email,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Account Settings
                        _sectionHeader('Account Settings', theme, isDark),
                        const SizedBox(height: 12),
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
                                  subtitle: 'Change your name, city & goals',
                                  onTap: () => context.push('/profile/edit'),
                                  isDark: isDark,
                                  theme: theme,
                                ),
                                _divider(theme, isDark),
                                _buildOptionTile(
                                  context,
                                  icon: Iconsax.notification,
                                  title: 'Notifications',
                                  subtitle: 'Manage alerts & reminders',
                                  onTap: () => context.push('/profile/notifications'),
                                  isDark: isDark,
                                  theme: theme,
                                ),
                                _divider(theme, isDark),
                                _buildOptionTile(
                                  context,
                                  icon: Iconsax.lock,
                                  title: 'Privacy & Security',
                                  subtitle: 'Password, data & permissions',
                                  onTap: () => context.push('/profile/privacy'),
                                  isDark: isDark,
                                  theme: theme,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Appearance
                        _sectionHeader('Appearance', theme, isDark),
                        const SizedBox(height: 12),
                        FadeInUp(
                          delay: const Duration(milliseconds: 500),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Theme selector
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Iconsax.paintbucket, color: theme.colorScheme.primary, size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'App Theme',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: AppColorTheme.values.map((t) {
                                    final isSelected = currentColorTheme == t;
                                    return GestureDetector(
                                      onTap: () => ref.read(themeProvider.notifier).setTheme(t),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? theme.colorScheme.primary
                                              : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                                            width: 2,
                                          ),
                                          boxShadow: isSelected
                                              ? [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 8)]
                                              : [],
                                        ),
                                        child: Text(
                                          t.displayName,
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Language
                        _sectionHeader('Language', theme, isDark),
                        const SizedBox(height: 12),
                        FadeInUp(
                          delay: const Duration(milliseconds: 600),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Iconsax.language_square, color: theme.colorScheme.primary, size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'App Language',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Note: AI Chat always responds in English.',
                                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38),
                                ),
                                const SizedBox(height: 16),
                                ...AppLanguage.values.map((lang) {
                                  final isSelected = currentLanguage == lang;
                                  return GestureDetector(
                                    onTap: () => ref.read(languageProvider.notifier).setLanguage(lang),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? theme.colorScheme.primary.withOpacity(0.15)
                                            : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04)),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            lang.displayName,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? theme.colorScheme.primary
                                                  : (isDark ? Colors.white70 : Colors.black87),
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const Spacer(),
                                          if (isSelected)
                                            Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Logout
                        FadeInUp(
                          delay: const Duration(milliseconds: 700),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                const storage = flutter_secure_storage.FlutterSecureStorage();
                                await storage.delete(key: 'jwt_token');
                                if (context.mounted) context.go('/login');
                              },
                              icon: const Icon(Iconsax.logout, color: Colors.white),
                              label: const Text(
                                'Logout',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF3366),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  Widget _sectionHeader(String title, ThemeData theme, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white54 : Colors.black45,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _divider(ThemeData theme, bool isDark) {
    return Divider(
      height: 1,
      indent: 56,
      endIndent: 20,
      color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    required ThemeData theme,
  }) {
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
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.white30 : Colors.black26),
      onTap: onTap,
    );
  }
}
