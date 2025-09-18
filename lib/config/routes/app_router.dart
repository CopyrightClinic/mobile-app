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
import '../../features/sessions/presentation/pages/select_payment_method_screen.dart';
import '../../features/sessions/presentation/pages/confirm_booking_screen.dart';
import '../../features/sessions/presentation/pages/booking_request_sent_screen.dart';
import '../../features/harold_ai/presentation/pages/ask_harold_ai_screen.dart';
import '../../features/harold_ai/presentation/pages/harold_signup.dart';
import '../../features/harold_ai/presentation/pages/harold_success_screen.dart';
import '../../features/harold_ai/presentation/pages/harold_failed_screen.dart';
import '../../features/dashboard/presentation/pages/dashboard_shell_screen.dart';
import '../../features/dashboard/presentation/pages/home_screen.dart';
import '../../features/dashboard/presentation/pages/sessions_screen.dart';
import '../../features/dashboard/presentation/pages/profile_screen.dart';
import '../../features/sessions/presentation/pages/schedule_session_screen.dart';
import '../../core/utils/enumns/ui/verification_type.dart';
import '../../core/utils/enumns/ui/payment_method.dart';
import 'app_routes.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splashRouteName,
    debugLogDiagnostics: true,
    routes: [
      // Onboarding and Auth Routes
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
      GoRoute(
        path: AppRoutes.addPaymentMethodRouteName,
        name: AppRoutes.addPaymentMethodRouteName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          PaymentMethodFrom from = extra['from'] ?? PaymentMethodFrom.auth;
          return AddPaymentMethodScreen(from: from);
        },
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return DashboardShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.homeRouteName, name: AppRoutes.homeRouteName, builder: (context, state) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: AppRoutes.sessionsRouteName, name: AppRoutes.sessionsRouteName, builder: (context, state) => const SessionsScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.profileRouteName, name: AppRoutes.profileRouteName, builder: (context, state) => const ProfileScreen())],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.scheduleSessionRouteName,
        name: AppRoutes.scheduleSessionRouteName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final query = extra?['query'] as String?;
          return ScheduleSessionScreen(query: query);
        },
      ),
      GoRoute(
        path: AppRoutes.selectPaymentMethodRouteName,
        name: AppRoutes.selectPaymentMethodRouteName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final sessionDate = extra['sessionDate'] as DateTime;
          final timeSlot = extra['timeSlot'] as String;
          final query = extra['query'] as String?;
          return SelectPaymentMethodScreen(sessionDate: sessionDate, timeSlot: timeSlot, query: query);
        },
      ),
      GoRoute(
        path: AppRoutes.confirmBookingRouteName,
        name: AppRoutes.confirmBookingRouteName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final sessionDate = extra['sessionDate'] as DateTime;
          final timeSlot = extra['timeSlot'] as String;
          final paymentMethod = extra['paymentMethod'];
          final query = extra['query'] as String?;
          return ConfirmBookingScreen(sessionDate: sessionDate, timeSlot: timeSlot, paymentMethod: paymentMethod, query: query);
        },
      ),
      GoRoute(
        path: AppRoutes.bookingRequestSentRouteName,
        name: AppRoutes.bookingRequestSentRouteName,
        builder: (context, state) => const BookingRequestSentScreen(),
      ),
      GoRoute(path: AppRoutes.askHaroldAiRouteName, name: AppRoutes.askHaroldAiRouteName, builder: (context, state) => const AskHaroldAiScreen()),
      GoRoute(path: AppRoutes.haroldSignupRouteName, name: AppRoutes.haroldSignupRouteName, builder: (context, state) => const HaroldSignupScreen()),
      GoRoute(
        path: AppRoutes.haroldSuccessRouteName,
        name: AppRoutes.haroldSuccessRouteName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final fromAuthFlow = extra?['fromAuthFlow'] ?? false;
          final query = extra?['query'] as String?;
          return HaroldSuccessScreen(fromAuthFlow: fromAuthFlow, query: query);
        },
      ),
      GoRoute(
        path: AppRoutes.haroldFailedRouteName,
        name: AppRoutes.haroldFailedRouteName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final fromAuthFlow = extra?['fromAuthFlow'] ?? false;
          final query = extra?['query'] as String?;
          return HaroldFailedScreen(fromAuthFlow: fromAuthFlow, query: query);
        },
      ),
    ],
  );
}
