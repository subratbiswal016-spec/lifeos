import 'package:flutter/material.dart';

class ScoreChart extends StatelessWidget {
  const ScoreChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text('Mock Test Score Chart Coming Soon', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}
