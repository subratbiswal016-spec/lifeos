import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/medicine_model.dart';
import '../models/family_member_model.dart';
import '../providers/medicine_provider.dart';
import '../providers/gharlog_provider.dart';
import '../../../core/widgets/app_text_field.dart';

class AddMedicineScreen extends ConsumerStatefulWidget {
  final String? memberId;
  const AddMedicineScreen({super.key, this.memberId});

  @override
  ConsumerState<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends ConsumerState<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  final _timeController = TextEditingController();
  bool _isLoading = false;

  // Used when no memberId is pre-supplied (e.g. from dashboard FAB)
  FamilyMemberModel? _selectedMember;

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _timeController.dispose();
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
      final newMedicine = MedicineModel(
        id: '',
        memberId: effectiveMemberId,
        name: _nameController.text.trim(),
        dose: _doseController.text.trim(),
        timesPerDay: 1,
        reminderTimes: [_timeController.text.trim()],
      );

      await ref.read(medicineProvider(effectiveMemberId).notifier).addMedicine(newMedicine);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medicine added successfully!')),
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

    // Only show the member picker if no memberId was passed in via route
    final showMemberPicker = widget.memberId == null;
    final membersAsync = showMemberPicker ? ref.watch(gharLogMembersProvider) : null;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Add Medicine', style: TextStyle(fontWeight: FontWeight.bold)),
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
                            child: Text('${m.name} (${m.relation})'),
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
              const SizedBox(height: 32),
              Text('Schedule',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTextField(theme, 'Time', 'e.g. 08:00 AM', _timeController,
                  icon: Icons.access_time, 
                  readOnly: true,
                  onTap: () async {
                    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (time != null && mounted) {
                      _timeController.text = time.format(context);
                    }
                  },
                  validator: (val) {
                if (val == null || val.isEmpty) return 'Required';
                final regex = RegExp(r'^(1[0-2]|0?[1-9]):[0-5][0-9]\s?(AM|PM|am|pm)$');
                if (!regex.hasMatch(val)) return 'Invalid time format (e.g. 08:00 AM)';
                return null;
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
                      : const Text('Save Medicine',
                          style: TextStyle(
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
      {IconData? icon, int? maxLength, String? Function(String?)? validator, bool readOnly = false, VoidCallback? onTap}) {
    return AppTextField(
      label: label,
      hint: hint,
      controller: controller,
      prefixIcon: icon,
      maxLength: maxLength,
      validator: validator ?? (val) => val == null || val.isEmpty ? 'Required' : null,
      readOnly: readOnly,
      onTap: onTap,
    );
  }
}
