import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/habit_provider.dart';
import '../models/habit_model.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final List<int> _selectedDays = [0, 1, 2, 3, 4]; // Mon-Fri default
  bool _isLoading = false;

  void _saveHabit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a habit name')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newHabit = HabitModel(
        id: '',
        name: name,
        frequency: _selectedDays.length == 7 ? 'daily' : 'custom',
        customDays: _selectedDays,
      );

      await ref.read(habitsProvider.notifier).addHabit(newHabit);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Habit Added!')));
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
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Add New Habit', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(theme, 'Habit Name', 'e.g. Morning Yoga', _nameController),
            const SizedBox(height: 16),
            _buildTextField(theme, 'Category', 'e.g. Health & Fitness', _categoryController),
            const SizedBox(height: 32),
            Text('Frequency', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDayChip(theme, 'Mon', 0),
                _buildDayChip(theme, 'Tue', 1),
                _buildDayChip(theme, 'Wed', 2),
                _buildDayChip(theme, 'Thu', 3),
                _buildDayChip(theme, 'Fri', 4),
                _buildDayChip(theme, 'Sat', 5),
                _buildDayChip(theme, 'Sun', 6),
              ],
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveHabit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFFFF6B35), // MyLife Color
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Habit', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(ThemeData theme, String label, String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDayChip(ThemeData theme, String label, int dayIndex) {
    final isSelected = _selectedDays.contains(dayIndex);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool value) {
        setState(() {
          if (value) {
            _selectedDays.add(dayIndex);
          } else {
            _selectedDays.remove(dayIndex);
          }
        });
      },
      selectedColor: const Color(0xFFFF6B35).withOpacity(0.2),
      checkmarkColor: const Color(0xFFFF6B35),
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
