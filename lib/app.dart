import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'navigation/app_router.dart';

class LifeOSApp extends ConsumerWidget {
  const LifeOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch so app rebuilds when theme changes
    ref.watch(themeProvider);
    final themeData = ref.read(themeProvider.notifier).currentThemeData;

    return MaterialApp.router(
      title: 'LifeOS India',
      theme: themeData,
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
