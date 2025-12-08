import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:copyright_clinic_flutter/core/constants/image_constants.dart';
import 'package:copyright_clinic_flutter/core/widgets/global_image.dart';
import 'package:copyright_clinic_flutter/core/widgets/translated_text.dart';
import 'package:copyright_clinic_flutter/core/constants/app_strings.dart';
import 'package:copyright_clinic_flutter/core/utils/extensions/responsive_extensions.dart';
import 'package:copyright_clinic_flutter/core/services/fcm_service.dart';
import 'package:copyright_clinic_flutter/core/services/push_notification_handler.dart';
import 'package:copyright_clinic_flutter/core/services/pending_navigation_service.dart';
import 'package:copyright_clinic_flutter/features/onboarding/presentation/widgets/onboarding_background.dart';
import 'package:copyright_clinic_flutter/config/routes/app_routes.dart';
import 'package:copyright_clinic_flutter/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:copyright_clinic_flutter/features/auth/presentation/bloc/auth_event.dart';
import 'package:copyright_clinic_flutter/features/auth/presentation/bloc/auth_state.dart';
import 'package:copyright_clinic_flutter/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:copyright_clinic_flutter/features/profile/presentation/bloc/profile_event.dart';
import 'package:copyright_clinic_flutter/di.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _checkAuthStatusAndNavigate();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);

    _scaleController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut));
  }

  void _startAnimations() {
    _scaleController.forward();
    _fadeController.forward();
  }

  void _checkAuthStatusAndNavigate() async {
    // Wait for animations to complete
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      // Check authentication status
      context.read<AuthBloc>().add(CheckAuthStatus());
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthAuthenticated) {
          sl<FCMService>().initialize();
          context.read<ProfileBloc>().add(const GetProfileRequested());

          final hasPendingNotification = PendingNavigationService().shouldSkipDefaultNavigation();

          if (hasPendingNotification) {
            await PushNotificationHandler().handlePendingNotificationIfExists();
          } else {
            if (mounted) {
              context.go(AppRoutes.homeRouteName);
            }
          }
        } else if (state is AuthUnauthenticated) {
          if (mounted) {
            context.go(AppRoutes.welcomeRouteName);
          }
        }
      },
      child: Scaffold(
        body: OnboardingBackground(
          child: Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(tag: 'app_logo', child: GlobalImage(assetPath: ImageConstants.logo, width: 105.8.w)),
                        SizedBox(height: 16.h),
                        Hero(
                          tag: 'app_name',
                          child: Material(
                            color: Colors.transparent,
                            child: TranslatedText(
                              AppStrings.appName,
                              style: TextStyle(color: Colors.white, fontSize: 24.f, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
