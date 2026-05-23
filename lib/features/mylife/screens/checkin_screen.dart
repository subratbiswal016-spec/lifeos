import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';

import '../../../core/widgets/app_button.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  late ConfettiController _confettiController;
  
  // Form State
  int _mood = 3;
  double _sleepHours = 7.0;
  int _energyLevel = 3;
  double _moneySpent = 0.0;
  String _spendCategory = '';
  final _noteController = TextEditingController();

  final List<String> _categories = ['Food', 'Travel', 'Shopping', 'Other'];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _confettiController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _submit() {
    _confettiController.play();
    // Haptic feedback logic can go here (using vibration package)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Daily Check-in'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / 5,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                  minHeight: 8,
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildMoodStep(theme),
                    _buildSleepStep(theme),
                    _buildEnergyStep(theme),
                    _buildMoneyStep(theme),
                    _buildNoteStep(theme),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: AppButton(
                  text: _currentStep == 4 ? 'Complete Check-in' : 'Next',
                  onPressed: _nextStep,
                ),
              )
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodStep(ThemeData theme) {
    final emojis = ['😭', '😔', '😐', '🙂', '🤩'];
    final labels = ['Terrible', 'Bad', 'Okay', 'Good', 'Awesome'];

    return FadeInUp(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('How are you feeling today?', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final isSelected = _mood == index + 1;
              return GestureDetector(
                onTap: () => setState(() => _mood = index + 1),
                child: AnimatedScale(
                  scale: isSelected ? 1.3 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
                      Text(emojis[index], style: const TextStyle(fontSize: 40)),
                      const SizedBox(height: 8),
                      if (isSelected)
                        Text(
                          labels[index],
                          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
              );
            }),
          )
        ],
      ),
    );
  }

  Widget _buildSleepStep(ThemeData theme) {
    return FadeInRight(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('How many hours did you sleep?', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          Text('${_sleepHours.toInt()} hrs', style: theme.textTheme.displayMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
          Slider(
            value: _sleepHours,
            min: 0,
            max: 12,
            divisions: 24,
            activeColor: theme.colorScheme.primary,
            onChanged: (value) => setState(() => _sleepHours = value),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyStep(ThemeData theme) {
    return FadeInRight(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('What\'s your energy level?', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final isSelected = _energyLevel == index + 1;
              return GestureDetector(
                onTap: () => setState(() => _energyLevel = index + 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: isSelected ? theme.colorScheme.primary : Colors.grey.withOpacity(0.3)),
                  ),
                  child: Icon(
                    Iconsax.battery_charging,
                    color: isSelected ? Colors.white : Colors.grey,
                    size: 32,
                  ),
                ),
              );
            }),
          )
        ],
      ),
    );
  }

  Widget _buildMoneyStep(ThemeData theme) {
    return FadeInRight(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Money spent today (₹)', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              keyboardType: TextInputType.number,
              style: theme.textTheme.displaySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                prefixText: '₹ ',
                border: InputBorder.none,
                hintText: '0',
                hintStyle: theme.textTheme.displaySmall?.copyWith(color: Colors.grey.withOpacity(0.5)),
              ),
              onChanged: (val) => _moneySpent = double.tryParse(val) ?? 0.0,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              children: _categories.map((cat) {
                final isSelected = _spendCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _spendCategory = cat);
                  },
                  selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onBackground,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNoteStep(ThemeData theme) {
    return FadeInRight(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Any quick note?', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write about your day...',
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
