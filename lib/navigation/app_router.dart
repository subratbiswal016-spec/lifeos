import 'package:go_router/go_router.dart';
import 'package:lifeos_ui/features/padhoai/screens/study_stats_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/home/screens/feature_tour_screen.dart';
import '../navigation/main_navigation.dart';
import '../features/premium/screens/premium_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/mylife/screens/checkin_screen.dart';
import '../features/mylife/screens/manage_habits_screen.dart';
import '../features/gharlog/screens/member_profile_screen.dart';
import '../features/gharlog/screens/add_medicine_screen.dart';
import '../features/gharlog/models/medicine_model.dart';
import '../features/padhoai/screens/pomodoro_timer_screen.dart';
import '../features/padhoai/screens/subject_details_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/profile/screens/notifications_screen.dart';
import '../features/profile/screens/privacy_screen.dart';
import '../features/gharlog/screens/doctor_visits_screen.dart';
import '../features/gharlog/screens/add_doctor_visit_screen.dart';
import '../features/gharlog/screens/symptoms_logger_screen.dart';
import '../features/mylife/screens/add_habit_screen.dart';
import '../features/home/screens/reminder_details_screen.dart';
import '../features/mylife/screens/life_stats_screen.dart';
import '../features/udhar/screens/udhar_screen.dart';
import '../features/expenses/screens/expense_dashboard_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/forgot_password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/feature_tour',
      builder: (context, state) => const FeatureTourScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainNavigation(),
    ),
    GoRoute(
      path: '/premium',
      builder: (context, state) => const PremiumScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/mood_logger',
      builder: (context, state) => const CheckInScreen(),
    ),
    GoRoute(
      path: '/manage_habits',
      builder: (context, state) => const ManageHabitsScreen(),
    ),
    GoRoute(
      path: '/member_profile/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return MemberProfileScreen(memberId: id);
      },
    ),
    GoRoute(
      path: '/add_medicine',
      builder: (context, state) => AddMedicineScreen(
        memberId: state.uri.queryParameters['memberId'],
        existingMedicine: state.extra as MedicineModel?,
      ),
    ),
    GoRoute(
      path: '/padhoai/timer',
      builder: (context, state) => PomodoroTimerScreen(
        subjectId: state.extra as String?,
      ),
    ),
    GoRoute(
      path: '/padhoai/stats',
      builder: (context, state) => const StudyStatsScreen(),
    ),
    GoRoute(
      path: '/padhoai/subject/:name',
      builder: (context, state) => SubjectDetailsScreen(
        subjectName: state.pathParameters['name'] ?? 'Subject Details',
      ),
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/profile/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/profile/privacy',
      builder: (context, state) => const PrivacyScreen(),
    ),
    GoRoute(
      path: '/gharlog/doctor_visits',
      builder: (context, state) => const DoctorVisitsScreen(),
    ),
    GoRoute(
      path: '/add_doctor_visit',
      builder: (context, state) => const AddDoctorVisitScreen(),
    ),
    GoRoute(
      path: '/gharlog/symptoms',
      builder: (context, state) => SymptomsLoggerScreen(
        memberId: state.uri.queryParameters['memberId'],
      ),
    ),
    GoRoute(
      path: '/add_habit',
      builder: (context, state) => const AddHabitScreen(),
    ),
    GoRoute(
      path: '/reminder_details',
      builder: (context, state) {
        final reminder = state.extra as Map<String, dynamic>? ?? {};
        return ReminderDetailsScreen(reminder: reminder);
      },
    ),
    GoRoute(
      path: '/life_stats',
      builder: (context, state) => const LifeStatsScreen(),
    ),
    GoRoute(
      path: '/udhar',
      builder: (context, state) => const UdharScreen(),
    ),
    GoRoute(
      path: '/expenses',
      builder: (context, state) => const ExpenseDashboardScreen(),
    ),
  ],
);
