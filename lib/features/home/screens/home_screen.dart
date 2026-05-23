import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';

import '../widgets/daily_tip_card.dart';
import '../widgets/quick_stats_card.dart';
import '../widgets/upcoming_reminders.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: theme.colorScheme.background,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    child: Text(
                      'Namaste, User! 🙏',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                  ),
                  FadeInDown(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      _getFormattedDate(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                FadeInDown(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                      backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=11'),
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: const DailyTipCard(),
                    ),
                    const SizedBox(height: 32),
                    
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        'Quick Access',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      duration: const Duration(milliseconds: 600),
                      child: Row(
                        children: [
                          Expanded(
                            child: QuickStatsCard(
                              title: 'My Life',
                              subtitle: 'Mood: 😊\nSpend: ₹120',
                              icon: Iconsax.heart,
                              color: const Color(0xFFFF6B35),
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: QuickStatsCard(
                              title: 'GharLog',
                              subtitle: '3 Meds Due\nAll Good',
                              icon: Iconsax.home,
                              color: const Color(0xFF2D6A4F),
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: QuickStatsCard(
                              title: 'PadhoAI',
                              subtitle: '2h 15m\nStreak: 4',
                              icon: Iconsax.book,
                              color: const Color(0xFF6C63FF),
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      duration: const Duration(milliseconds: 600),
                      child: const UpcomingReminders(),
                    ),
                    const SizedBox(height: 100), // padding for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FadeInUp(
        delay: const Duration(milliseconds: 800),
        child: FloatingActionButton.extended(
          onPressed: () {
            // Show bottom sheet with options: [Check In] [Add Log] [Start Study]
          },
          backgroundColor: theme.colorScheme.primary,
          icon: const Icon(Iconsax.add, color: Colors.white),
          label: const Text(
            'Quick Action',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
