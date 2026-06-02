import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/doctor_visit_provider.dart';

class DoctorVisitsScreen extends ConsumerWidget {
  const DoctorVisitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final visitsAsync = ref.watch(doctorVisitsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Doctor Visits', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(doctorVisitsProvider.notifier).fetchVisits(),
        child: visitsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (visits) {
            if (visits.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 100),
                  Center(child: Text('No doctor visits logged yet.')),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(24.0),
              itemCount: visits.length,
              itemBuilder: (context, index) {
                final visit = visits[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildVisitCard(
                    theme,
                    visit.doctorName,
                    visit.date,
                    visit.member?.name ?? 'Unknown',
                    true, // You could parse date to check if it's upcoming
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add_doctor_visit'),
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
