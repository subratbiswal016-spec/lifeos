import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../models/family_member_model.dart';
import '../providers/gharlog_provider.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/theme/app_localizations.dart';

class AddMemberScreen extends ConsumerStatefulWidget {
  final FamilyMemberModel? existingMember;
  const AddMemberScreen({super.key, this.existingMember});

  @override
  ConsumerState<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends ConsumerState<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _customRelationController = TextEditingController();
  String _selectedRelationKey = 'rel_self';
  bool _isLoading = false;
  String? _photoBase64;
  Uint8List? _photoBytes;

  final List<String> _relationKeys = ['rel_self', 'rel_papa', 'rel_maa', 'rel_dadi', 'rel_nana', 'rel_child', 'rel_spouse', 'rel_other'];

  @override
  void initState() {
    super.initState();
    if (widget.existingMember != null) {
      final mem = widget.existingMember!;
      _nameController.text = mem.name;
      _ageController.text = mem.age?.toString() ?? '';
      if (_relationKeys.contains(mem.relation)) {
        _selectedRelationKey = mem.relation;
      } else {
        _selectedRelationKey = 'rel_other';
        _customRelationController.text = mem.relation;
      }
      
      if (mem.photoUrl != null && mem.photoUrl!.startsWith('data:image')) {
        _photoBase64 = mem.photoUrl;
        try {
          final b64 = mem.photoUrl!.split(',').last;
          _photoBytes = base64Decode(b64);
        } catch (e) {
          debugPrint('Error decoding base64 image: $e');
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _photoBytes = bytes;
        _photoBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      });
    }
  }

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final finalRelation = _selectedRelationKey == 'rel_other' 
          ? _customRelationController.text.trim() 
          : _selectedRelationKey;

      final newMember = FamilyMemberModel(
        id: widget.existingMember?.id ?? '', // Will be assigned by backend if new
        name: _nameController.text.trim(),
        relation: finalRelation,
        age: int.tryParse(_ageController.text.trim()),
        photoUrl: _photoBase64,
      );
      
      if (widget.existingMember != null) {
        await ref.read(gharLogMembersProvider.notifier).updateMember(widget.existingMember!.id, newMember);
      } else {
        await ref.read(gharLogMembersProvider.notifier).addMember(newMember);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.existingMember != null ? 'Member updated successfully!' : 'Member added successfully!')));
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
    final loc = ref.watch(localizationsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(widget.existingMember != null ? 'Edit Family Member' : 'Add Family Member', style: const TextStyle(fontWeight: FontWeight.bold)),
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
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: theme.colorScheme.surface,
                        backgroundImage: _photoBytes != null ? MemoryImage(_photoBytes!) : null,
                        child: _photoBytes == null
                            ? Icon(Icons.person, size: 50, color: theme.colorScheme.primary)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
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
                    value: _selectedRelationKey,
                    decoration: InputDecoration(
                      hintText: loc.translate('Select Relation'),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    items: _relationKeys.map((r) => DropdownMenuItem(value: r, child: Text(loc.translate(r), style: TextStyle(color: textColor)))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRelationKey = val);
                    },
                    dropdownColor: theme.colorScheme.surface,
                  ),
                  if (_selectedRelationKey == 'rel_other') ...[
                    const SizedBox(height: 16),
                    _buildTextField(
                      theme: theme,
                      label: 'Custom Relation',
                      hint: 'e.g. Best Friend',
                      controller: _customRelationController,
                      maxLength: 30,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ],
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
                      : Text(widget.existingMember != null ? 'Update Member' : 'Save Member', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
