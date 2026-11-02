import 'package:go_router/go_router.dart';
import '../core/storage/storage_service.dart';
import '../features/splash/splash_page.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/calculator/bmi_calculator_page.dart';
import '../features/progress/weight_history_page.dart';
import '../features/profile/profile_page.dart';
import '../features/profile/edit_profile_page.dart';
import '../features/profile/add_person_page.dart';
import '../features/settings/settings_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (_, state) {
    final hasProfile = StorageService.getProfile() != null;
    if (state.matchedLocation == '/' || state.matchedLocation == '/onboarding') return null;
    return hasProfile ? null : '/onboarding';
  },
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashPage()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPage()),
    GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
    GoRoute(path: '/calculator', builder: (_, __) => const BmiCalculatorPage()),
    GoRoute(path: '/weight-history', builder: (_, __) => const WeightHistoryPage()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
    GoRoute(path: '/profile/edit', builder: (_, __) => const EditProfilePage()),
    GoRoute(path: '/profile/add', builder: (_, __) => const AddPersonPage()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
  ],
);
