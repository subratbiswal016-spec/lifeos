import 'package:go_router/go_router.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../navigation/main_navigation.dart';
import '../features/premium/screens/premium_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/mylife/screens/checkin_screen.dart';
import '../features/mylife/screens/manage_habits_screen.dart';
import '../features/gharlog/screens/member_profile_screen.dart';
import '../features/gharlog/screens/add_medicine_screen.dart';
import '../features/padhoai/screens/pomodoro_timer_screen.dart';
import '../features/padhoai/screens/subject_details_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/profile/screens/notifications_screen.dart';
import '../features/profile/screens/privacy_screen.dart';
import '../features/gharlog/screens/doctor_visits_screen.dart';
import '../features/gharlog/screens/symptoms_logger_screen.dart';
import '../features/mylife/screens/add_habit_screen.dart';
import '../features/home/screens/reminder_details_screen.dart';
import '../features/mylife/screens/life_stats_screen.dart';

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
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
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
      ),
    ),
    GoRoute(
      path: '/padhoai/timer',
      builder: (context, state) => const PomodoroTimerScreen(),
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
      path: '/reminder_details/:title',
      builder: (context, state) => ReminderDetailsScreen(
        title: state.pathParameters['title'] ?? 'Reminder',
      ),
    ),
    GoRoute(
      path: '/life_stats',
      builder: (context, state) => const LifeStatsScreen(),
    ),
  ],
);
