import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';

import '../../../core/widgets/premium_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../providers/dashboard_provider.dart';
import '../providers/daily_tip_provider.dart';
import '../../ai_coach/screens/ai_coach_screen.dart';
import '../../../core/widgets/app_text_field.dart';
import '../widgets/daily_tip_card.dart';
import '../widgets/quick_stats_card.dart';
import '../widgets/upcoming_reminders.dart';
import '../../../core/theme/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _hasShownOnboardingDialog = false;

  String _getFormattedDate(String todayLoc) {
    final now = DateTime.now();
    final englishDate = DateFormat('EEEE, d MMM').format(now);
    return '$englishDate • $todayLoc'; 
  }

  Future<void> _showOnboardingDialog(BuildContext context, ThemeData theme) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController cityController = TextEditingController();
    final TextEditingController prepController = TextEditingController();
    final TextEditingController wakeController = TextEditingController();
    final TextEditingController sleepController = TextEditingController();
    final TextEditingController budgetController = TextEditingController();
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: GlassContainer(
                padding: const EdgeInsets.all(24),
                borderRadius: 24,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Complete Profile 🎉',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Just a few more details to get you started on LifeOS.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.8)),
                        ),
                        const SizedBox(height: 24),
                        AppTextField(
                          label: 'Phone Number (10 digits)',
                          hint: 'Enter your 10 digit phone number',
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Required';
                            if (val.length != 10 || int.tryParse(val) == null) return 'Must be exactly 10 digits';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'City',
                          hint: 'Enter your city',
                          controller: cityController,
                          maxLength: 50,
                          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Preparation (e.g. UPSC, JEE, Job)',
                          hint: 'What are you preparing for?',
                          controller: prepController,
                          maxLength: 50,
                          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'Wake Time',
                                hint: '06:00 AM',
                                controller: wakeController,
                                readOnly: true,
                                onTap: () async {
                                  final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                                  if (time != null) {
                                    wakeController.text = time.format(context);
                                  }
                                },
                                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AppTextField(
                                label: 'Sleep Time',
                                hint: '10:00 PM',
                                controller: sleepController,
                                readOnly: true,
                                onTap: () async {
                                  final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                                  if (time != null) {
                                    sleepController.text = time.format(context);
                                  }
                                },
                                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Monthly Budget (₹)',
                          hint: 'e.g. 5000',
                          controller: budgetController,
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Required';
                            final b = int.tryParse(val);
                            if (b == null) return 'Invalid number';
                            if (b > 500000) return 'Maximum budget is ₹5,00,000';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: isLoading ? null : () async {
                              if (formKey.currentState!.validate()) {
                                setState(() => isLoading = true);
                                try {
                                  final dioClient = ref.read(dioClientProvider);
                                  await dioClient.dio.put(
                                    ApiEndpoints.profile,
                                    data: {
                                      'phone': phoneController.text,
                                      'city': cityController.text,
                                      'examPreparingFor': prepController.text,
                                      'wakeTime': wakeController.text,
                                      'sleepTime': sleepController.text,
                                      'monthlyBudget': int.parse(budgetController.text)
                                    },
                                  );
                                  if (mounted) {
                                    Navigator.pop(context);
                                    ref.refresh(dashboardProvider);
                                  }
                                } catch (e) {
                                  // error handled
                                } finally {
                                  if (mounted) setState(() => isLoading = false);
                                }
                              }
                            },
                            child: isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Save & Continue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = ref.watch(localizationsProvider);
    final dashboardState = ref.watch(dashboardProvider);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        showOrbs: true,
        child: Column(
          children: [
            // Custom AppBar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  dashboardState.when(
                    loading: () => const SizedBox.shrink(),
                    error: (err, stack) => const SizedBox.shrink(),
                    data: (data) => FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Namaste, ${data['name'] ?? 'User'}! 🙏',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getFormattedDate(loc.translate('today')),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: subtitleColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  FadeInRight(
                    duration: const Duration(milliseconds: 600),
                    child: InkWell(
                      onTap: () => context.push('/profile'),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.colorScheme.primary, width: 2),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: dashboardState.valueOrNull?['profilePhotoUrl'] != null
                              ? (dashboardState.valueOrNull!['profilePhotoUrl'].toString().startsWith('data:image')
                                  ? MemoryImage(base64Decode(dashboardState.valueOrNull!['profilePhotoUrl'].toString().split(',').last))
                                  : NetworkImage(dashboardState.valueOrNull!['profilePhotoUrl'])) as ImageProvider
                              : const NetworkImage('https://i.pravatar.cc/150?img=11'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.0),
                    theme.colorScheme.primary.withOpacity(0.35),
                    theme.colorScheme.primary.withOpacity(0.0),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.refresh(dashboardProvider);
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: dashboardState.when(
                    loading: () => const Center(child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    )),
                    error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
                    data: (data) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if ((data['phone'] == null || data['city'] == null || data['monthlyBudget'] == null) && !_hasShownOnboardingDialog) {
                          _hasShownOnboardingDialog = true;
                          _showOnboardingDialog(context, theme);
                        }
                      });

                      final quickStats = data['quickStats'] ?? {};
                      final reminders = data['reminders'] as List? ?? [];
                      final dailyTipState = ref.watch(dailyTipProvider);
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeInUp(
                            delay: const Duration(milliseconds: 200),
                            child: dailyTipState.when(
                              loading: () => DailyTipCard(theme: theme, tip: 'Generating your AI tip... ✨', title: loc.translate('ai_daily_tip')),
                              error: (e, st) => DailyTipCard(theme: theme, tip: 'Take a deep breath and start your day.', title: loc.translate('ai_daily_tip')),
                              data: (tip) => DailyTipCard(theme: theme, tip: tip, title: loc.translate('ai_daily_tip')),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Daily Check-in Banner
                          FadeInUp(
                            delay: const Duration(milliseconds: 300),
                            child: GlassContainer(
                              onTap: () => context.push('/mood_logger'),
                              padding: const EdgeInsets.all(20),
                              color: theme.colorScheme.primary.withOpacity(0.15),
                              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3), width: 1),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Iconsax.note_2, color: theme.colorScheme.primary, size: 28),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(loc.translate('daily_checkin'), style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text(loc.translate('log_mood'), style: TextStyle(color: subtitleColor, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios, color: subtitleColor, size: 16),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          FadeInUp(
                            delay: const Duration(milliseconds: 400),
                            child: Text(
                              loc.translate('quick_access'),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                  
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 140,
                                  child: FadeInUp(
                                    delay: const Duration(milliseconds: 500),
                                    child: QuickStatsCard(
                                      title: loc.translate('udhar_manager'),
                                      subtitle: 'Manage debts\nGiven & Taken',
                                      icon: Iconsax.wallet_money,
                                      color: const Color(0xFFE5B300),
                                      onTap: () => context.push('/udhar'),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 140,
                                  child: FadeInUp(
                                    delay: const Duration(milliseconds: 600),
                                    child: QuickStatsCard(
                                      title: loc.translate('my_life'),
                                      subtitle: 'Mood: ${quickStats['mood'] ?? '😊'}\nSleep: ${quickStats['sleep'] ?? 0}h • Nrg: ${quickStats['energy'] ?? 0}%',
                                      icon: Iconsax.heart,
                                      color: const Color(0xFFFF6B35),
                                      onTap: () => widget.onNavigateTab?.call(1),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 140,
                                  child: FadeInUp(
                                    delay: const Duration(milliseconds: 600),
                                    child: QuickStatsCard(
                                      title: loc.translate('ghar_log'),
                                      subtitle: '${quickStats['familyMembers'] ?? 0} Members\n${quickStats['medsDue'] ?? 0} Meds Due',
                                      icon: Iconsax.home,
                                      color: const Color(0xFF2D6A4F),
                                      onTap: () => widget.onNavigateTab?.call(2),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 140,
                                  child: FadeInUp(
                                    delay: const Duration(milliseconds: 700),
                                    child: QuickStatsCard(
                                      title: loc.translate('padho_ai'),
                                      subtitle: '${quickStats['subjectsStudied'] ?? 0} Subjs • ${quickStats['studyTime'] ?? 0}m\nStreak: ${quickStats['studyStreak'] ?? 0}',
                                      icon: Iconsax.book,
                                      color: const Color(0xFF6C63FF),
                                      onTap: () => widget.onNavigateTab?.call(3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          FadeInUp(
                            delay: const Duration(milliseconds: 800),
                            child: UpcomingReminders(theme: theme, reminders: reminders),
                          ),
                          const SizedBox(height: 32),
                          const SizedBox(height: 100), // Extra padding to clear the global FAB
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FadeInUp(
        delay: const Duration(milliseconds: 1000),
        child: FloatingActionButton(
          heroTag: null,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => GlassContainer(
                borderRadius: 24,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Quick Actions', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 24),
                    ListTile(
                      leading: const Icon(Iconsax.note_2, color: Color(0xFFFF6B35)),
                      title: Text('Daily Check-in', style: TextStyle(color: textColor)),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/mood_logger');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.health, color: Color(0xFFF44336)),
                      title: Text('Add Medicine', style: TextStyle(color: textColor)),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/add_medicine');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.timer_1, color: Color(0xFF6C63FF)),
                      title: Text('Start Study Timer', style: TextStyle(color: textColor)),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/padhoai/timer');
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          backgroundColor: theme.colorScheme.primary,
          child: const Icon(Iconsax.add, color: Colors.white),
        ),
      ),
    );
  }
}
