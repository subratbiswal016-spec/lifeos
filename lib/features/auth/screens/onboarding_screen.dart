import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/widgets/app_button.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Apni Life Track Karo",
      "subtitle": "Track your mood, habits, and daily expenses all in one place.",
      "image": "assets/images/onboarding1.png", // We will use a placeholder widget for now
      "icon": Icons.track_changes,
      "color": const Color(0xFFFF6B35)
    },
    {
      "title": "Ghar Ki Sehat",
      "subtitle": "Manage family health, medicines, and doctor appointments easily.",
      "image": "assets/images/onboarding2.png",
      "icon": Icons.health_and_safety,
      "color": const Color(0xFF2D6A4F)
    },
    {
      "title": "Padhai Mein Aage",
      "subtitle": "Track study hours, use Pomodoro timers, and view your progress.",
      "image": "assets/images/onboarding3.png",
      "icon": Icons.school,
      "color": const Color(0xFF6C63FF)
    },
    {
      "isForm": true,
      "color": const Color(0xFF1E1E1E), // Dark theme form
    }
  ];

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              return _buildPage(
                context,
                data: _onboardingData[index],
                theme: theme,
                index: index,
              );
            },
          ),
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
                      _onboardingData.length,
                      (index) => _buildDot(index, theme),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: AppButton(
                      text: _currentPage == _onboardingData.length - 1 ? 'Start' : 'Next',
                      onPressed: _nextPage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context, {required Map<String, dynamic> data, required ThemeData theme, required int index}) {
    if (data['isForm'] == true) {
      return _buildFormPage(theme);
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            data['color'].withOpacity(0.1),
            theme.colorScheme.background,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: data['color'].withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                data['icon'],
                size: 100,
                color: data['color'],
              ),
            ),
          ),
          const SizedBox(height: 60),
          FadeInUp(
            child: Text(
              data['title'],
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onBackground,
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
                color: theme.colorScheme.onBackground.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildFormPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeInDown(
            child: Text(
              'Let\'s personalize LifeOS',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: _buildSimpleField(theme, 'Name', 'What should we call you?'),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildSimpleField(theme, 'City', 'Where are you from?'),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: _buildSimpleField(theme, 'Preparation', 'What are you preparing for? (e.g. UPSC, JEE)'),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _buildSimpleField(theme, 'Monthly Budget (₹)', 'e.g. 5000', keyboardType: TextInputType.number),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: _buildSimpleField(theme, 'Wake Time', '06:00 AM'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: _buildSimpleField(theme, 'Sleep Time', '11:00 PM'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildSimpleField(ThemeData theme, String label, String hint, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(int index, ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? theme.colorScheme.primary : theme.colorScheme.onBackground.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
