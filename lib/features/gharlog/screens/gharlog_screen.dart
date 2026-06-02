import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/member_card.dart';
import '../providers/gharlog_provider.dart';
import '../../../core/theme/app_localizations.dart';
import '../models/family_member_model.dart';
import '../screens/add_member_screen.dart';

class GharLogScreen extends ConsumerWidget {
  const GharLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final membersAsync = ref.watch(gharLogMembersProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Ghar Ki Sehat', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.colorScheme.primary.withOpacity(0.15),
            height: 1.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.notification),
            onPressed: () {},
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(gharLogMembersProvider.notifier).fetchMembers();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 100.0), // Added bottom padding to clear the FAB
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInUp(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Family Members',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMemberScreen()));
                    },
                    icon: const Icon(Iconsax.add),
                    label: const Text('Add Member'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            membersAsync.when(
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              )),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Iconsax.warning_2, size: 48, color: theme.colorScheme.error),
                      const SizedBox(height: 16),
                      Text('Failed to load family members.\nPlease check your connection or backend.', 
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.colorScheme.error)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => ref.read(gharLogMembersProvider.notifier).fetchMembers(),
                        icon: const Icon(Iconsax.refresh),
                        label: const Text('Retry'),
                      )
                    ],
                  ),
                ),
              ),
              data: (members) {
                if (members.isEmpty) {
                  return const Center(child: Text('No family members yet. Add one!'));
                }
                return Column(
                  children: members.asMap().entries.map((entry) {
                    final index = entry.key;
                    final member = entry.value;
                    return FadeInUp(
                      delay: Duration(milliseconds: 200 + (index * 100)),
                      child: MemberCard(
                        name: member.name,
                        relation: ref.watch(localizationsProvider).translate(member.relation),
                        age: member.age?.toString() ?? 'N/A',
                        photoUrl: member.photoUrl,
                        onTap: () {
                          // Pass ID instead of name eventually, but keeping route simple for now
                          context.push('/member_profile/${member.id}');
                        },
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Member'),
                              content: Text('Are you sure you want to delete ${member.name}? This will also delete their medicines, visits, and symptoms.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  onPressed: () async {
                                    Navigator.pop(context); // close dialog
                                    try {
                                      await ref.read(gharLogMembersProvider.notifier).deleteMember(member.id);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member deleted')));
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
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 32),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: Text(
                'Quick Actions',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionCard(context, 'Medicines', Iconsax.health, const Color(0xFFF44336)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionCard(context, 'Doctor Visits', Iconsax.hospital, const Color(0xFF03A9F4)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionCard(context, 'Symptoms', Iconsax.activity, const Color(0xFFFF9800)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        if (title == 'Medicines') {
          context.push('/add_medicine');
        } else if (title == 'Doctor Visits') {
          context.push('/gharlog/doctor_visits');
        } else if (title == 'Symptoms') {
          context.push('/gharlog/symptoms');
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
