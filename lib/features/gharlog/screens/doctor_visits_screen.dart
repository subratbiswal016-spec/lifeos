import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class DoctorVisitsScreen extends StatelessWidget {
  const DoctorVisitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Doctor Visits', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildVisitCard(theme, 'Dr. Sharma (Cardiologist)', 'Oct 15, 2023 - 10:00 AM', 'Papa', true),
          const SizedBox(height: 16),
          _buildVisitCard(theme, 'Dr. Gupta (General)', 'Nov 02, 2023 - 04:30 PM', 'Maa', false),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: theme.colorScheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Book Appointment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildVisitCard(ThemeData theme, String doctor, String datetime, String patient, bool isUpcoming) {
    final color = isUpcoming ? theme.colorScheme.primary : Colors.grey;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Iconsax.hospital, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(datetime, style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6), fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onBackground.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Patient: $patient', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
