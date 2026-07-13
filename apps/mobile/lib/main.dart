import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/auth.dart';
import 'data/credentials_stub.dart' if (dart.library.html) 'data/credentials_web.dart';
import 'router.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initCookieJar(); // native: load persisted cookies before first request
  runApp(const ProviderScope(child: WhySoCreamyApp()));
}

class WhySoCreamyApp extends ConsumerWidget {
  const WhySoCreamyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Wait for session restore before mounting the router (avoids logout-on-refresh flicker).
    final boot = ref.watch(sessionRestoreProvider);
    final theme = AppTheme.light();
    return boot.when(
      loading: () => MaterialApp(theme: theme, debugShowCheckedModeBanner: false, home: const _Splash()),
      error: (_, __) => MaterialApp(theme: theme, debugShowCheckedModeBanner: false, home: const _Splash()),
      data: (_) => MaterialApp.router(
        title: 'Why So Creamy',
        debugShowCheckedModeBanner: false,
        theme: theme,
        routerConfig: ref.watch(routerProvider),
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
}
