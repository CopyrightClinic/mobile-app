import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/global_image.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../sessions/domain/entities/session_entity.dart';
import '../../../sessions/presentation/widgets/session_card.dart';
import '../../../../core/utils/enumns/ui/session_status.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  SessionEntity get _dummySession => SessionEntity(
    id: '1',
    title: AppStrings.copyrightConsultation,
    scheduledDate: DateTime.now().add(const Duration(days: 2, hours: 15, minutes: 30)),
    duration: const Duration(minutes: 30),
    price: 99.00,
    status: SessionStatus.upcoming,
    description: AppStrings.copyrightConsultationSession,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  );

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: context.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: DimensionConstants.gap2Px.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TranslatedText(
                          AppStrings.welcome,
                          style: TextStyle(fontSize: DimensionConstants.font16Px.f, color: context.darkTextSecondary, fontWeight: FontWeight.w400),
                        ),
                        SizedBox(height: DimensionConstants.gap2Px.h),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            String userName = 'John Doe!';
                            if (state is AuthAuthenticated) {
                              userName = '${state.user.name ?? state.user.email.split('@').first}!';
                            }
                            return Text(
                              userName,
                              style: TextStyle(fontSize: DimensionConstants.font20Px.f, fontWeight: FontWeight.w700, color: context.darkTextPrimary),
                            );
                          },
                        ),
                      ],
                    ),
                    Container(
                      width: DimensionConstants.gap40Px.w,
                      height: DimensionConstants.gap40Px.w,
                      decoration: BoxDecoration(color: context.bgDark.withValues(alpha: 0.7), shape: BoxShape.circle),
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular((DimensionConstants.gap40Px.w / 2).w),
                        child: Center(
                          child: Icon(Icons.notifications_outlined, color: context.darkTextPrimary, size: (DimensionConstants.gap40Px * 0.5).w),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: DimensionConstants.gap32Px.h),

                Row(
                  children: [
                    Expanded(child: _buildActionBlock(context, icon: ImageConstants.aboutUs, title: AppStrings.aboutUs, onTap: () {})),
                    SizedBox(width: DimensionConstants.gap16Px.w),
                    Expanded(child: _buildActionBlock(context, icon: ImageConstants.whatWeDo, title: AppStrings.whatWeDo, onTap: () {})),
                  ],
                ),

                SizedBox(height: DimensionConstants.gap24Px.h),

                _buildHaroldAIBlock(context),

                SizedBox(height: DimensionConstants.gap32Px.h),

                TranslatedText(
                  AppStrings.upcomingSessions,
                  style: TextStyle(fontSize: DimensionConstants.font20Px.f, fontWeight: FontWeight.w700, color: context.darkTextPrimary),
                ),

                SizedBox(height: DimensionConstants.gap16Px.h),

                SessionCard(session: _dummySession, onCancel: () {}, onJoin: () {}),

                SizedBox(height: DimensionConstants.gap24Px.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBlock(BuildContext context, {required String icon, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(DimensionConstants.gap20Px.w),
        decoration: BoxDecoration(color: context.filledBgDark, borderRadius: BorderRadius.circular(DimensionConstants.radius20Px.r)),
        child: Column(
          children: [
            Container(
              width: DimensionConstants.gap48Px.w,
              height: DimensionConstants.gap48Px.h,
              decoration: BoxDecoration(color: context.white.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Center(
                child: GlobalImage(
                  assetPath: icon,
                  width: DimensionConstants.icon24Px.w,
                  height: DimensionConstants.icon24Px.h,
                  fit: BoxFit.contain,
                  showLoading: false,
                  showError: false,
                  fadeIn: false,
                ),
              ),
            ),
            SizedBox(height: DimensionConstants.gap12Px.h),
            TranslatedText(
              title,
              style: TextStyle(fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w700, color: context.darkTextPrimary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHaroldAIBlock(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w, vertical: DimensionConstants.gap20Px.h),
        decoration: BoxDecoration(color: context.filledBgDark, borderRadius: BorderRadius.circular(DimensionConstants.radius20Px.r)),
        child: Row(
          children: [
            Container(
              width: DimensionConstants.gap48Px.w,
              height: DimensionConstants.gap48Px.h,
              decoration: BoxDecoration(color: context.white.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Center(
                child: GlobalImage(
                  assetPath: ImageConstants.askHaroldAi,
                  width: DimensionConstants.icon24Px.w,
                  height: DimensionConstants.icon24Px.h,
                  fit: BoxFit.contain,
                  showLoading: false,
                  showError: false,
                  fadeIn: false,
                ),
              ),
            ),
            SizedBox(width: DimensionConstants.gap12Px.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText(
                    AppStrings.askHaroldAI,
                    style: TextStyle(fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w700, color: context.darkTextPrimary),
                  ),
                  SizedBox(height: DimensionConstants.gap2Px.h),
                  TranslatedText(
                    AppStrings.haroldWillHelpYou,
                    style: TextStyle(fontSize: DimensionConstants.font12Px.f, color: context.darkTextSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
