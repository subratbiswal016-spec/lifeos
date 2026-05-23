import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/gharlog_provider.dart';
import '../models/symptom_log_model.dart';

class SymptomsLoggerScreen extends ConsumerStatefulWidget {
  const SymptomsLoggerScreen({super.key});

  @override
  ConsumerState<SymptomsLoggerScreen> createState() => _SymptomsLoggerScreenState();
}

class _SymptomsLoggerScreenState extends ConsumerState<SymptomsLoggerScreen> {
  String? _selectedMemberId;
  final _tempController = TextEditingController();
  final _bpSysController = TextEditingController();
  final _bpDiaController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _tempController.dispose();
    _bpSysController.dispose();
    _bpDiaController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveLog() async {
    if (_selectedMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a family member')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final log = SymptomLogModel(
        id: '',
        memberId: _selectedMemberId!,
        date: DateTime.now().toIso8601String(),
        temperature: double.tryParse(_tempController.text),
        bpSystolic: int.tryParse(_bpSysController.text),
        bpDiastolic: int.tryParse(_bpDiaController.text),
        notes: _notesController.text,
      );

      await ref.read(symptomsProvider(_selectedMemberId!).notifier).addSymptom(log);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vitals Logged!')));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final membersAsync = ref.watch(gharLogMembersProvider);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Log Symptoms', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Who is feeling unwell?', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            membersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Error loading members: $e'),
              data: (members) {
                if (members.isEmpty) return const Text('Please add a family member first.');
                
                // Set default selection
                if (_selectedMemberId == null && members.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() => _selectedMemberId = members.first.id);
                  });
                }

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: members.map((m) {
                    final isSelected = _selectedMemberId == m.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMemberId = m.id),
                      child: _buildSelectBox(theme, m.name, isSelected),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 32),
            Text('Vitals', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField(theme, 'Temp (°F)', _tempController, TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(theme, 'BP Sys', _bpSysController, TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(theme, 'BP Dia', _bpDiaController, TextInputType.number)),
              ],
            ),
            const SizedBox(height: 32),
            Text('Notes', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTextField(theme, 'How are they feeling? (e.g., Headache, Cough)', _notesController, TextInputType.text, maxLines: 3),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveLog,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Log', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectBox(ThemeData theme, String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onBackground.withOpacity(0.1)),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onBackground),
        ),
      ),
    );
  }

  Widget _buildTextField(ThemeData theme, String label, TextEditingController controller, TextInputType type, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}
