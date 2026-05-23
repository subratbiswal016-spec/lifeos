import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../widgets/habit_card.dart';
import 'checkin_screen.dart';

class MyLifeScreen extends StatelessWidget {
  const MyLifeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('My Life', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              // Navigate to Life Stats Screen
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF6B35), // Saffron Orange
                      const Color(0xFFFF6B35).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFFF6B35).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                  ]
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Daily Check-in', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text('Have you logged your mood today?', style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFFF6B35)),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const CheckInScreen(),
                        );
                      },
                      child: const Text('Check In'),
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
                  Text(
                    'Today\'s Habits',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Manage'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: HabitCard(
                title: 'Morning Yoga',
                emoji: '🧘🏽‍♀️',
                streak: '12',
                isCompleted: true,
                color: const Color(0xFF4CAF50),
                onComplete: () {},
              ),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: HabitCard(
                title: 'Read 10 Pages',
                emoji: '📚',
                streak: '5',
                isCompleted: false,
                color: const Color(0xFF6C63FF),
                onComplete: () {},
              ),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: HabitCard(
                title: 'Drink 2L Water',
                emoji: '💧',
                streak: '1',
                isCompleted: false,
                color: const Color(0xFF03A9F4),
                onComplete: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
