import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/study_provider.dart';
import '../providers/subject_provider.dart';

class PomodoroTimerScreen extends ConsumerStatefulWidget {
  final String? subjectId;
  const PomodoroTimerScreen({super.key, this.subjectId});

  @override
  ConsumerState<PomodoroTimerScreen> createState() => _PomodoroTimerScreenState();
}

class _PomodoroTimerScreenState extends ConsumerState<PomodoroTimerScreen> {
  bool _isSetup = true;
  int _selectedMinutes = 25;
  String? _selectedSubjectId;

  @override
  void initState() {
    super.initState();
    _selectedSubjectId = widget.subjectId;
  }

  bool _isRunning = false;
  int _totalSeconds = 25 * 60;
  int _remainingSeconds = 25 * 60;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_remainingSeconds > 0) {
            setState(() {
              _remainingSeconds--;
            });
          } else {
            _timer?.cancel();
            setState(() {
              _isRunning = false;
            });
            _stopTracking();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Focus Session Completed! 🎉')),
            );
          }
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isSetup = true;
    });
  }

  Future<void> _startTracking() async {
    if (_selectedSubjectId != null) {
      await ref.read(studyProvider.notifier).startTracking(_selectedSubjectId!, true);
    }
  }

  Future<void> _stopTracking() async {
    ref.read(studyProvider.notifier).updateDuration(_totalSeconds - _remainingSeconds);
    await ref.read(studyProvider.notifier).endTracking('Pomodoro session');
    ref.invalidate(todaySessionsProvider);
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color padhoColor = const Color(0xFF6C63FF);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Focus Session', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isSetup ? _buildSetupUI(theme, padhoColor) : _buildTimerUI(theme, padhoColor),
    );
  }

  Widget _buildSetupUI(ThemeData theme, Color padhoColor) {
    final subjectState = ref.watch(subjectProvider);
    final subjects = subjectState.subjects;
    
    // Default select first if none selected
    if (_selectedSubjectId == null && subjects.isNotEmpty) {
      _selectedSubjectId = subjects.first.id;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.timer_1, size: 80, color: padhoColor),
          const SizedBox(height: 24),
          if (subjects.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 8.0),
              child: DropdownButtonFormField<String>(
                value: _selectedSubjectId,
                decoration: InputDecoration(
                  labelText: 'Select Subject',
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (val) => setState(() => _selectedSubjectId = val),
              ),
            ),
          const SizedBox(height: 24),
          Text('Select Focus Duration', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [15, 25, 45, 60].map((mins) => ChoiceChip(
              label: Text('$mins min', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              selected: _selectedMinutes == mins,
              onSelected: (selected) {
                if (selected) setState(() => _selectedMinutes = mins);
              },
              selectedColor: padhoColor.withOpacity(0.2),
              backgroundColor: theme.colorScheme.surface,
              showCheckmark: false,
              labelStyle: TextStyle(color: _selectedMinutes == mins ? padhoColor : theme.colorScheme.onBackground),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide.none),
            )).toList(),
          ),
          const SizedBox(height: 64),
          ElevatedButton(
            onPressed: () {
              if (_selectedSubjectId == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a subject first!')));
                return;
              }
              setState(() {
                _totalSeconds = _selectedMinutes * 60;
                _remainingSeconds = _totalSeconds;
                _isSetup = false;
              });
              _startTracking();
              _toggleTimer(); // Auto-start the timer!
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: padhoColor,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Start Timer', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildTimerUI(ThemeData theme, Color padhoColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 250,
                height: 250,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 12,
                  color: theme.colorScheme.surface,
                ),
              ),
              SizedBox(
                width: 250,
                height: 250,
                child: CircularProgressIndicator(
                  value: _remainingSeconds / _totalSeconds,
                  strokeWidth: 12,
                  color: padhoColor,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(_remainingSeconds),
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Focus',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 64),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconButton(Iconsax.refresh, _resetTimer, theme.colorScheme.surface, theme.colorScheme.onBackground),
              const SizedBox(width: 24),
              FloatingActionButton.large(
                heroTag: null,
                onPressed: _toggleTimer,
                backgroundColor: padhoColor,
                child: Icon(_isRunning ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 40),
              ),
              const SizedBox(width: 24),
              _buildIconButton(Iconsax.stop, () async {
                _timer?.cancel();
                await _stopTracking();
                if (mounted) context.pop();
              }, theme.colorScheme.surface, Colors.red),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, Color bgColor, Color iconColor) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 28),
      ),
    );
  }
}
