import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class DailyTipCard extends StatelessWidget {
  final ThemeData theme;

  const DailyTipCard({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.magic_star, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI Daily Tip',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '"Focus on drinking 3L of water today, it will help you stay energized during your UPSC prep!"',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
