import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/medicine_model.dart';
import '../models/family_member_model.dart';
import '../providers/medicine_provider.dart';
import '../providers/gharlog_provider.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_localizations.dart';

class AddMedicineScreen extends ConsumerStatefulWidget {
  final String? memberId;
  final MedicineModel? existingMedicine;
  const AddMedicineScreen({super.key, this.memberId, this.existingMedicine});

  @override
  ConsumerState<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends ConsumerState<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  final _durationController = TextEditingController();
  int _timesPerDay = 1;
  final List<TextEditingController> _timeControllers = [TextEditingController()];
  bool _isLoading = false;

  // Used when no memberId is pre-supplied (e.g. from dashboard FAB)
  FamilyMemberModel? _selectedMember;

  @override
  void initState() {
    super.initState();
    if (widget.existingMedicine != null) {
      final med = widget.existingMedicine!;
      _nameController.text = med.name;
      _doseController.text = med.dose ?? '';
      _durationController.text = med.durationDays?.toString() ?? '';
      _timesPerDay = med.timesPerDay ?? 1;
      
      _timeControllers.clear();
      if (med.reminderTimes != null && med.reminderTimes!.isNotEmpty) {
        for (final time in med.reminderTimes!) {
          _timeControllers.add(TextEditingController(text: time));
        }
      }
      while (_timeControllers.length < _timesPerDay) {
        _timeControllers.add(TextEditingController());
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _durationController.dispose();
    for (var c in _timeControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveMedicine() async {
    // Resolve the effective memberId
    final effectiveMemberId = widget.memberId ?? _selectedMember?.id;

    if (effectiveMemberId == null || effectiveMemberId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a family member first.')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final reminderTimes = _timeControllers.map((c) => c.text.trim()).toList();
      final durationDays = int.tryParse(_durationController.text.trim()) ?? 0;
      
      final newMedicine = MedicineModel(
        id: widget.existingMedicine?.id ?? '',
        memberId: effectiveMemberId,
        name: _nameController.text.trim(),
        dose: _doseController.text.trim(),
        timesPerDay: _timesPerDay,
        durationDays: durationDays,
        reminderTimes: reminderTimes,
      );

      if (widget.existingMedicine != null) {
        await ref.read(medicineProvider(effectiveMemberId).notifier).updateMedicine(widget.existingMedicine!.id, newMedicine);
      } else {
        await ref.read(medicineProvider(effectiveMemberId).notifier).addMedicine(newMedicine);
      }

      // Schedule local notifications for each reminder time
      int i = 0;
      for (final timeStr in reminderTimes) {
        try {
          // Expected format: "12:50 PM" or "14:30"
          final parts = timeStr.split(' ');
          final timeParts = parts[0].split(':');
          int hour = int.parse(timeParts[0]);
          final int minute = int.parse(timeParts[1]);
          if (parts.length > 1) {
            final period = parts[1].toUpperCase();
            if (period == 'PM' && hour != 12) hour += 12;
            if (period == 'AM' && hour == 12) hour = 0;
          }

          // Use a unique ID based on time hash to avoid colliding
          final id = newMedicine.name.hashCode + i++;
          await NotificationService().scheduleMedicineReminder(
            id: id.abs() % 100000, // limit to max int size for android
            title: 'Medicine Time! 💊',
            body: 'It is time for ${newMedicine.name} (${newMedicine.dose ?? "1 dose"}).',
            hour: hour,
            minute: minute,
          );
        } catch (e) {
          debugPrint('Error scheduling notification: $e');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.existingMedicine != null ? 'Medicine updated successfully!' : 'Medicine added successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = ref.watch(localizationsProvider);

    // Only show the member picker if no memberId was passed in via route
    final showMemberPicker = widget.memberId == null;
    final membersAsync = showMemberPicker ? ref.watch(gharLogMembersProvider) : null;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(widget.existingMedicine != null ? 'Edit Medicine' : 'Add Medicine', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Family member picker (only when no memberId passed) ===
              if (showMemberPicker) ...[
                Text('For whom?',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (membersAsync == null)
                  const SizedBox.shrink()
                else
                  membersAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Could not load members: $e',
                        style: const TextStyle(color: Colors.red)),
                    data: (members) {
                      if (members.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'No family members found. Please add a member in GharLog first.',
                            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                          ),
                        );
                      }
                      return DropdownButtonFormField<FamilyMemberModel>(
                        value: _selectedMember,
                        hint: const Text('Select a member'),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        items: members.map((m) {
                          return DropdownMenuItem(
                            value: m,
                            child: Text('${m.name} (${loc.translate(m.relation)})'),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedMember = val),
                        validator: (_) =>
                            _selectedMember == null ? 'Please select a family member' : null,
                      );
                    },
                  ),
                const SizedBox(height: 24),
              ],

              // === Medicine Details ===
              Text('Medicine Details',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTextField(theme, 'Medicine Name', 'e.g. Dolo 650', _nameController, maxLength: 50),
              const SizedBox(height: 16),
              _buildTextField(theme, 'Dosage', 'e.g. 1 pill', _doseController, maxLength: 50),
              const SizedBox(height: 16),
              _buildTextField(theme, 'Duration (in days)', 'e.g. 5', _durationController, 
                maxLength: 3, 
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (int.tryParse(val) == null) return 'Must be a number';
                  return null;
                }
              ),
              const SizedBox(height: 32),
              Text('Schedule',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _timesPerDay,
                decoration: InputDecoration(
                  labelText: 'Doses per day',
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                items: [1, 2, 3, 4].map((n) => DropdownMenuItem(value: n, child: Text('$n times a day'))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _timesPerDay = val;
                      if (_timeControllers.length < val) {
                        while (_timeControllers.length < val) {
                          _timeControllers.add(TextEditingController());
                        }
                      } else if (_timeControllers.length > val) {
                        while (_timeControllers.length > val) {
                          final c = _timeControllers.removeLast();
                          c.dispose();
                        }
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              ...List.generate(_timesPerDay, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildTextField(theme, 'Time for Dose ${index + 1}', 'Select Time', _timeControllers[index],
                      icon: Icons.access_time, 
                      readOnly: true,
                      onTap: () async {
                        final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if (time != null && mounted) {
                          final isAmPm = time.periodOffset == 0;
                          final period = time.period == DayPeriod.am ? 'AM' : 'PM';
                          final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
                          final min = time.minute.toString().padLeft(2, '0');
                          _timeControllers[index].text = '$hour:$min $period';
                        }
                      },
                      validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    return null;
                  }),
                );
              }),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveMedicine,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.existingMedicine != null ? 'Update Medicine' : 'Save Medicine',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      ThemeData theme, String label, String hint, TextEditingController controller,
      {IconData? icon, int? maxLength, String? Function(String?)? validator, bool readOnly = false, VoidCallback? onTap, TextInputType? keyboardType}) {
    return AppTextField(
      label: label,
      hint: hint,
      controller: controller,
      prefixIcon: icon,
      maxLength: maxLength,
      keyboardType: keyboardType ?? TextInputType.text,
      validator: validator ?? (val) => val == null || val.isEmpty ? 'Required' : null,
      readOnly: readOnly,
      onTap: onTap,
    );
  }
}
