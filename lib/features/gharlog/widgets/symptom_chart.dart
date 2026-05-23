import 'package:flutter/material.dart';

class SymptomChart extends StatelessWidget {
  const SymptomChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text('Symptom Chart Coming Soon', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}
