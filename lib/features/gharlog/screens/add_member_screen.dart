import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/family_member_model.dart';
import '../providers/gharlog_provider.dart';
import '../../../core/widgets/app_text_field.dart';

class AddMemberScreen extends ConsumerStatefulWidget {
  const AddMemberScreen({super.key});

  @override
  ConsumerState<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends ConsumerState<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _relation = 'Self';
  bool _isLoading = false;

  final List<String> _relations = ['Self', 'Papa', 'Maa', 'Dadi', 'Nana', 'Child', 'Spouse', 'Other'];

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final newMember = FamilyMemberModel(
        id: '', // Will be assigned by backend
        name: _nameController.text.trim(),
        relation: _relation,
        age: int.tryParse(_ageController.text.trim()),
      );
      
      await ref.read(gharLogMembersProvider.notifier).addMember(newMember);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member added successfully!')));
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
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Add Family Member', style: TextStyle(fontWeight: FontWeight.bold)),
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
              Text('Member Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTextField(
                theme: theme,
                label: 'Name',
                hint: 'e.g. Rahul',
                controller: _nameController,
                maxLength: 50,
                validator: (val) => val == null || val.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                theme: theme,
                label: 'Age',
                hint: 'e.g. 45',
                controller: _ageController,
                keyboardType: TextInputType.number,
                maxLength: 3,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter age';
                  final age = int.tryParse(val);
                  if (age == null || age < 1 || age > 120) return 'Please enter a valid age (1-120)';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Relation',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor.withOpacity(0.9),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _relation,
                    decoration: InputDecoration(
                      hintText: 'Select Relation',
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    items: _relations.map((r) => DropdownMenuItem(value: r, child: Text(r, style: TextStyle(color: textColor)))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _relation = val);
                    },
                    dropdownColor: theme.colorScheme.surface,
                  ),
                ],
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveMember,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Member', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required ThemeData theme,
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return AppTextField(
      label: label,
      hint: hint,
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      maxLength: maxLength,
      validator: validator,
    );
  }
}
