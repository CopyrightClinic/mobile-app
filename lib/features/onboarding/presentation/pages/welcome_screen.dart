import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:copyright_clinic_flutter/features/onboarding/presentation/widgets/onboarding_background.dart';
import 'package:copyright_clinic_flutter/core/constants/image_constants.dart';
import 'package:copyright_clinic_flutter/core/constants/dimensions.dart';
import 'package:copyright_clinic_flutter/core/widgets/global_image.dart';
import 'package:copyright_clinic_flutter/core/widgets/translated_text.dart';
import 'package:copyright_clinic_flutter/core/constants/app_strings.dart';
import 'package:copyright_clinic_flutter/core/utils/extensions/extensions.dart';
import 'package:copyright_clinic_flutter/config/routes/app_routes.dart';
import 'dart:ui';
import '../widgets/gradient_border_painter.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late List<Animation<double>> _staggerAnimations;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _staggerController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);

    _staggerAnimations = List.generate(
      6,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _staggerController, curve: Interval(index * 0.1, (index * 0.1) + 0.4, curve: Curves.easeOutBack))),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _staggerController, curve: Curves.easeOutCubic));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _staggerController.forward();
      }
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnboardingBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap24Px),
            child: AnimatedBuilder(
              animation: _staggerController,
              builder: (context, child) {
                return Column(
                  children: [
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.16),
                    Hero(tag: 'app_logo', child: GlobalImage(assetPath: ImageConstants.logo, width: 105.8.w)),
                    SizedBox(height: DimensionConstants.gap16Px.h),
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _staggerAnimations[0],
                        child: Column(
                          children: [
                            TranslatedText(
                              AppStrings.welcomeTo,
                              style: TextStyle(color: Colors.white, fontSize: DimensionConstants.font32Px.f, fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                            TranslatedText(
                              AppStrings.copyrightClinic,
                              style: TextStyle(color: Colors.white, fontSize: DimensionConstants.font32Px.f, fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    _buildAnimatedInfoButton(
                      animation: _staggerAnimations[1],
                      icon: Icons.info,
                      title: AppStrings.aboutUs,
                      onTap: () {
                        context.push(AppRoutes.aboutUsRouteName);
                      },
                    ),

                    SizedBox(height: DimensionConstants.gap16Px),

                    _buildAnimatedInfoButton(
                      animation: _staggerAnimations[2],
                      icon: Icons.lightbulb,
                      title: AppStrings.whatWeDo,
                      onTap: () {
                        context.push(AppRoutes.whatWeDoRouteName);
                      },
                    ),

                    SizedBox(height: DimensionConstants.gap16Px.h),

                    _buildAnimatedInfoButton(
                      animation: _staggerAnimations[3],
                      icon: Icons.auto_awesome,
                      title: AppStrings.askHaroldAI,
                      onTap: () {
                        context.push(AppRoutes.askHaroldAiRouteName);
                      },
                    ),

                    SizedBox(height: DimensionConstants.gap40Px.h),

                    FadeTransition(
                      opacity: _staggerAnimations[4],
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(_staggerAnimations[4]),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              context.push(AppRoutes.signupRouteName);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(vertical: DimensionConstants.gap16Px),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.r)),
                              elevation: 2,
                            ),
                            child: TranslatedText(
                              AppStrings.signUp,
                              style: TextStyle(fontSize: DimensionConstants.font16Px, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: DimensionConstants.gap20Px.h),

                    FadeTransition(
                      opacity: _staggerAnimations[5],
                      child: GestureDetector(
                        onTap: () {
                          context.push(AppRoutes.loginRouteName);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TranslatedText(
                              AppStrings.alreadyHaveAccount,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: DimensionConstants.font14Px),
                            ),
                            SizedBox(width: 4.w),
                            TranslatedText(
                              AppStrings.login,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: DimensionConstants.font14Px,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: DimensionConstants.gap10Px.h),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedInfoButton({
    required Animation<double> animation,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero).animate(animation),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
          child: SizedBox(
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                child: CustomPaint(
                  painter: WelcomeScreenGradientBorderPainter(backgroundColor: Colors.black.withValues(alpha: 0.5), borderRadius: 100.r),
                  child: ElevatedButton.icon(
                    onPressed: onTap,
                    icon: Icon(icon, color: Colors.white, size: DimensionConstants.font20Px.f),
                    label: TranslatedText(
                      title,
                      style: TextStyle(color: Colors.white, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w500),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: DimensionConstants.gap16Px.h, horizontal: DimensionConstants.gap20Px.w),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.r)),
                      elevation: 0,
                      side: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
