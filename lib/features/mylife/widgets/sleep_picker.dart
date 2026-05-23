import 'package:flutter/material.dart';

class SleepPicker extends StatelessWidget {
  final double sleepHours;
  final ValueChanged<double> onChanged;

  const SleepPicker({
    super.key,
    required this.sleepHours,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, size: 32),
          onPressed: () {
            if (sleepHours > 0) onChanged(sleepHours - 0.5);
          },
        ),
        const SizedBox(width: 24),
        Column(
          children: [
            Text(
              '${sleepHours.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const Text('Hours', style: TextStyle(color: Colors.grey)),
          ],
        ),
        const SizedBox(width: 24),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 32),
          onPressed: () {
            if (sleepHours < 24) onChanged(sleepHours + 0.5);
          },
        ),
      ],
    );
  }
}
