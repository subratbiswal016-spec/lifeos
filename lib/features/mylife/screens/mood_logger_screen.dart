import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';

class MoodLoggerScreen extends ConsumerStatefulWidget {
  const MoodLoggerScreen({super.key});

  @override
  ConsumerState<MoodLoggerScreen> createState() => _MoodLoggerScreenState();
}

class _MoodLoggerScreenState extends ConsumerState<MoodLoggerScreen> {
  int _selectedMoodIndex = 2; // Default to neutral
  double _sleepHours = 7.0;
  double _energyLevel = 50.0;
  final _noteController = TextEditingController();
  bool _isLoading = false;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😢', 'label': 'Sad', 'color': Colors.blue},
    {'emoji': '😔', 'label': 'Stressed', 'color': Colors.orange},
    {'emoji': '😐', 'label': 'Neutral', 'color': Colors.grey},
    {'emoji': '😊', 'label': 'Good', 'color': Colors.green},
    {'emoji': '🤩', 'label': 'Awesome', 'color': Colors.purple},
  ];

  @override
  void dispose() {
    _noteController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      context.pop();
    }
  }

  Future<void> _saveLog() async {
    setState(() => _isLoading = true);
    try {
      final dioClient = ref.read(dioClientProvider);
      final response = await dioClient.dio.post(
        ApiEndpoints.dailyLog,
        data: {
          'mood': _selectedMoodIndex + 1, // 1 to 5
          'sleepHours': _sleepHours,
          'energyLevel': _energyLevel,
          'note': _noteController.text,
        },
      );
      
      if (response.data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Daily Check-in Saved!')));
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        // Handled by dio client toast
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: _currentPage == 0,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _previousPage();
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          title: Text('Step ${_currentPage + 1} of 3', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          centerTitle: true,
          backgroundColor: theme.colorScheme.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _previousPage,
          ),
        ),
        body: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentPage + 1) / 3,
              backgroundColor: theme.colorScheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe to force using buttons
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildMoodStep(theme),
                  _buildSleepEnergyStep(theme),
                  _buildNoteStep(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'How are you feeling today?',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_moods.length, (index) {
                final isSelected = _selectedMoodIndex == index;
                final mood = _moods[index];
                return GestureDetector(
                  onTap: () => setState(() => _selectedMoodIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? mood['color'].withOpacity(0.2) : theme.colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? mood['color'] : theme.colorScheme.onBackground.withOpacity(0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      mood['emoji'],
                      style: TextStyle(fontSize: isSelected ? 36 : 24),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 48),
          _buildNextButton(theme, 'Next: Sleep & Energy', _nextPage),
        ],
      ),
    );
  }

  Widget _buildSleepEnergyStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Sleep Hours: ${_sleepHours.toStringAsFixed(1)} h',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Slider(
            value: _sleepHours,
            min: 0,
            max: 14,
            divisions: 28,
            activeColor: theme.colorScheme.primary,
            onChanged: (val) => setState(() => _sleepHours = val),
          ),
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Energy Level: ${_energyLevel.toInt()}%',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Slider(
            value: _energyLevel,
            min: 0,
            max: 100,
            divisions: 20,
            activeColor: const Color(0xFFFF6B35),
            onChanged: (val) => setState(() => _energyLevel = val),
          ),
          const SizedBox(height: 48),
          _buildNextButton(theme, 'Next: Final Notes', _nextPage),
        ],
      ),
    );
  }

  Widget _buildNoteStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Add a Note (Optional)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Why are you feeling this way?',
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
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
                : const Text('Save Log', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(ThemeData theme, String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5)),
          ),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
