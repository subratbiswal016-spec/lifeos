import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../widgets/habit_card.dart';
import '../providers/habit_provider.dart';

class MyLifeScreen extends ConsumerWidget {
  const MyLifeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final habitsAsyncValue = ref.watch(habitsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(habitsProvider.notifier).fetchHabits();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 48.0, bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: Text(
                  'My Life',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              
              // Daily Logs Banner
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                child: InkWell(
                  onTap: () => context.push('/life_stats'),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Iconsax.calendar_1, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Daily Logs',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'View your history & calendar',
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today\'s Habits',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push('/manage_habits');
                      },
                      child: const Text('Manage'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              habitsAsyncValue.when(
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator())),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text('Network Error. Pull to refresh.', style: TextStyle(color: theme.colorScheme.error)),
                  )
                ),
                data: (habits) {
                  if (habits.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text('No habits found. Click Manage to add one!', style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6))),
                      ),
                    );
                  }
                  return Column(
                    children: habits.asMap().entries.map((entry) {
                      final index = entry.key;
                      final habit = entry.value;
                      return FadeInUp(
                        delay: Duration(milliseconds: 200 + (index * 100)),
                        child: HabitCard(
                          title: habit.name,
                          subtitle: habit.frequency,
                          progress: habit.isCompletedToday ? 'Done' : 'Active',
                          isCompleted: habit.isCompletedToday,
                          onTap: () {
                            if (!habit.isCompletedToday) {
                              ref.read(habitsProvider.notifier).toggleHabitCompletion(habit.id);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
