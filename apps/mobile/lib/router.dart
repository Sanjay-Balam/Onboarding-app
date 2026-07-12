import 'package:go_router/go_router.dart';
import 'screens/auth/email_login_screen.dart';
import 'screens/auth/two_factor_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/staff_management_screen.dart';
import 'screens/admin/verification_queue_screen.dart';
import 'screens/admin/admin_profile_screen.dart';
import 'screens/chef/chef_dashboard_screen.dart';
import 'screens/chef/chef_onboarding_screen.dart';

// APIs not wired yet — routes are open. Auth redirect added at integration time.
final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const EmailLoginScreen()),
    GoRoute(path: '/2fa', builder: (_, __) => const TwoFactorScreen()),
    GoRoute(path: '/admin', builder: (_, __) => const AdminDashboardScreen()),
    GoRoute(path: '/admin/staff', builder: (_, __) => const StaffManagementScreen()),
    GoRoute(path: '/admin/kyc', builder: (_, __) => const VerificationQueueScreen()),
    GoRoute(path: '/admin/profile', builder: (_, __) => const AdminProfileScreen()),
    GoRoute(path: '/chef', builder: (_, __) => const ChefDashboardScreen()),
    GoRoute(path: '/chef/onboarding', builder: (_, __) => const ChefOnboardingScreen()),
  ],
);
