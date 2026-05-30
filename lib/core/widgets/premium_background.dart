import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class PremiumBackground extends StatelessWidget {
  final Widget child;
  final bool showOrbs;

  const PremiumBackground({
    super.key,
    required this.child,
    this.showOrbs = true,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark ? [
            const Color(0xFF0F172A), // Slate 900
            const Color(0xFF020617), // Slate 950
            const Color(0xFF000000), // Black
          ] : [
            const Color(0xFFF8FAFC), // Slate 50
            const Color(0xFFF1F5F9), // Slate 100
            const Color(0xFFE2E8F0), // Slate 200
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          if (showOrbs) ...[
            // Top Right Orb
            Positioned(
              top: -size.height * 0.1,
              right: -size.width * 0.2,
              child: FadeIn(
                duration: const Duration(seconds: 3),
                child: Container(
                  width: size.width * 0.7,
                  height: size.width * 0.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withOpacity(isDark ? 0.15 : 0.08),
                    backgroundBlendMode: isDark ? BlendMode.screen : BlendMode.multiply,
                  ),
                ),
              ),
            ),
            // Bottom Left Orb
            Positioned(
              bottom: -size.height * 0.1,
              left: -size.width * 0.2,
              child: FadeIn(
                duration: const Duration(seconds: 3),
                delay: const Duration(milliseconds: 500),
                child: Container(
                  width: size.width * 0.6,
                  height: size.width * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.secondary.withOpacity(isDark ? 0.10 : 0.06),
                    backgroundBlendMode: isDark ? BlendMode.screen : BlendMode.multiply,
                  ),
                ),
              ),
            ),
          ],
          SafeArea(child: child),
        ],
      ),
    );
  }
}
