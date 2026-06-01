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
              const SizedBox(height: 12),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.0),
                      theme.colorScheme.primary.withOpacity(0.35),
                      theme.colorScheme.primary.withOpacity(0.0),
                    ],
                  ),
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
              const SizedBox(height: 16),

              // Expense Tracker Banner
              FadeInDown(
                delay: const Duration(milliseconds: 125),
                child: InkWell(
                  onTap: () => context.push('/expenses'),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF38B2AC), const Color(0xFF4FD1C5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF38B2AC).withOpacity(0.3),
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
                          child: const Icon(Iconsax.wallet_3, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Wallet & Expenses',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Track your spending & budget',
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
              const SizedBox(height: 16),

              // Udhar Manager Banner
              FadeInDown(
                delay: const Duration(milliseconds: 150),
                child: InkWell(
                  onTap: () => context.push('/udhar'),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFFE5B300), const Color(0xFFF4D03F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE5B300).withOpacity(0.3),
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
                          child: const Icon(Iconsax.wallet_money, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Udhar Manager',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Manage debts Given & Taken',
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
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.push('/add_habit'),
                          icon: const Icon(Icons.add_circle_outline),
                          color: theme.colorScheme.primary,
                        ),
                        TextButton(
                          onPressed: () {
                            context.push('/manage_habits');
                          },
                          child: const Text('Manage'),
                        ),
                      ],
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.note_add, size: 64, color: theme.colorScheme.onBackground.withOpacity(0.2)),
                            const SizedBox(height: 16),
                            Text(
                              'No habits found.',
                              style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6), fontSize: 16),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => context.push('/add_habit'),
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text('Create your first Habit', style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ],
                        ),
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
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Habit'),
                                content: Text('Are you sure you want to delete "${habit.name}"?'),
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
                                        await ref.read(habitsProvider.notifier).deleteHabit(habit.id);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Habit deleted')));
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
