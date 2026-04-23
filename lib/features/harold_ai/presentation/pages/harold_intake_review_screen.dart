import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/utils/ui/snackbar_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_back_button.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../di.dart';
import '../../domain/usecases/check_harold_eligibility_usecase.dart';
import 'params/harold_failed_screen_params.dart';
import 'params/harold_intake_review_screen_params.dart';
import 'params/harold_success_screen_params.dart';

class HaroldIntakeReviewScreen extends StatefulWidget {
  final HaroldIntakeReviewScreenParams params;

  const HaroldIntakeReviewScreen({super.key, required this.params});

  @override
  State<HaroldIntakeReviewScreen> createState() => _HaroldIntakeReviewScreenState();
}

class _HaroldIntakeReviewScreenState extends State<HaroldIntakeReviewScreen> {
  bool _submitting = false;

  void _popToEditFromStart() {
    context.pop(kHaroldIntakeReviewPopEditFromStart);
  }

  Future<void> _onSubmit() async {
    final evalId = widget.params.evaluationId;
    if (evalId == null || evalId.isEmpty) {
      SnackBarUtils.showError(context, AppStrings.haroldEvaluationIdMissing.tr());
      return;
    }

    setState(() => _submitting = true);
    try {
      final result = await sl<CheckHaroldEligibilityUseCase>()(
        CheckHaroldEligibilityParams(evaluationId: evalId, answersPayload: widget.params.eligibilityPayload),
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          SnackBarUtils.showError(context, failure.message ?? AppStrings.unexpectedErrorOccurred.tr());
        },
        (eligibility) {
          final cat = eligibility.category.trim().toUpperCase();
          if (cat == 'B') {
            context.go(
              AppRoutes.haroldFailedRouteName,
              extra: HaroldFailedScreenParams(
                fromAuthFlow: widget.params.fromAuthFlow,
                query: widget.params.query,
                overrideMessageKey: AppStrings.haroldEligibilityCategoryBMessage,
              ),
            );
          } else if (cat == 'A' || cat == 'C') {
            context.pushReplacement(
              AppRoutes.haroldSuccessRouteName,
              extra: HaroldSuccessScreenParams(
                fromAuthFlow: widget.params.fromAuthFlow,
                query: widget.params.query,
                fee: widget.params.fee,
                eligibility: eligibility,
              ),
            );
          } else {
            SnackBarUtils.showError(context, AppStrings.unexpectedErrorOccurred.tr());
          }
        },
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        color: context.darkTextSecondary,
        fontSize: DimensionConstants.font13Px.f,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _queryCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w, vertical: DimensionConstants.gap16Px.h),
      decoration: BoxDecoration(
        color: context.filledBgDark,
        borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r),
        border: Border.all(color: context.darkTextPrimary.withValues(alpha: 0.08)),
      ),
      child: Text(
        widget.params.query,
        style: TextStyle(
          color: context.darkTextPrimary,
          fontSize: DimensionConstants.font16Px.f,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _qaCard(BuildContext context, int index, HaroldIntakeReviewRow row) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: DimensionConstants.gap14Px.h),
      padding: EdgeInsets.all(DimensionConstants.gap16Px.w),
      decoration: BoxDecoration(
        color: context.filledBgDark,
        borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r),
        border: Border.all(color: context.darkTextPrimary.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                width: 28.w,
                height: 28.h,
                decoration: BoxDecoration(
                  color: context.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(DimensionConstants.radius8Px.r),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: context.primary,
                    fontSize: DimensionConstants.font14Px.f,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: DimensionConstants.gap12Px.w),
              Expanded(
                child: Text(
                  row.question,
                  style: TextStyle(
                    color: context.darkTextPrimary,
                    fontSize: DimensionConstants.font16Px.f,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 28.w + DimensionConstants.gap12Px.w, top: DimensionConstants.gap12Px.h),
            child: Text(
              row.answer,
              style: TextStyle(
                color: context.darkTextPrimary.withValues(alpha: 0.92),
                fontSize: DimensionConstants.font16Px.f,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        leadingPadding: EdgeInsets.only(left: DimensionConstants.gap12Px.w),
        leading: CustomBackButton(onPressed: _popToEditFromStart),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: DimensionConstants.gap12Px.h),
              TranslatedText(
                AppStrings.haroldIntakeReviewTitle,
                style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font24Px.f, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: DimensionConstants.gap6Px.h),
              Text(
                AppStrings.haroldIntakeReviewSubtitle.tr(),
                style: TextStyle(
                  color: context.darkTextSecondary,
                  fontSize: DimensionConstants.font14Px.f,
                  fontWeight: FontWeight.w400,
                  height: 1.35,
                ),
              ),
              SizedBox(height: DimensionConstants.gap20Px.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _sectionLabel(context, AppStrings.haroldSuccessOriginalInputLabel.tr()),
                      SizedBox(height: DimensionConstants.gap10Px.h),
                      _queryCard(context),
                      SizedBox(height: DimensionConstants.gap24Px.h),
                      Divider(height: 1, thickness: 1, color: context.darkTextPrimary.withValues(alpha: 0.1)),
                      SizedBox(height: DimensionConstants.gap20Px.h),
                      TranslatedText(
                        AppStrings.haroldIntakeReviewAnswersHeading,
                        style: TextStyle(
                          color: context.darkTextPrimary,
                          fontSize: DimensionConstants.font18Px.f,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: DimensionConstants.gap16Px.h),
                      for (var i = 0; i < widget.params.rows.length; i++) _qaCard(context, i, widget.params.rows[i]),
                      SizedBox(height: DimensionConstants.gap8Px.h),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: DimensionConstants.gap8Px.w),
                      child: OutlinedButton(
                        onPressed: _submitting ? null : _popToEditFromStart,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.darkTextPrimary,
                          side: BorderSide(color: context.darkTextPrimary.withValues(alpha: 0.25)),
                          padding: EdgeInsets.symmetric(vertical: DimensionConstants.gap14Px.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.r)),
                        ),
                        child: TranslatedText(
                          AppStrings.haroldIntakeEdit,
                          style: TextStyle(fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: DimensionConstants.gap8Px.w),
                      child: AuthButton(
                        text: AppStrings.submit,
                        onPressed: _submitting ? null : _onSubmit,
                        isLoading: _submitting,
                        isEnabled: !_submitting,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: DimensionConstants.gap10Px.h),
            ],
          ),
        ),
      ),
    );
  }
}
