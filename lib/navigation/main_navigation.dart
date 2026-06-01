import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../features/home/screens/home_screen.dart';
import '../features/mylife/screens/mylife_screen.dart';
import '../features/gharlog/screens/gharlog_screen.dart';
import '../features/padhoai/screens/padhoai_screen.dart';
import '../features/ai_coach/screens/ai_coach_screen.dart';
import '../features/premium/screens/premium_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

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
    final theme = Theme.of(context);

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvoked: (didPop) {
        if (!didPop) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        body: _getScreens()[_currentIndex],
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AICoachScreen()));
        },
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Iconsax.home, 'Home', 0),
            _buildNavItem(Iconsax.heart, 'My Life', 1),
            const SizedBox(width: 48), // Space for FAB
            _buildNavItem(Iconsax.home_hashtag, 'Family', 2),
            _buildNavItem(Iconsax.book, 'Study', 3),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primary : Colors.grey;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
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
