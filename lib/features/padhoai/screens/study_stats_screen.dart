import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
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
                  child: _buildWeeklyGraph(theme, padhoColor, stats['dailyBreakdown'] ?? []),
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
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

  Widget _buildWeeklyGraph(ThemeData theme, Color color, List<dynamic> dailyData) {
    if (dailyData.isEmpty) return const SizedBox.shrink();

    // dailyData is a list of { date: 'YYYY-MM-DD', hours: 1.5 }
    // Sort from oldest to newest (should be 7 days)
    final sortedData = List<Map<String, dynamic>>.from(dailyData)
      ..sort((a, b) => a['date'].compareTo(b['date']));

    double maxHours = 0;
    for (var item in sortedData) {
      if ((item['hours'] as num) > maxHours) {
        maxHours = (item['hours'] as num).toDouble();
      }
    }
    // Add some padding to the top of the chart
    if (maxHours < 1) maxHours = 1;
    maxHours = (maxHours * 1.2).ceilToDouble();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Progress', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxHours,
                minY: 0,
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value >= 0 && value < sortedData.length) {
                          // Format date to show just the day like "Mon", "Tue"
                          final dateStr = sortedData[value.toInt()]['date'] as String;
                          final date = DateTime.parse(dateStr);
                          final dayStr = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(dayStr, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 10)),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString(), style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 10));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxHours > 5 ? (maxHours / 5) : 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                barGroups: sortedData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final hours = (entry.value['hours'] as num).toDouble();
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: hours,
                        color: color,
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxHours,
                          color: color.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
