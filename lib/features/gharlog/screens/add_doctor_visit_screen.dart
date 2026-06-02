import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/doctor_visit_model.dart';
import '../models/family_member_model.dart';
import '../providers/doctor_visit_provider.dart';
import '../providers/gharlog_provider.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/theme/app_localizations.dart';

class AddDoctorVisitScreen extends ConsumerStatefulWidget {
  const AddDoctorVisitScreen({super.key});

  @override
  ConsumerState<AddDoctorVisitScreen> createState() => _AddDoctorVisitScreenState();
}

class _AddDoctorVisitScreenState extends ConsumerState<AddDoctorVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _doctorController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  
  FamilyMemberModel? _selectedMember;
  bool _isLoading = false;

  @override
  void dispose() {
    _doctorController.dispose();
    _hospitalController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null && mounted) {
        setState(() {
          _selectedDate = date;
          _selectedTime = time;
        });
      }
    }
  }

  Future<void> _saveVisit() async {
    if (_selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a family member')));
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select date and time')));
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final isAmPm = _selectedTime!.periodOffset == 0;
      final period = _selectedTime!.period == DayPeriod.am ? 'AM' : 'PM';
      final hour = _selectedTime!.hourOfPeriod == 0 ? 12 : _selectedTime!.hourOfPeriod;
      final min = _selectedTime!.minute.toString().padLeft(2, '0');
      
      final month = _selectedDate!.month.toString().padLeft(2, '0');
      final day = _selectedDate!.day.toString().padLeft(2, '0');
      final year = _selectedDate!.year.toString();
      
      // E.g. "Oct 15, 2023 - 10:00 AM" format approximation, or standard ISO. We will store a string that can be displayed easily.
      final dateString = '${_selectedDate!.year}-$month-$day $hour:$min $period';

      final newVisit = DoctorVisitModel(
        id: '',
        memberId: _selectedMember!.id,
        date: dateString,
        doctorName: _doctorController.text.trim(),
        hospital: _hospitalController.text.trim(),
        reason: _reasonController.text.trim(),
        notes: _notesController.text.trim(),
      );

      await ref.read(doctorVisitsProvider.notifier).addVisit(newVisit);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Doctor visit logged successfully!')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = ref.watch(localizationsProvider);
    final membersAsync = ref.watch(gharLogMembersProvider);

    String dateTimeLabel = 'Select Date & Time';
    if (_selectedDate != null && _selectedTime != null) {
      final period = _selectedTime!.period == DayPeriod.am ? 'AM' : 'PM';
      final hour = _selectedTime!.hourOfPeriod == 0 ? 12 : _selectedTime!.hourOfPeriod;
      final min = _selectedTime!.minute.toString().padLeft(2, '0');
      dateTimeLabel = '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} - $hour:$min $period';
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Book / Log Visit', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Patient', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              membersAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
                data: (members) {
                  return DropdownButtonFormField<FamilyMemberModel>(
                    value: _selectedMember,
                    hint: const Text('Select a member'),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    items: members.map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text('${m.name} (${loc.translate(m.relation)})'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedMember = val),
                    validator: (_) => _selectedMember == null ? 'Required' : null,
                  );
                },
              ),
              const SizedBox(height: 24),
              Text('Appointment Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Doctor Name',
                hint: 'e.g. Dr. Sharma',
                controller: _doctorController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Hospital / Clinic',
                hint: 'e.g. Apollo Hospital',
                controller: _hospitalController,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Reason for Visit',
                hint: 'e.g. Routine Checkup, Fever',
                controller: _reasonController,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDateTime,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                      const SizedBox(width: 16),
                      Text(dateTimeLabel, style: TextStyle(fontSize: 16, color: _selectedDate == null ? Colors.grey : theme.colorScheme.onSurface)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Notes / Prescriptions',
                hint: 'Any specific instructions...',
                controller: _notesController,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveVisit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Visit', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
