import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/checkin_provider.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  late ConfettiController _confettiController;

  // Form State
  int _mood = 3;
  double _sleepHours = 7.0;
  double _energyLevel = 50.0; // Changed to percentage 0-100
  double _moneySpent = 0.0;
  String _spendCategory = '';
  final _noteController = TextEditingController();

  final List<String> _categories = ['Food', 'Travel', 'Shopping', 'Other'];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
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
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastOutSlowIn,
      );
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  bool _isSubmitting = false;

  void _submit() async {
    setState(() => _isSubmitting = true);
    final data = {
      'date': DateTime.now().toIso8601String().split('T')[0],
      'mood': _mood,
      'sleepHours': _sleepHours,
      'energyLevel': _energyLevel.toInt(), // Save as 0-100 integer
      'moneySpent': _moneySpent,
      'spendCategory': _spendCategory,
      'note': _noteController.text,
    };

    final success = await ref.read(checkinProvider.notifier).submit(data);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        _confettiController.play();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) context.replace('/life_stats');
        });
      } else {
        final error = ref.read(checkinProvider).error ?? 'Submission failed';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  // Premium Background Widget
  Widget _buildPremiumBackground() {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Container(color: theme.colorScheme.background),
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF6B35).withOpacity(0.15),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          right: -50,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6C63FF).withOpacity(0.15),
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }

  // Premium Glass Card Widget
  Widget _buildGlassCard({required Widget child, double? height}) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: height,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.4),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 30,
                spreadRadius: -5,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Daily Check-in',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          _buildPremiumBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    children: List.generate(5, (index) {
                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 6,
                          decoration: BoxDecoration(
                            color: index <= _currentStep
                                ? theme.colorScheme.primary
                                : theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: index <= _currentStep
                                ? [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.5),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
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
                ),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: _isSubmitting
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _nextStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 10,
                              shadowColor: theme.colorScheme.primary
                                  .withOpacity(0.5),
                            ),
                            child: Text(
                              _currentStep == 4
                                  ? 'Complete Check-in'
                                  : 'Continue',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
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
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How are you feeling?',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 48),
              _buildGlassCard(
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (index) {
                    final isSelected = _mood == index + 1;
                    return GestureDetector(
                      onTap: () => setState(() => _mood = index + 1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        transform: Matrix4.identity()
                          ..scale(isSelected ? 1.4 : 1.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              emojis[index],
                              style: const TextStyle(fontSize: 36),
                            ),
                            if (isSelected) ...[
                              const SizedBox(height: 12),
                              Text(
                                labels[index],
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSleepStep(ThemeData theme) {
    return FadeInRight(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hours of sleep',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 48),
              _buildGlassCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Colors.indigo.shade300,
                          Colors.purple.shade300,
                        ],
                      ).createShader(bounds),
                      child: Text(
                        '${_sleepHours.toStringAsFixed(1)}h',
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 12,
                        activeTrackColor: Colors.indigo,
                        inactiveTrackColor: Colors.indigo.withOpacity(0.1),
                        thumbColor: Colors.white,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 16,
                          elevation: 5,
                        ),
                        overlayColor: Colors.indigo.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: _sleepHours,
                        min: 0,
                        max: 12,
                        divisions: 24,
                        onChanged: (value) =>
                            setState(() => _sleepHours = value),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnergyStep(ThemeData theme) {
    return FadeInRight(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Energy Level',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 48),
              _buildGlassCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: CircularProgressIndicator(
                            value: _energyLevel / 100,
                            strokeWidth: 20,
                            backgroundColor: theme.colorScheme.primary
                                .withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color.lerp(
                                    Colors.redAccent,
                                    Colors.greenAccent,
                                    _energyLevel / 100,
                                  ) ??
                                  theme.colorScheme.primary,
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          children: [
                            Icon(
                              Iconsax.flash_15,
                              size: 40,
                              color: Color.lerp(
                                Colors.redAccent,
                                Colors.greenAccent,
                                _energyLevel / 100,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_energyLevel.toInt()}%',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 12,
                        activeTrackColor: Color.lerp(
                          Colors.redAccent,
                          Colors.greenAccent,
                          _energyLevel / 100,
                        ),
                        inactiveTrackColor: Colors.grey.withOpacity(0.2),
                        thumbColor: Colors.white,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 16,
                          elevation: 5,
                        ),
                      ),
                      child: Slider(
                        value: _energyLevel,
                        min: 0,
                        max: 100,
                        onChanged: (value) =>
                            setState(() => _energyLevel = value),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoneyStep(ThemeData theme) {
    return FadeInRight(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Money Spent',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 48),
              _buildGlassCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      keyboardType: TextInputType.number,
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        prefixText: '₹ ',
                        prefixStyle: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                        border: InputBorder.none,
                        hintText: '0',
                        hintStyle: theme.textTheme.displayMedium?.copyWith(
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                      onChanged: (val) =>
                          _moneySpent = double.tryParse(val) ?? 0.0,
                    ),
                    const Divider(height: 48),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: _categories.map((cat) {
                        final isSelected = _spendCategory == cat;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected)
                                setState(() => _spendCategory = cat);
                            },
                            backgroundColor: theme.colorScheme.surface
                                .withOpacity(0.5),
                            selectedColor: theme.colorScheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : theme.colorScheme.onBackground,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            side: BorderSide.none,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteStep(ThemeData theme) {
    return FadeInRight(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Journal Entry',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 48),
              _buildGlassCard(
                child: TextField(
                  controller: _noteController,
                  maxLines: 6,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                  decoration: InputDecoration(
                    hintText: 'What made today unique?',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onBackground.withOpacity(0.4),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
