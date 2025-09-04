import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../features/onboarding/presentation/pages/about_us_screen.dart';
import '../../../features/onboarding/presentation/pages/splash_screen.dart';
import '../../../features/onboarding/presentation/pages/what_we_do_screen.dart';
import '../../../features/onboarding/presentation/pages/welcome_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/auth/presentation/signup_success_screen.dart';
import '../../features/auth/presentation/password_signup_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/auth/presentation/complete_profile_screen.dart';
import '../../features/auth/presentation/unified_verification_screen.dart';
import '../../features/payments/presentation/pages/add_payment_method_screen.dart';
import '../../features/payments/presentation/bloc/payment_bloc.dart';
import '../../core/utils/enumns/ui/verification_type.dart';
import '../../di.dart';
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
      GoRoute(
        path: AppRoutes.passwordSignupRouteName,
        name: AppRoutes.passwordSignupRouteName,
        builder: (context, state) {
          final email = state.extra as String;
          return PasswordSignupScreen(email: email);
        },
      ),

      GoRoute(
        path: AppRoutes.verifyCodeRouteName,
        name: AppRoutes.verifyCodeRouteName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          String email = extra['email'] ?? '';
          VerificationType verificationType = extra['verificationType'] ?? VerificationType.emailVerification;
          return UnifiedVerificationScreen(email: email, verificationType: verificationType);
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPasswordRouteName,
        name: AppRoutes.forgotPasswordRouteName,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPasswordRouteName,
        name: AppRoutes.resetPasswordRouteName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          String email = extra['email'] ?? '';
          String otp = extra['otp'] ?? '';
          return ResetPasswordScreen(email: email, otp: otp);
        },
      ),
      GoRoute(
        path: AppRoutes.completeProfileRouteName,
        name: AppRoutes.completeProfileRouteName,
        builder: (context, state) => const CompleteProfileScreen(),
      ),
    ],
  );
}
