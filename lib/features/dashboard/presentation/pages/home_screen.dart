import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../payments/domain/entities/payment_method_entity.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(titleText: AppStrings.home.tr(), automaticallyImplyLeading: false),
      body: Padding(
        padding: EdgeInsets.all(DimensionConstants.gap24Px.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TranslatedText(
              AppStrings.welcomeBack,
              style: TextStyle(fontSize: DimensionConstants.font24Px.f, fontWeight: FontWeight.bold, color: context.darkTextPrimary),
            ),
            SizedBox(height: DimensionConstants.gap8Px.h),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                String userName = 'User';
                if (state is AuthAuthenticated) {
                  userName = state.user.name ?? state.user.email.split('@').first;
                }
                return TranslatedText(
                  userName,
                  style: TextStyle(fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w500, color: context.primary),
                );
              },
            ),
            SizedBox(height: DimensionConstants.gap32Px.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(DimensionConstants.gap20Px.w),
              decoration: BoxDecoration(
                color: context.filledBgDark,
                borderRadius: BorderRadius.circular(DimensionConstants.radius16Px.r),
                border: Border.all(color: context.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText(
                    AppStrings.upcomingSessions,
                    style: TextStyle(fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w600, color: context.darkTextPrimary),
                  ),
                  SizedBox(height: DimensionConstants.gap16Px.h),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: DimensionConstants.gap48Px.w, color: context.darkTextSecondary),
                        SizedBox(height: DimensionConstants.gap16Px.h),
                        TranslatedText(
                          AppStrings.noUpcomingSessions,
                          style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: DimensionConstants.gap24Px.h),

            AuthButton(
              text: AppStrings.askHaroldAI,
              onPressed: () {
                context.push(AppRoutes.askHaroldAiRouteName);
              },
            ),
          ],
        ),
      ),
    );
  }
}
