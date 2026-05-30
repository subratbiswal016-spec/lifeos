import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';

import '../../../core/widgets/premium_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../providers/dashboard_provider.dart';
import '../providers/daily_tip_provider.dart';
import '../../ai_coach/screens/ai_coach_screen.dart';
import '../widgets/daily_tip_card.dart';
import '../widgets/quick_stats_card.dart';
import '../widgets/upcoming_reminders.dart';

class HomeScreen extends ConsumerWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  String _getFormattedDate() {
    final now = DateTime.now();
    final englishDate = DateFormat('EEEE, d MMM').format(now);
    return '$englishDate • आज'; 
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dashboardState = ref.watch(dashboardProvider);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        showOrbs: true,
        child: Column(
          children: [
            // Custom AppBar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  dashboardState.when(
                    loading: () => const SizedBox.shrink(),
                    error: (err, stack) => const SizedBox.shrink(),
                    data: (data) => FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Namaste, ${data['name'] ?? 'User'}! 🙏',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getFormattedDate(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: subtitleColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  FadeInRight(
                    duration: const Duration(milliseconds: 600),
                    child: InkWell(
                      onTap: () => context.push('/profile'),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.colorScheme.primary, width: 2),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: dashboardState.value?['profilePhotoUrl'] != null
                              ? (dashboardState.value!['profilePhotoUrl'].toString().startsWith('data:image')
                                  ? MemoryImage(base64Decode(dashboardState.value!['profilePhotoUrl'].toString().split(',').last))
                                  : NetworkImage(dashboardState.value!['profilePhotoUrl'])) as ImageProvider
                              : const NetworkImage('https://i.pravatar.cc/150?img=11'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.refresh(dashboardProvider);
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: dashboardState.when(
                    loading: () => const Center(child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    )),
                    error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
                    data: (data) {
                      final quickStats = data['quickStats'] ?? {};
                      final reminders = data['reminders'] as List? ?? [];
                      final dailyTipAsync = ref.watch(dailyTipProvider);
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeInUp(
                            delay: const Duration(milliseconds: 200),
                            child: dailyTipAsync.when(
                              data: (tip) => DailyTipCard(theme: theme, tip: tip),
                              loading: () => DailyTipCard(theme: theme, tip: 'Analyzing your daily progress...'),
                              error: (_, __) => DailyTipCard(theme: theme, tip: 'Keep pushing forward!'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Daily Check-in Banner
                          FadeInUp(
                            delay: const Duration(milliseconds: 300),
                            child: GlassContainer(
                              onTap: () => context.push('/mood_logger'),
                              padding: const EdgeInsets.all(20),
                              color: theme.colorScheme.primary.withOpacity(0.15),
                              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3), width: 1),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Iconsax.note_2, color: theme.colorScheme.primary, size: 28),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Daily Check-in', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text('Log your mood, sleep & energy', style: TextStyle(color: subtitleColor, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios, color: subtitleColor, size: 16),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          FadeInUp(
                            delay: const Duration(milliseconds: 400),
                            child: Text(
                              'Quick Access',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                  
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 140,
                                  child: FadeInUp(
                                    delay: const Duration(milliseconds: 500),
                                    child: QuickStatsCard(
                                      title: 'My Life',
                                      subtitle: 'Mood: ${quickStats['mood'] ?? '😊'}\nSleep: ${quickStats['sleep'] ?? 0}h • Nrg: ${quickStats['energy'] ?? 0}%',
                                      icon: Iconsax.heart,
                                      color: const Color(0xFFFF6B35),
                                      onTap: () => onNavigateTab?.call(1),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 140,
                                  child: FadeInUp(
                                    delay: const Duration(milliseconds: 600),
                                    child: QuickStatsCard(
                                      title: 'GharLog',
                                      subtitle: '${quickStats['familyMembers'] ?? 0} Members\n${quickStats['medsDue'] ?? 0} Meds Due',
                                      icon: Iconsax.home,
                                      color: const Color(0xFF2D6A4F),
                                      onTap: () => onNavigateTab?.call(2),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 140,
                                  child: FadeInUp(
                                    delay: const Duration(milliseconds: 700),
                                    child: QuickStatsCard(
                                      title: 'PadhoAI',
                                      subtitle: '${quickStats['subjectsStudied'] ?? 0} Subjs • ${quickStats['studyTime'] ?? 0}m\nStreak: ${quickStats['studyStreak'] ?? 0}',
                                      icon: Iconsax.book,
                                      color: const Color(0xFF6C63FF),
                                      onTap: () => onNavigateTab?.call(3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          FadeInUp(
                            delay: const Duration(milliseconds: 800),
                            child: UpcomingReminders(theme: theme, reminders: reminders),
                          ),
                          const SizedBox(height: 32),
                          const SizedBox(height: 100), // Extra padding to clear the global FAB
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FadeInUp(
        delay: const Duration(milliseconds: 1000),
        child: FloatingActionButton(
          heroTag: null,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => GlassContainer(
                borderRadius: 24,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Quick Actions', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 24),
                    ListTile(
                      leading: const Icon(Iconsax.note_2, color: Color(0xFFFF6B35)),
                      title: Text('Daily Check-in', style: TextStyle(color: textColor)),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/mood_logger');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.health, color: Color(0xFFF44336)),
                      title: Text('Add Medicine', style: TextStyle(color: textColor)),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/add_medicine');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.timer_1, color: Color(0xFF6C63FF)),
                      title: Text('Start Study Timer', style: TextStyle(color: textColor)),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/padhoai/timer');
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          backgroundColor: theme.colorScheme.primary,
          child: const Icon(Iconsax.add, color: Colors.white),
        ),
      ),
    );
  }
}
