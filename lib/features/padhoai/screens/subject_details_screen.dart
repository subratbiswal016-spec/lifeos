import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subject_provider.dart';
import '../providers/study_provider.dart';
import '../models/subject_model.dart';

class SubjectDetailsScreen extends ConsumerStatefulWidget {
  final String subjectName;

  const SubjectDetailsScreen({super.key, this.subjectName = 'Subject Details'});

  @override
  ConsumerState<SubjectDetailsScreen> createState() => _SubjectDetailsScreenState();
}

class _SubjectDetailsScreenState extends ConsumerState<SubjectDetailsScreen> {
  void _showEditSubjectDialog(BuildContext context, ThemeData theme, SubjectModel subject) {
    final formKey = GlobalKey<FormState>();
    String name = subject.name;
    int weeklyTargetHours = subject.weeklyTargetHours;
    int dailyTargetHours = subject.dailyTargetHours;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Subject', style: TextStyle(color: theme.colorScheme.onBackground, fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.surface,
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(
                    labelText: 'Subject Name',
                    prefixIcon: Icon(Iconsax.book),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  onSaved: (value) => name = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: weeklyTargetHours.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Weekly Target (Hours)',
                    prefixIcon: Icon(Iconsax.timer),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || int.tryParse(value) == null ? 'Enter valid number' : null,
                  onSaved: (value) => weeklyTargetHours = int.parse(value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: dailyTargetHours.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Daily Target (Hours)',
                    prefixIcon: Icon(Iconsax.clock),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || int.tryParse(value) == null ? 'Enter valid number' : null,
                  onSaved: (value) => dailyTargetHours = int.parse(value!),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                Navigator.pop(context);
                
                final success = await ref.read(subjectProvider.notifier).updateSubject(subject.id, {
                  'name': name,
                  'weeklyTargetHours': weeklyTargetHours,
                  'dailyTargetHours': dailyTargetHours,
                });
                
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Subject updated successfully!')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color padhoColor = const Color(0xFF6C63FF);

    final subjectState = ref.watch(subjectProvider);
    final subject = subjectState.subjects.firstWhere(
      (s) => s.name == widget.subjectName,
      orElse: () => subjectState.subjects.first,
    );
    final todaySessionsAsync = ref.watch(todaySessionsProvider);
    
    int todayStudiedMinutes = 0;
    todaySessionsAsync.whenData((sessions) {
      for (var s in sessions) {
        if (s['subjectId'] != null && (s['subjectId']['_id'] == subject.id || s['subjectId'] == subject.id)) {
          todayStudiedMinutes += (s['durationMinutes'] as num? ?? 0).toInt();
        }
      }
    });

    final todayStudiedHours = (todayStudiedMinutes / 60).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(widget.subjectName, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.edit),
            onPressed: () => _showEditSubjectDialog(context, theme, subject),
          ),
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
                    Text(
                      todayStudiedMinutes > 0 
                        ? 'You have studied $todayStudiedHours h today!'
                        : 'You need to study ${subject.dailyTargetHours}h more today!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: todayStudiedMinutes >= (subject.dailyTargetHours * 60) ? Colors.green : Colors.orange,
                      ),
                    ),
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
                  context.push('/padhoai/timer', extra: subject.id);
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
