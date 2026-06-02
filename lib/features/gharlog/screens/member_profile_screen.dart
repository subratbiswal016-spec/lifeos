import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/gharlog_provider.dart';
import '../providers/medicine_provider.dart';
import '../../home/providers/dashboard_provider.dart'; // Added
import '../../../core/network/dio_client.dart'; // Added
import '../../../core/constants/api_endpoints.dart'; // Added
import '../../../core/theme/app_localizations.dart';
import 'add_member_screen.dart';

class MemberProfileScreen extends ConsumerWidget {
  final String memberId;

  const MemberProfileScreen({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final loc = ref.watch(localizationsProvider);
    
    final membersAsync = ref.watch(gharLogMembersProvider);
    final symptomsAsync = ref.watch(symptomsProvider(memberId));
    final medicinesAsync = ref.watch(medicineProvider(memberId));
    
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
        actions: [
          if (member != null)
            IconButton(
              icon: const Icon(Iconsax.edit),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AddMemberScreen(existingMember: member)));
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(symptomsProvider(memberId).notifier).fetchSymptoms();
          await ref.read(medicineProvider(memberId).notifier).fetchMedicines();
          await ref.read(gharLogMembersProvider.notifier).fetchMembers();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Builder(
                builder: (context) {
                  Uint8List? photoBytes;
                  if (member?.photoUrl != null && member!.photoUrl!.startsWith('data:image')) {
                    try {
                      final b64 = member.photoUrl!.split(',').last;
                      photoBytes = base64Decode(b64);
                    } catch (e) {
                      debugPrint('Error decoding base64 image: $e');
                    }
                  }

                  return Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      image: photoBytes != null
                          ? DecorationImage(image: MemoryImage(photoBytes), fit: BoxFit.cover)
                          : null,
                    ),
                    child: photoBytes == null
                        ? Icon(Iconsax.user, size: 40, color: theme.colorScheme.primary)
                        : null,
                  );
                }
              ),
            ),
            const SizedBox(height: 16),
            Text('Age: ${member?.age ?? 'Unknown'} | Relation: ${loc.translate(member?.relation ?? 'Unknown')}', style: TextStyle(fontSize: 16, color: theme.colorScheme.onBackground.withOpacity(0.7))),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Current Medications', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => context.push('/add_medicine?memberId=$memberId'),
                  icon: const Icon(Icons.add_circle_outline),
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            medicinesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (medicines) {
                if (medicines.isEmpty) {
                  return const Text('No medications recorded.');
                }
                return Column(
                  children: medicines.map((med) {
                    final durationText = med.durationDays != null && med.durationDays! > 0 
                        ? ' for ${med.durationDays} days' 
                        : '';
                    return InkWell(
                      onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Medicine'),
                          content: Text('Are you sure you want to delete "${med.name}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () async {
                                Navigator.pop(context);
                                try {
                                  await ref.read(medicineProvider(memberId).notifier).deleteMedicine(med.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Medicine deleted')));
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                  }
                                }
                              },
                              child: const Text('Delete', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.1),
                            theme.colorScheme.surface,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Iconsax.health, color: theme.colorScheme.primary, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(med.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(Iconsax.edit, color: theme.colorScheme.primary, size: 18),
                                      onPressed: () {
                                        context.push('/add_medicine?memberId=$memberId', extra: med);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('${med.dose ?? ''} • ${med.timesPerDay ?? 1}x Daily$durationText', style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.7), fontSize: 13)),
                                if (med.reminderTimes != null && med.reminderTimes!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: med.reminderTimes!.map((time) {
                                      final isTaken = med.takenTimes?.contains(time) ?? false;
                                      return InkWell(
                                        onTap: isTaken ? null : () async {
                                          try {
                                            final dioClient = ref.read(dioClientProvider);
                                            final now = DateTime.now();
                                            final todayDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                                            await dioClient.dio.post(
                                              '${ApiEndpoints.baseUrl}${ApiEndpoints.toggleMedicine(med.id)}',
                                              data: {
                                                'date': todayDate,
                                                'scheduledTime': time,
                                                'status': 'taken',
                                                'takenAt': now.toIso8601String(),
                                              },
                                            );
                                            ref.invalidate(medicineProvider(memberId));
                                            ref.invalidate(dashboardProvider);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as taken!')));
                                            }
                                          } catch (e) {
                                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error marking as taken')));
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isTaken ? Colors.grey : theme.colorScheme.primary,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(isTaken ? Icons.check : Iconsax.clock, size: 12, color: Colors.white),
                                              const SizedBox(width: 4),
                                              Text(time, style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold, decoration: isTaken ? TextDecoration.lineThrough : null)),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                );
              },
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Symptoms & Vitals', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => context.push('/gharlog/symptoms?memberId=$memberId'),
                  icon: const Icon(Icons.add_circle_outline),
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
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

  Widget _buildInfoCard(ThemeData theme, String title, String subtitle, IconData icon, Color color, {VoidCallback? onLongPress}) {
    return InkWell(
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
    ),
    );
  }
}
