import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/widgets/glass_container.dart';

class DailyTipCard extends StatelessWidget {
  final ThemeData theme;
  final String tip;

  const DailyTipCard({
    super.key, 
    required this.theme,
    required this.tip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: const Color(0xFF6C63FF).withOpacity(0.15),
      border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.4), width: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.magic_star, color: Color(0xFF8C85FF), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Daily Tip',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '"$tip"',
            style: TextStyle(
              color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87.withOpacity(0.9),
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
