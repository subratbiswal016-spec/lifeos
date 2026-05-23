import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class PremiumGate extends StatelessWidget {
  final Widget child;
  final bool isPremiumUser;

  const PremiumGate({
    super.key,
    required this.child,
    required this.isPremiumUser,
  });

  @override
  Widget build(BuildContext context) {
    if (isPremiumUser) {
      return child;
    }

    final theme = Theme.of(context);
    
    return Stack(
      children: [
        // The blurred/disabled background child
        Opacity(
          opacity: 0.3,
          child: IgnorePointer(
            child: child,
          ),
        ),
        // The Premium Overlay
        Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Iconsax.crown, color: Color(0xFFFFD700), size: 60),
                const SizedBox(height: 16),
                Text(
                  'Premium Feature',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Unlock this feature with LifeOS Premium.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    context.push('/premium');
                  },
                  child: const Text('Upgrade Now', style: TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
