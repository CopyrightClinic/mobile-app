import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_back_button.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/global_image.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../sessions/presentation/pages/params/schedule_session_screen_params.dart';
import 'params/harold_success_screen_params.dart';

class HaroldSuccessScreen extends StatelessWidget {
  final HaroldSuccessScreenParams params;

  const HaroldSuccessScreen({super.key, required this.params});

  void _handleBackPress(BuildContext context) {
    context.go(AppRoutes.homeRouteName);
  }

  void _handleScheduleAppointment(BuildContext context) {
    context.push(
      AppRoutes.scheduleSessionRouteName,
      extra: ScheduleSessionScreenParams(
        query: params.query ?? '',
        eligibilityCategory: params.eligibility?.category,
        eligibilitySummary: params.eligibility?.summary,
        eligibilityIsLegitimate: params.eligibility?.isLegitimate,
      ),
    );
  }

  String _getFormattedPrice() {
    if (params.fee != null) {
      final currency = params.fee!.currency == 'USD' ? '\$' : params.fee!.currency;
      return '$currency${params.fee!.totalFee.toStringAsFixed(2)}';
    }
    return '\$99';
  }

  String _getConsultationDescription(BuildContext context) {
    if (params.fee != null) {
      return tr(AppStrings.haroldConsultationDescriptionDynamic, namedArgs: {'totalFee': _getFormattedPrice()});
    }
    return tr(AppStrings.haroldConsultationDescription);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        leadingPadding: EdgeInsets.only(left: DimensionConstants.gap12Px.w),
        leading: CustomBackButton(onPressed: () => _handleBackPress(context)),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GlobalImage(assetPath: ImageConstants.haroldSuccess, width: 200.w, height: 330.h, fit: BoxFit.contain),
                      SizedBox(height: DimensionConstants.gap26Px.h),
                      TranslatedText(
                        AppStrings.haroldCanConnectYou,
                        style: TextStyle(
                          color: context.darkTextPrimary,
                          fontSize: DimensionConstants.font24Px.f,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: DimensionConstants.gap12Px.h),
                      Text(
                        _getConsultationDescription(context),
                        style: TextStyle(
                          color: context.darkTextPrimary,
                          fontSize: DimensionConstants.font14Px.f,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if ((params.query ?? '').trim().isNotEmpty) ...[
                        SizedBox(height: DimensionConstants.gap20Px.h),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TranslatedText(
                            AppStrings.haroldSuccessOriginalInputLabel,
                            style: TextStyle(
                              color: context.darkTextSecondary,
                              fontSize: DimensionConstants.font12Px.f,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: DimensionConstants.gap8Px.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(DimensionConstants.gap14Px.w),
                          decoration: BoxDecoration(
                            color: context.filledBgDark,
                            borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r),
                          ),
                          child: Text(
                            params.query!.trim(),
                            style: TextStyle(
                              color: context.darkTextPrimary,
                              fontSize: DimensionConstants.font14Px.f,
                              fontWeight: FontWeight.w400,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              AuthButton(
                text: AppStrings.scheduleAppointment,
                onPressed: () => _handleScheduleAppointment(context),
                isLoading: false,
                isEnabled: true,
              ),
              SizedBox(height: DimensionConstants.gap10Px.h),
            ],
          ),
        ),
      ),
    );
  }
}
