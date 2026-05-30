import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subject_provider.dart';

class SubjectDetailsScreen extends ConsumerWidget {
  final String subjectName;

  const SubjectDetailsScreen({super.key, this.subjectName = 'Subject Details'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final Color padhoColor = const Color(0xFF6C63FF);

    final subjectState = ref.watch(subjectProvider);
    final subject = subjectState.subjects.firstWhere(
      (s) => s.name == subjectName,
      orElse: () => subjectState.subjects.first,
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(subjectName, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Iconsax.edit), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: padhoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: padhoColor.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Icon(Iconsax.book, size: 48, color: padhoColor),
                    const SizedBox(height: 16),
                    Text('Study Progress', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text('Daily Target', style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6))),
                            Text('${subject.dailyTargetHours}h', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: padhoColor)),
                          ],
                        ),
                        Container(width: 1, height: 40, color: padhoColor.withOpacity(0.2)),
                        Column(
                          children: [
                            Text('Weekly Target', style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6))),
                            Text('${subject.weeklyTargetHours}h', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: padhoColor)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('You need to study ${subject.dailyTargetHours}h more today!', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            Text('Recent Mock Tests', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTestCard(theme, 'Chapter 1: Basics', 'Score: 85%', '2 days ago', Colors.green),
            _buildTestCard(theme, 'Chapter 2: Advanced', 'Score: 60%', '5 days ago', Colors.orange),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/padhoai/timer');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: padhoColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Iconsax.timer_1, color: Colors.white),
                label: const Text('Start Studying', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard(ThemeData theme, String title, String score, String date, Color scoreColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.onBackground.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(date, style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6))),
            ],
          ),
          Text(score, style: TextStyle(fontWeight: FontWeight.bold, color: scoreColor, fontSize: 16)),
        ],
      ),
    );
  }
}
