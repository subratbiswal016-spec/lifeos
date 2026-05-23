import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/habit_card.dart';
import '../providers/habit_provider.dart';

class ManageHabitsScreen extends ConsumerWidget {
  const ManageHabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final habitsAsyncValue = ref.watch(habitsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Manage Habits', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            habitsAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (habits) {
                if (habits.isEmpty) {
                  return const Center(child: Text('No habits found.'));
                }
                return Column(
                  children: habits.map((habit) => HabitCard(
                    title: habit.name,
                    subtitle: habit.frequency,
                    progress: 'Active',
                    isCompleted: habit.isCompletedToday,
                    onTap: () {
                      ref.read(habitsProvider.notifier).toggleHabitCompletion(habit.id);
                    },
                  )).toList(),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/add_habit');
        },
        backgroundColor: theme.colorScheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Habit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
