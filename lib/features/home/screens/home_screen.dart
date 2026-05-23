import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../widgets/daily_tip_card.dart';
import '../widgets/quick_stats_card.dart';
import '../widgets/upcoming_reminders.dart';

class HomeScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  String _getFormattedDate() {
    final now = DateTime.now();
    final englishDate = DateFormat('EEEE, d MMM').format(now);
    // Simple mock for Hindi translation of the day
    return '$englishDate • आज'; 
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Namaste, User! 🙏',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onBackground,
              ),
            ),
            Text(
              _getFormattedDate(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () => context.push('/profile'),
              borderRadius: BorderRadius.circular(20),
              child: CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=11'),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Mock refresh since Home currently has static widgets
            await Future.delayed(const Duration(seconds: 1));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DailyTipCard(theme: theme),
                const SizedBox(height: 24),
                
                // Daily Check-in Banner
                InkWell(
                  onTap: () => context.push('/mood_logger'),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFFFF6B35), const Color(0xFFFF6B35).withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFFF6B35).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                      ]
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Iconsax.note_2, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Daily Check-in', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('Log your mood, sleep & energy', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Text(
                  'Quick Access',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: QuickStatsCard(
                        title: 'My Life',
                        subtitle: 'Mood: 😊\nSpend: ₹120',
                        icon: Iconsax.heart,
                        color: const Color(0xFFFF6B35),
                        onTap: () => onNavigateTab?.call(1),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: QuickStatsCard(
                        title: 'GharLog',
                        subtitle: '3 Meds Due\nAll Good',
                        icon: Iconsax.home,
                        color: const Color(0xFF2D6A4F),
                        onTap: () => onNavigateTab?.call(2),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: QuickStatsCard(
                        title: 'PadhoAI',
                        subtitle: '2h 15m\nStreak: 4',
                        icon: Iconsax.book,
                        color: const Color(0xFF6C63FF),
                        onTap: () => onNavigateTab?.call(3),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                UpcomingReminders(theme: theme),
                const SizedBox(height: 100), // padding for FAB
              ],
            ),
          ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) => Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Quick Actions', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: const Icon(Iconsax.note_2, color: Color(0xFFFF6B35)),
                    title: const Text('Daily Check-in'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/mood_logger');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Iconsax.health, color: Color(0xFFF44336)),
                    title: const Text('Add Medicine'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/add_medicine');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Iconsax.timer_1, color: Color(0xFF6C63FF)),
                    title: const Text('Start Study Timer'),
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
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: const Text(
          'Quick Action',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
