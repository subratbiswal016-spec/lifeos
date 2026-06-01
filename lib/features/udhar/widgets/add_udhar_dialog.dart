import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/app_text_field.dart';
import '../providers/udhar_provider.dart';

class AddUdharDialog extends ConsumerStatefulWidget {
  const AddUdharDialog({super.key});

  @override
  ConsumerState<AddUdharDialog> createState() => _AddUdharDialogState();
}

class _AddUdharDialogState extends ConsumerState<AddUdharDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  String _type = 'gave';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(udharNotifierProvider.notifier).addUdhar({
        'personName': _nameController.text,
        'amount': int.parse(_amountController.text),
        'type': _type,
        'description': _descController.text,
        'date': _selectedDate.toIso8601String(),
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(udharNotifierProvider).isLoading;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Transaction',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Gave'),
                        value: 'gave',
                        groupValue: _type,
                        onChanged: (val) => setState(() => _type = val!),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Took'),
                        value: 'took',
                        groupValue: _type,
                        onChanged: (val) => setState(() => _type = val!),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Person Name',
                  hint: 'e.g. Ramesh',
                  controller: _nameController,
                  maxLength: 50,
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Amount (₹)',
                  hint: 'e.g. 500',
                  controller: _amountController,
                  maxLength: 7,
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    final b = int.tryParse(val);
                    if (b == null) return 'Invalid number';
                    if (b > 500000) return 'Maximum amount allowed is ₹5,00,000';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Date',
                  hint: 'Select Date',
                  controller: _dateController,
                  readOnly: true,
                  prefixIcon: Icons.calendar_today,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null && mounted) {
                      setState(() {
                        _selectedDate = date;
                        _dateController.text = DateFormat('yyyy-MM-dd').format(date);
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Description (Optional)',
                  hint: 'e.g. For dinner',
                  controller: _descController,
                  maxLength: 150,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Save Transaction', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
