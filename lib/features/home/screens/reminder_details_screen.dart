import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../providers/dashboard_provider.dart';

class ReminderDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> reminder;

  const ReminderDetailsScreen({super.key, required this.reminder});

  @override
  ConsumerState<ReminderDetailsScreen> createState() => _ReminderDetailsScreenState();
}

class _ReminderDetailsScreenState extends ConsumerState<ReminderDetailsScreen> {
  bool _isMarkingDone = false;
  bool _isDone = false;

  Future<void> _markAsDone() async {
    final id = widget.reminder['id'] as String?;
    if (id == null || id.isEmpty) {
      _showSnack('Cannot mark done: medicine ID not found.', isError: true);
      return;
    }

    setState(() => _isMarkingDone = true);
    try {
      final dioClient = ref.read(dioClientProvider);
      await dioClient.dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.toggleMedicine(id)}',
        data: {
          'takenAt': DateTime.now().toIso8601String(),
          'status': 'taken',
        },
      );
      setState(() => _isDone = true);
      // Refresh the dashboard so reminder count updates
      ref.invalidate(dashboardProvider);
      _showSnack('✅ Marked as taken! Great job staying on track.', isError: false);
    } catch (e) {
      _showSnack('Could not mark as done. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isMarkingDone = false);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: isError ? Colors.red.shade600 : Colors.teal.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
      ),
    );
  }

  void _openEditSheet() {
    final reminder = widget.reminder;
    final doseController = TextEditingController(text: reminder['dose'] ?? '');
    final timesController = TextEditingController(
      text: (reminder['reminderTimes'] as List?)?.join(', ') ?? '',
    );
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.4), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text('Edit Medicine', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                controller: doseController,
                decoration: InputDecoration(
                  labelText: 'Dose (e.g. 500mg)',
                  prefixIcon: const Icon(Iconsax.health),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: timesController,
                decoration: InputDecoration(
                  labelText: 'Reminder Times (comma separated, e.g. 08:00, 20:00)',
                  prefixIcon: const Icon(Iconsax.clock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  filled: true,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    final id = widget.reminder['id'] as String?;
                    if (id == null) return;
                    try {
                      final dioClient = ref.read(dioClientProvider);
                      final times = timesController.text
                          .split(',')
                          .map((t) => t.trim())
                          .where((t) => t.isNotEmpty)
                          .toList();
                      await dioClient.dio.put(
                        '${ApiEndpoints.baseUrl}/medicine/$id',
                        data: {
                          'dose': doseController.text,
                          'reminderTimes': times,
                        },
                      );
                      ref.invalidate(dashboardProvider);
                      if (ctx.mounted) Navigator.pop(ctx);
                      _showSnack('Medicine updated successfully!', isError: false);
                    } catch (e) {
                      _showSnack('Could not update. Try again.', isError: true);
                    }
                  },
                  child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reminder = widget.reminder;
    final title = reminder['title'] ?? 'Reminder';
    final memberName = reminder['memberName'] ?? 'Self';
    final dose = reminder['dose'] ?? '';
    final time = reminder['time'] ?? 'Upcoming';
    final reminderTimes = (reminder['reminderTimes'] as List?)?.cast<String>() ?? [];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Reminder Details', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.edit),
            tooltip: 'Edit Medicine',
            onPressed: _openEditSheet,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF44336).withOpacity(0.15),
                    const Color(0xFFF44336).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF44336).withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF44336).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.health, size: 48, color: Color(0xFFF44336)),
                  ),
                  const SizedBox(height: 16),
                  Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text('For: $memberName', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 14)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF44336).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Iconsax.clock, size: 16, color: Color(0xFFF44336)),
                        const SizedBox(width: 8),
                        Text(time, style: const TextStyle(color: Color(0xFFF44336), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Details
            if (dose.isNotEmpty) ...[
              _infoRow(theme, Iconsax.health, 'Dose', dose),
              const SizedBox(height: 12),
            ],
            if (reminderTimes.isNotEmpty)
              _infoRow(theme, Iconsax.clock, 'Reminder Times', reminderTimes.join(' • ')),

            const Spacer(),

            // Mark as Done button
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: _isDone || _isMarkingDone ? null : _markAsDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isDone ? Colors.grey : const Color(0xFF4CAF50),
                  disabledBackgroundColor: _isDone ? Colors.green.shade200 : Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: _isDone ? 0 : 6,
                  shadowColor: const Color(0xFF4CAF50).withOpacity(0.4),
                ),
                icon: _isMarkingDone
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Icon(_isDone ? Icons.check_circle : Icons.check, color: Colors.white),
                label: Text(
                  _isDone ? 'Already Taken ✓' : 'Mark as Taken',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => context.pop(),
                child: Text('Go Back', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(ThemeData theme, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.5))),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }
}
