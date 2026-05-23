import 'package:flutter/material.dart';

class MoodChart extends StatelessWidget {
  const MoodChart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text('Fl_Chart Mood Implementation Coming Soon', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}
