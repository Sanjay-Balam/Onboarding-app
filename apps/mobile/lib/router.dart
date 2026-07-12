import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'data/auth.dart';
import 'screens/auth/email_login_screen.dart';
import 'screens/auth/two_factor_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/staff_management_screen.dart';
import 'screens/admin/verification_queue_screen.dart';
import 'screens/admin/admin_profile_screen.dart';
import 'screens/chef/chef_dashboard_screen.dart';
import 'screens/chef/chef_attendance_screen.dart';
import 'screens/chef/chef_onboarding_screen.dart';

/// Router is driven by auth state: unauthenticated users can't reach app areas.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final user = ref.read(authProvider).user;
      final loggedIn = user != null;
      final loc = state.matchedLocation;
      final inAppArea = loc.startsWith('/admin') || loc.startsWith('/chef');
      final onAuthPage = loc == '/login' || loc == '/2fa';
      if (!loggedIn && inAppArea) return '/login';
      // Already authenticated but sitting on an auth page → go to role home.
      if (loggedIn && onAuthPage) return user.isAdmin ? '/admin' : '/chef';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const EmailLoginScreen()),
      GoRoute(path: '/2fa', builder: (_, __) => const TwoFactorScreen()),
      GoRoute(path: '/admin', builder: (_, __) => const AdminDashboardScreen()),
      GoRoute(path: '/admin/staff', builder: (_, __) => const StaffManagementScreen()),
      GoRoute(path: '/admin/kyc', builder: (_, __) => const VerificationQueueScreen()),
      GoRoute(path: '/admin/profile', builder: (_, __) => const AdminProfileScreen()),
      GoRoute(path: '/chef', builder: (_, __) => const ChefDashboardScreen()),
      GoRoute(path: '/chef/attendance', builder: (_, __) => const ChefAttendanceScreen()),
      GoRoute(path: '/chef/onboarding', builder: (_, __) => const ChefOnboardingScreen()),
    ],
  );
});

/// Bridges the Riverpod auth state to go_router's refresh mechanism.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}
