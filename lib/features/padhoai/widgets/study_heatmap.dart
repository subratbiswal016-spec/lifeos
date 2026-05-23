import 'package:flutter/material.dart';

class StudyHeatmap extends StatelessWidget {
  const StudyHeatmap({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text('GitHub-style Heatmap Coming Soon', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}
