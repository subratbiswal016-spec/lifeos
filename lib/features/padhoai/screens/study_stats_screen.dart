import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../providers/study_provider.dart';

class StudyStatsScreen extends ConsumerWidget {
  const StudyStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final Color padhoColor = const Color(0xFF6C63FF);
    final statsAsync = ref.watch(studyStatsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Study Statistics', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: statsAsync.when(
        data: (stats) {
          if (stats.isEmpty) {
             return const Center(child: Text('No study stats available yet. Start a timer!'));
          }
          final totalHours = stats['totalHours']?.toString() ?? '0';
          final thisWeekHours = stats['thisWeekHours']?.toString() ?? '0';
          final studyStreak = stats['studyStreak']?.toString() ?? '0';
          final Map<String, dynamic> breakdown = stats['subjectBreakdown'] ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  child: Row(
                    children: [
                      Expanded(child: _buildStatCard(theme, 'Total Hours', totalHours, Iconsax.clock, padhoColor)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard(theme, 'This Week', thisWeekHours, Iconsax.calendar_1, Colors.orange)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  child: _buildStatCard(theme, 'Current Streak', '$studyStreak Days', Iconsax.flash_1, Colors.amber),
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Text('Subject Breakdown', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                if (breakdown.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text('No subject data yet.', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                    ),
                  )
                else
                  ...breakdown.entries.map((entry) {
                    return FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: padhoColor.withValues(alpha: 0.2)),
                          boxShadow: [
                            BoxShadow(color: padhoColor.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: padhoColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Iconsax.book, color: padhoColor),
                                ),
                                const SizedBox(width: 16),
                                Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            Text('${entry.value}h', style: TextStyle(fontWeight: FontWeight.bold, color: padhoColor, fontSize: 16)),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 16),
          Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}
