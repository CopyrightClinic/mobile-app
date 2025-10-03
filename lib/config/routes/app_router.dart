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
import '../../features/payments/presentation/pages/payment_methods_screen.dart';
import '../../features/sessions/presentation/pages/params/schedule_session_screen_params.dart';
import '../../features/sessions/presentation/pages/select_payment_method_screen.dart';
import '../../features/sessions/presentation/pages/confirm_booking_screen.dart';
import '../../features/sessions/presentation/pages/booking_request_sent_screen.dart';
import '../../features/harold_ai/presentation/pages/ask_harold_ai_screen.dart';
import '../../features/harold_ai/presentation/pages/harold_signup.dart';
import '../../features/harold_ai/presentation/pages/harold_success_screen.dart';
import '../../features/harold_ai/presentation/pages/harold_failed_screen.dart';
import '../../features/harold_ai/presentation/pages/params/harold_success_screen_params.dart';
import '../../features/harold_ai/presentation/pages/params/harold_failed_screen_params.dart';
import '../../features/sessions/presentation/pages/params/select_payment_method_screen_params.dart';
import '../../features/sessions/presentation/pages/params/confirm_booking_screen_params.dart';
import '../../features/dashboard/presentation/pages/dashboard_shell_screen.dart';
import '../../features/dashboard/presentation/pages/home_screen.dart';
import '../../features/dashboard/presentation/pages/sessions_screen.dart';
import '../../features/dashboard/presentation/pages/profile_screen.dart';
import '../../features/sessions/presentation/pages/schedule_session_screen.dart';
import '../../features/profile/presentation/pages/edit_profile_screen.dart';
import '../../features/profile/presentation/pages/change_password_screen.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../core/utils/enumns/ui/verification_type.dart';
import '../../core/utils/enumns/ui/payment_method.dart';
import '../../features/notifications/presentation/pages/notifications_screen.dart';
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
          final extra = state.extra as ScheduleSessionScreenParams;
          return ScheduleSessionScreen(params: extra);
        },
      ),
      GoRoute(
        path: AppRoutes.selectPaymentMethodRouteName,
        name: AppRoutes.selectPaymentMethodRouteName,
        builder: (context, state) {
          final params = state.extra as SelectPaymentMethodScreenParams;
          return SelectPaymentMethodScreen(params: params);
        },
      ),
      GoRoute(
        path: AppRoutes.confirmBookingRouteName,
        name: AppRoutes.confirmBookingRouteName,
        builder: (context, state) {
          final params = state.extra as ConfirmBookingScreenParams;
          return ConfirmBookingScreen(params: params);
        },
      ),
      GoRoute(
        path: AppRoutes.bookingRequestSentRouteName,
        name: AppRoutes.bookingRequestSentRouteName,
        builder: (context, state) => const BookingRequestSentScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfileRouteName,
        name: AppRoutes.editProfileRouteName,
        builder: (context, state) {
          final user = state.extra as UserEntity;
          return EditProfileScreen(user: user);
        },
      ),
      GoRoute(
        path: AppRoutes.changePasswordRouteName,
        name: AppRoutes.changePasswordRouteName,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.paymentMethodsRouteName,
        name: AppRoutes.paymentMethodsRouteName,
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
      GoRoute(path: AppRoutes.askHaroldAiRouteName, name: AppRoutes.askHaroldAiRouteName, builder: (context, state) => const AskHaroldAiScreen()),
      GoRoute(path: AppRoutes.haroldSignupRouteName, name: AppRoutes.haroldSignupRouteName, builder: (context, state) => const HaroldSignupScreen()),
      GoRoute(
        path: AppRoutes.haroldSuccessRouteName,
        name: AppRoutes.haroldSuccessRouteName,
        builder: (context, state) {
          final params = state.extra as HaroldSuccessScreenParams;
          return HaroldSuccessScreen(params: params);
        },
      ),
      GoRoute(
        path: AppRoutes.haroldFailedRouteName,
        name: AppRoutes.haroldFailedRouteName,
        builder: (context, state) {
          final params = state.extra as HaroldFailedScreenParams;
          return HaroldFailedScreen(params: params);
        },
      ),
      GoRoute(
        path: AppRoutes.notificationsRouteName,
        name: AppRoutes.notificationsRouteName,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
}
