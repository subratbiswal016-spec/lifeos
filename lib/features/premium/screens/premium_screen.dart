import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goldColor = const Color(0xFFFFD700);
    final darkSurface = const Color(0xFF1E1E1E);

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Force dark background for premium feel
      appBar: AppBar(
        title: const Text('Upgrade to Premium', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [goldColor.withOpacity(0.2), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Iconsax.crown, size: 80, color: goldColor),
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              child: Text(
                'Unlock Your Full Potential',
                style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: Text(
                'Get unlimited AI messages, more family members, and PDF reports.',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _buildFeatureRow(Iconsax.tick_circle, 'Unlimited AI Coach Messages', goldColor),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: _buildFeatureRow(Iconsax.tick_circle, 'Add Unlimited Family Members', goldColor),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: _buildFeatureRow(Iconsax.tick_circle, 'Unlimited Habits & Tasks', goldColor),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: _buildFeatureRow(Iconsax.tick_circle, 'Download PDF Reports', goldColor),
            ),
            const SizedBox(height: 48),
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: _buildPricingCard(
                theme,
                title: '₹149/month',
                subtitle: 'Mahina plan',
                color: goldColor,
                isSelected: false,
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 700),
              child: _buildPricingCard(
                theme,
                title: '₹799 lifetime',
                subtitle: 'Ek baar, hamesha ke liye',
                color: goldColor,
                isSelected: true, // Default selected
              ),
            ),
            const SizedBox(height: 40),
            FadeInUp(
              delay: const Duration(milliseconds: 800),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: goldColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goldColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('7 din free trial shuru karo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 900),
              child: TextButton(
                onPressed: () {},
                child: const Text('Restore Purchases', style: TextStyle(color: Colors.white54)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard(ThemeData theme, {required String title, required String subtitle, required Color color, required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : theme.colorScheme.surface,
        border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          if (isSelected)
            Icon(Iconsax.tick_circle, color: color, size: 28),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, Color goldColor) {
    return Row(
      children: [
        Icon(icon, color: goldColor, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
