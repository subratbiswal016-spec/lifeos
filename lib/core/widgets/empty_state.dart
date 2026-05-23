import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String lottieAsset;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.lottieAsset = 'assets/lottie/empty.json',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Using an icon as fallback if Lottie asset doesn't exist yet
            Icon(Icons.inbox, size: 100, color: theme.colorScheme.primary.withOpacity(0.5)),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
