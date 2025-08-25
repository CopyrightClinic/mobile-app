import 'package:go_router/go_router.dart';
import '../../../features/onboarding/presentation/pages/splash_screen.dart';
import '../../../features/onboarding/presentation/pages/welcome_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splashRouteName,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(path: AppRoutes.splashRouteName, name: AppRoutes.splashRouteName, builder: (context, state) => const SplashScreen()),
      GoRoute(path: AppRoutes.welcomeRouteName, name: AppRoutes.welcomeRouteName, builder: (context, state) => const WelcomeScreen()),
    ],
  );
}
