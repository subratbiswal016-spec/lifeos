import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../providers/subject_provider.dart';
import '../models/subject_model.dart';

class PadhoAIScreen extends ConsumerStatefulWidget {
  const PadhoAIScreen({super.key});

  @override
  ConsumerState<PadhoAIScreen> createState() => _PadhoAIScreenState();
}

class _PadhoAIScreenState extends ConsumerState<PadhoAIScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(subjectProvider.notifier).fetchSubjects());
  }

  void _showAddSubjectDialog(BuildContext context, ThemeData theme) {
    final formKey = GlobalKey<FormState>();
    String name = '';
    int weeklyTargetHours = 10;
    int dailyTargetHours = 2;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Subject', style: TextStyle(color: theme.colorScheme.onBackground, fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.surface,
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Subject Name',
                  prefixIcon: Icon(Iconsax.book),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                onSaved: (value) => name = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Weekly Target (Hours)',
                  prefixIcon: Icon(Iconsax.timer),
                ),
                keyboardType: TextInputType.number,
                initialValue: '10',
                validator: (value) => value == null || int.tryParse(value) == null ? 'Enter valid number' : null,
                onSaved: (value) => weeklyTargetHours = int.parse(value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Daily Target (Hours)',
                  prefixIcon: Icon(Iconsax.clock),
                ),
                keyboardType: TextInputType.number,
                initialValue: '2',
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
                
                final success = await ref.read(subjectProvider.notifier).addSubject({
                  'name': name,
                  'weeklyTargetHours': weeklyTargetHours,
                  'dailyTargetHours': dailyTargetHours,
                  'emoji': '📚',
                  'color': '#6C63FF',
                });
                
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Subject added successfully!')),
                  );
                }
              }
            },
            child: const Text('Add Subject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color padhoColor = const Color(0xFF6C63FF); // PadhoAI Purple
    final subjectState = ref.watch(subjectProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Padho AI', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.colorScheme.primary.withOpacity(0.15),
            height: 1.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.chart),
            onPressed: () => context.push('/padhoai/stats'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 100.0), // Padding for FAB
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [padhoColor, padhoColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: padhoColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ready to focus?',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                          child: const Icon(Iconsax.timer_1, color: Colors.white),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Start a Pomodoro session or take a mock test.',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: padhoColor,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        context.push('/padhoai/timer');
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Study Session', style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Your Subjects', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () => _showAddSubjectDialog(context, theme),
                    icon: const Icon(Iconsax.add),
                    label: const Text('Add'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: subjectState.isLoading 
                ? const Center(child: CircularProgressIndicator())
                : subjectState.subjects.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(Iconsax.book_1, size: 48, color: theme.colorScheme.onBackground.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            Text('No subjects added yet.', style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.5))),
                          ],
                        ),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: subjectState.subjects.length,
                      itemBuilder: (context, index) {
                        final subject = subjectState.subjects[index];
                        // Convert string color '#6C63FF' to Color
                        Color color = padhoColor;
                        try {
                          if (subject.color.startsWith('#')) {
                            color = Color(int.parse(subject.color.substring(1, 7), radix: 16) + 0xFF000000);
                          }
                        } catch (e) {
                          // Ignore parsing error, fallback to default padhoColor
                        }
                        
                        return _buildSubjectCard(
                          context, 
                          subject, 
                          '${subject.weeklyTargetHours}h Target', 
                          Iconsax.book, 
                          color,
                          ref
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, dynamic subject, String subtitle, IconData icon, Color color, WidgetRef ref) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        context.push('/padhoai/subject/${subject.name}');
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Subject'),
            content: Text('Are you sure you want to delete "${subject.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await ref.read(subjectProvider.notifier).deleteSubject(subject.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subject deleted')));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                child: const Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const Spacer(),
            Text(subject.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }
}
