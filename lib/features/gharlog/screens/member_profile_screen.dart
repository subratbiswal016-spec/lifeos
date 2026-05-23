import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/gharlog_provider.dart';

class MemberProfileScreen extends ConsumerWidget {
  final String memberId;

  const MemberProfileScreen({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    final membersAsync = ref.watch(gharLogMembersProvider);
    final symptomsAsync = ref.watch(symptomsProvider(memberId));
    
    // Find member
    final member = membersAsync.value?.firstWhere((m) => m.id == memberId);
    final displayName = member?.name ?? 'Loading...';

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text('$displayName\'s Health Profile', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(symptomsProvider(memberId).notifier).fetchSymptoms();
          // Optionally, invalidate members provider to refresh the member's details too
          await ref.read(gharLogMembersProvider.notifier).fetchMembers();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.1),
                ),
                child: Icon(Iconsax.user, size: 40, color: theme.colorScheme.primary),
              ),
            ),
            const SizedBox(height: 32),
            Text('Current Medications', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildInfoCard(theme, 'Dolo 650', '2x Daily - After Meals', Iconsax.health, Colors.red),
            _buildInfoCard(theme, 'Amlodipine 5mg', '1x Daily - Morning', Iconsax.health, Colors.blue),
            const SizedBox(height: 32),
            Text('Recent Symptoms & Vitals', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            symptomsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (symptoms) {
                if (symptoms.isEmpty) {
                  return const Text('No recent logs found.');
                }
                final recent = symptoms.first;
                return Column(
                  children: [
                    if (recent.bpSystolic != null && recent.bpDiastolic != null)
                      _buildInfoCard(theme, 'Blood Pressure', '${recent.bpSystolic}/${recent.bpDiastolic} mmHg', Iconsax.activity, Colors.green),
                    if (recent.temperature != null)
                      _buildInfoCard(theme, 'Temperature', '${recent.temperature} °F', Iconsax.mask, Colors.red),
                    if (recent.bloodSugar != null)
                      _buildInfoCard(theme, 'Blood Sugar', '${recent.bloodSugar} mg/dL', Iconsax.health, Colors.orange),
                    if (recent.notes != null && recent.notes!.isNotEmpty)
                      _buildInfoCard(theme, 'Notes', recent.notes!, Iconsax.note, Colors.blue),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.onBackground.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
