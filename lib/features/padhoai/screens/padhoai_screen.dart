import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';

class PadhoAIScreen extends StatelessWidget {
  const PadhoAIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color padhoColor = const Color(0xFF6C63FF); // PadhoAI Purple

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Padho AI', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Iconsax.chart), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
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
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Add Subject'),
                          content: const Text('Subject form will appear here.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Iconsax.add),
                    label: const Text('Add'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  _buildSubjectCard(context, 'Mathematics', 'UPSC CSAT', Iconsax.math, const Color(0xFFE91E63)),
                  _buildSubjectCard(context, 'History', 'Modern India', Iconsax.book, const Color(0xFF9C27B0)),
                  _buildSubjectCard(context, 'Polity', 'Indian Const.', Iconsax.bank, const Color(0xFF3F51B5)),
                  _buildSubjectCard(context, 'Geography', 'World & India', Iconsax.global, const Color(0xFF009688)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        context.push('/padhoai/subject/$title');
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
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }
}
