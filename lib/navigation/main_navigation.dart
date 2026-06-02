import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/home/screens/home_screen.dart';
import '../features/mylife/screens/mylife_screen.dart';
import '../features/gharlog/screens/gharlog_screen.dart';
import '../features/padhoai/screens/padhoai_screen.dart';
import '../features/ai_coach/screens/ai_coach_screen.dart';
import '../core/theme/app_localizations.dart';
import '../features/home/widgets/interactive_tour_overlay.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;
  bool _showTourOverlay = false;
  final List<TourTarget> _tourTargets = [];

  // Keys for highlight showcase tour
  final GlobalKey _homeTabKey = GlobalKey();
  final GlobalKey _myLifeTabKey = GlobalKey();
  final GlobalKey _aiCoachFabKey = GlobalKey();
  final GlobalKey _gharLogTabKey = GlobalKey();
  final GlobalKey _padhoAiTabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTour();
    });
  }

  Future<void> _checkAndShowTour() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('has_seen_inapp_tour') ?? false;
    if (!hasSeen && mounted) {
      final loc = ref.read(localizationsProvider);
      
      setState(() {
        _tourTargets.addAll([
          TourTarget(
            key: _homeTabKey,
            title: loc.translate('home'),
            description: "Your central cockpit! Check daily reminders, upcoming medications, and quick action tiles at a glance.",
            icon: Iconsax.home,
            color: const Color(0xFF6C63FF),
          ),
          TourTarget(
            key: _myLifeTabKey,
            title: loc.translate('my_life'),
            description: "Track your habits, check in on your daily mood, and log statistics. Your personal health and productivity hub.",
            icon: Iconsax.heart,
            color: const Color(0xFFFF6B35),
          ),
          TourTarget(
            key: _aiCoachFabKey,
            title: "AI Coach",
            description: "Meet your advanced AI companion! Tap here to get instant personalized coaching and answers to your life questions.",
            icon: Icons.auto_awesome,
            color: const Color(0xFF8A3FFC),
          ),
          TourTarget(
            key: _gharLogTabKey,
            title: loc.translate('ghar_log'),
            description: "Manage your household, family health profiles, medicine logs, symptoms, and doctor visits in one place.",
            icon: Iconsax.home_hashtag,
            color: const Color(0xFF2D6A4F),
          ),
          TourTarget(
            key: _padhoAiTabKey,
            title: loc.translate('padho_ai'),
            description: "Your academic assistant. Run study timers, check detailed subjects, and monitor your academic progress.",
            icon: Iconsax.book,
            color: const Color(0xFF38B2AC),
          ),
        ]);
      });

      // Wait a moment for layout to settle and initial data fetching/transitions to finish
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        setState(() {
          _showTourOverlay = true;
        });
      }
    }
  }

  Future<void> _markTourCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_inapp_tour', true);
  }

  List<Widget> _getScreens() {
    return [
      HomeScreen(
        onNavigateTab: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      const MyLifeScreen(),
      const GharLogScreen(),
      const PadhoAIScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(localizationsProvider);

    return Stack(
      children: [
        PopScope(
          canPop: _currentIndex == 0,
          onPopInvoked: (didPop) {
            if (!didPop) {
              setState(() => _currentIndex = 0);
            }
          },
          child: Scaffold(
            body: _getScreens()[_currentIndex],
            floatingActionButton: FloatingActionButton(
              key: _aiCoachFabKey,
              heroTag: null,
              shape: const CircleBorder(), // Force it to be perfectly circular to fit the notch
              elevation: 4,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AICoachScreen()));
              },
              backgroundColor: const Color(0xFF6C63FF),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 6.0,
              clipBehavior: Clip.antiAlias,
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              height: 64.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Iconsax.home, loc.translate('home'), 0, _homeTabKey),
                  _buildNavItem(Iconsax.heart, loc.translate('my_life'), 1, _myLifeTabKey),
                  const SizedBox(width: 48), // Space for FAB
                  _buildNavItem(Iconsax.home_hashtag, loc.translate('ghar_log'), 2, _gharLogTabKey),
                  _buildNavItem(Iconsax.book, loc.translate('padho_ai'), 3, _padhoAiTabKey),
                ],
              ),
            ),
          ),
        ),
        if (_showTourOverlay)
          InteractiveTourOverlay(
            targets: _tourTargets,
            onComplete: () {
              setState(() {
                _showTourOverlay = false;
              });
              _markTourCompleted();
            },
          ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, Key key) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primary : Colors.grey;

    return InkWell(
      key: key,
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
