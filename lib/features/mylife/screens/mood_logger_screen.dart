import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class MoodLoggerScreen extends StatefulWidget {
  const MoodLoggerScreen({super.key});

  @override
  State<MoodLoggerScreen> createState() => _MoodLoggerScreenState();
}

class _MoodLoggerScreenState extends State<MoodLoggerScreen> {
  int _selectedMoodIndex = 2; // Default to neutral

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😢', 'label': 'Sad', 'color': Colors.blue},
    {'emoji': '😕', 'label': 'Stressed', 'color': Colors.orange},
    {'emoji': '😐', 'label': 'Neutral', 'color': Colors.grey},
    {'emoji': '😊', 'label': 'Good', 'color': Colors.green},
    {'emoji': '😁', 'label': 'Awesome', 'color': Colors.purple},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Log Your Mood', style: TextStyle(fontWeight: FontWeight.bold)),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              'How are you feeling today?',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_moods.length, (index) {
                final isSelected = _selectedMoodIndex == index;
                final mood = _moods[index];
                return GestureDetector(
                  onTap: () => setState(() => _selectedMoodIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? mood['color'].withOpacity(0.2) : theme.colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? mood['color'] : theme.colorScheme.onBackground.withOpacity(0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      mood['emoji'],
                      style: TextStyle(fontSize: isSelected ? 40 : 28),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 48),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Add a Note (Optional)',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Why are you feeling this way?',
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mood logged!')));
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Log', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
