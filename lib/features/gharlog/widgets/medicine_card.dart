import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class MedicineCard extends StatelessWidget {
  final String name;
  final String time;
  final String status; // 'taken', 'skipped', 'pending'

  const MedicineCard({
    super.key,
    required this.name,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color getStatusColor() {
      switch (status) {
        case 'taken': return const Color(0xFF4CAF50);
        case 'skipped': return const Color(0xFFF44336);
        case 'pending': return const Color(0xFFFFC107);
        default: return Colors.grey;
      }
    }

    final color = getStatusColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.health, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(time, style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6))),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: status == 'taken' ? color : Colors.grey.withOpacity(0.3)),
        ],
      ),
    );
  }
}
