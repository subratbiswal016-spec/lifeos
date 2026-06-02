import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/premium_background.dart';
import '../../../core/widgets/glass_container.dart';

class FeatureTourScreen extends ConsumerStatefulWidget {
  const FeatureTourScreen({super.key});

  @override
  ConsumerState<FeatureTourScreen> createState() => _FeatureTourScreenState();
}

class _FeatureTourScreenState extends ConsumerState<FeatureTourScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _tourData = [
    {
      "title": "Welcome to LifeOS!",
      "subtitle": "Your ultimate hub to track, manage, and optimize every aspect of your life.",
      "icon": Iconsax.health,
      "color": const Color(0xFF6C63FF),
    },
    {
      "title": "My Life",
      "subtitle": "Track your mood, sleep, energy, and build powerful daily habits.",
      "icon": Iconsax.activity,
      "color": const Color(0xFFFF6B35),
    },
    {
      "title": "Ghar Ki Sehat",
      "subtitle": "Manage family health profiles, medicine reminders, and doctor visits easily.",
      "icon": Iconsax.heart,
      "color": const Color(0xFF2D6A4F),
    },
    {
      "title": "Wallet & Udhar",
      "subtitle": "Track your daily expenses and seamlessly manage debts given or taken.",
      "icon": Iconsax.wallet_money,
      "color": const Color(0xFFE5B300),
    },
    {
      "title": "PadhoAI",
      "subtitle": "Your personal AI study companion with focus timers and analytics.",
      "icon": Iconsax.book_1,
      "color": const Color(0xFF38B2AC),
    }
  ];

  Future<void> _completeTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_feature_tour', true);
    if (mounted) {
      final isAuthenticated = ref.read(authProvider).isAuthenticated;
      if (isAuthenticated) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    }
  }

  void _nextPage() {
    if (_currentPage < _tourData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _completeTour();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: PremiumBackground(
        showOrbs: true,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: _tourData.length,
              itemBuilder: (context, index) {
                return _buildPage(
                  context,
                  data: _tourData[index],
                  theme: theme,
                  size: size,
                );
              },
            ),
            
            // Skip Button
            Positioned(
              top: 50,
              right: 20,
              child: FadeIn(
                child: TextButton(
                  onPressed: _completeTour,
                  child: Text(
                    'Skip Tour',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Navigation Area
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(
                        _tourData.length,
                        (index) => _buildDot(index, theme),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: AppButton(
                        text: _currentPage == _tourData.length - 1 ? 'Get Started' : 'Next',
                        onPressed: _nextPage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, {required Map<String, dynamic> data, required ThemeData theme, required Size size}) {
    final Color color = data['color'];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: GlassContainer(
              padding: const EdgeInsets.all(40),
              child: Icon(
                data['icon'],
                size: 100,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 60),
          FadeInUp(
            child: Text(
              data['title'],
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              data['subtitle'],
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
                height: 1.5,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildDot(int index, ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? theme.colorScheme.primary : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
