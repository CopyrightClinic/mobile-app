import 'package:go_router/go_router.dart';
import '../../../features/onboarding/presentation/pages/about_us_screen.dart';
import '../../../features/onboarding/presentation/pages/splash_screen.dart';
import '../../../features/onboarding/presentation/pages/what_we_do_screen.dart';
import '../../../features/onboarding/presentation/pages/welcome_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/auth/presentation/signup_success_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splashRouteName,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(path: AppRoutes.splashRouteName, name: AppRoutes.splashRouteName, builder: (context, state) => const SplashScreen()),
      GoRoute(path: AppRoutes.welcomeRouteName, name: AppRoutes.welcomeRouteName, builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: AppRoutes.aboutUsRouteName, name: AppRoutes.aboutUsRouteName, builder: (context, state) => const AboutUsScreen()),
      GoRoute(path: AppRoutes.whatWeDoRouteName, name: AppRoutes.whatWeDoRouteName, builder: (context, state) => const WhatWeDoScreen()),
      GoRoute(path: AppRoutes.loginRouteName, name: AppRoutes.loginRouteName, builder: (context, state) => const LoginScreen()),
      GoRoute(path: AppRoutes.signupRouteName, name: AppRoutes.signupRouteName, builder: (context, state) => const SignUpScreen()),
      GoRoute(
        path: AppRoutes.signupSuccessRouteName,
        name: AppRoutes.signupSuccessRouteName,
        builder: (context, state) => const SignupSuccessScreen(),
      ),
    ],
  );
}
