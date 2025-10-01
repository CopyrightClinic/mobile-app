import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/utils/session_datetime_utils.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_back_button.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/widgets/global_image.dart';
import '../../../../core/widgets/custom_bottomsheet.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../core/utils/ui/snackbar_utils.dart';
import '../bloc/sessions_bloc.dart';
import '../bloc/sessions_event.dart';
import '../bloc/sessions_state.dart';
import 'params/session_details_screen_params.dart';

class SessionDetailsScreen extends StatefulWidget {
  final SessionDetailsScreenParams params;

  const SessionDetailsScreen({super.key, required this.params});

  @override
  State<SessionDetailsScreen> createState() => _SessionDetailsScreenState();
}

class _SessionDetailsScreenState extends State<SessionDetailsScreen> {
  late SessionsBloc _sessionsBloc;
  bool _isRatingExpanded = false;

  @override
  void initState() {
    super.initState();
    _sessionsBloc = context.read<SessionsBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionsBloc, SessionsState>(
      listener: (context, state) {
        if (state is SessionCancelled) {
          SnackBarUtils.showSuccess(context, AppStrings.sessionCancelledSuccessfully.tr());
          context.pop();
        } else if (state is SessionsError) {
          SnackBarUtils.showError(context, state.message);
        }
      },
      child: CustomScaffold(
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(
          leadingPadding: EdgeInsets.only(left: DimensionConstants.gap12Px.w),
          leading: const CustomBackButton(),
          centerTitle: true,
          title: TranslatedText(
            AppStrings.sessionDetailsTitle,
            style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w700),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: DimensionConstants.gap16Px.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap12Px.w, vertical: DimensionConstants.gap6Px.h),
                decoration: BoxDecoration(
                  color: widget.params.session.isUpcoming ? context.neonBlue.withAlpha(30) : context.neonGreen.withAlpha(30),
                  borderRadius: BorderRadius.circular(DimensionConstants.radius52Px.r),
                ),
                child: TranslatedText(
                  widget.params.session.isUpcoming ? AppStrings.upcoming : AppStrings.completed,
                  style: TextStyle(
                    color: widget.params.session.isUpcoming ? context.neonBlue : context.neonGreen,
                    fontSize: DimensionConstants.font12Px.f,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: DimensionConstants.gap24Px.h),
                        _buildSessionDetailsSection(),
                        if (widget.params.session.isCompleted) ...[
                          SizedBox(height: DimensionConstants.gap24Px.h),
                          _buildRatingReviewSection(),
                          SizedBox(height: DimensionConstants.gap24Px.h),
                          _buildSessionSummarySection(),
                        ] else ...[
                          SizedBox(height: DimensionConstants.gap24Px.h),
                          _buildNoteSection(),
                        ],
                        SizedBox(height: DimensionConstants.gap24Px.h),
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.params.session.isUpcoming) _buildActionButtons() else SizedBox(height: DimensionConstants.gap16Px.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionDetailsSection() {
    final session = widget.params.session;
    return Container(
      padding: EdgeInsets.all(DimensionConstants.gap16Px.w),
      decoration: BoxDecoration(color: context.filledBgDark, borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r)),
      child: Column(
        children: [
          Row(
            children: [
              GlobalImage(
                assetPath: ImageConstants.sessionTime,
                width: DimensionConstants.gap42Px.w,
                height: DimensionConstants.gap42Px.h,
                fit: BoxFit.contain,
                showLoading: false,
                showError: false,
                fadeIn: false,
              ),
              SizedBox(width: DimensionConstants.gap8Px.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      SessionDateTimeUtils.formatSessionDate(session.scheduledDateTime),
                      style: TextStyle(fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w600, color: context.darkTextPrimary),
                    ),
                    SizedBox(height: DimensionConstants.gap2Px.h),
                    Text(
                      '(${session.formattedDuration} ${AppStrings.session})',
                      style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary),
                    ).tr(),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: DimensionConstants.gap16Px.h),
          Row(
            children: [
              GlobalImage(
                assetPath: ImageConstants.sessionPrice,
                width: DimensionConstants.gap42Px.w,
                height: DimensionConstants.gap42Px.h,
                fit: BoxFit.contain,
                showLoading: false,
                showError: false,
                fadeIn: false,
              ),
              SizedBox(width: DimensionConstants.gap8Px.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.formattedHoldAmount,
                    style: TextStyle(fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w600, color: context.darkTextPrimary),
                  ),
                  SizedBox(height: DimensionConstants.gap2Px.h),
                  TranslatedText(
                    session.isCompleted ? AppStrings.charged : AppStrings.holdAmountChargedAfterSession,
                    style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: DimensionConstants.gap16Px.h),
          Row(
            children: [
              GlobalImage(
                assetPath: ImageConstants.mic,
                width: DimensionConstants.gap42Px.w,
                height: DimensionConstants.gap42Px.h,
                fit: BoxFit.contain,
                showLoading: false,
                showError: false,
                fadeIn: false,
              ),
              SizedBox(width: DimensionConstants.gap8Px.w),
              Expanded(
                child: TranslatedText(
                  AppStrings.recordingConsented,
                  style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingReviewSection() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isRatingExpanded = !_isRatingExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(DimensionConstants.gap16Px.w),
        decoration: BoxDecoration(color: context.filledBgDark, borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TranslatedText(
                  AppStrings.yourRatingAndReview,
                  style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: context.orange, size: DimensionConstants.gap16Px.w),
                    SizedBox(width: DimensionConstants.gap4Px.w),
                    Text(
                      '(4.0)',
                      style: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(width: DimensionConstants.gap8Px.w),
                    AnimatedRotation(
                      turns: _isRatingExpanded ? 0.0 : 0.5,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(Icons.keyboard_arrow_up, color: context.darkTextSecondary, size: DimensionConstants.gap20Px.w),
                    ),
                  ],
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: DimensionConstants.gap12Px.h),
                  Text(
                    'The attorney was very helpful and provided clear guidance on my legal question. Would definitely recommend!',
                    style: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              crossFadeState: _isRatingExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionSummarySection() {
    return Container(
      padding: EdgeInsets.all(DimensionConstants.gap24Px.w),
      decoration: BoxDecoration(color: context.filledBgDark, borderRadius: BorderRadius.circular(DimensionConstants.radius20Px.r)),
      child: Column(
        children: [
          GlobalImage(
            assetPath: ImageConstants.unlockSummary,
            width: DimensionConstants.gap40Px.w,
            height: DimensionConstants.gap40Px.h,
            fit: BoxFit.contain,
            showLoading: false,
            showError: false,
            fadeIn: false,
          ),
          SizedBox(height: DimensionConstants.gap16Px.h),
          TranslatedText(
            AppStrings.unlockWrittenSummary,
            style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: DimensionConstants.gap16Px.h),
          Container(
            width: double.infinity,
            height: 120.h,
            decoration: BoxDecoration(color: context.bgDark2, borderRadius: BorderRadius.circular(DimensionConstants.radius8Px.r)),
            child: Center(child: Icon(Icons.lock_outline, color: context.darkTextSecondary, size: DimensionConstants.gap32Px.w)),
          ),
          SizedBox(height: DimensionConstants.gap16Px.h),
          TranslatedText(
            AppStrings.payToRequestSummary,
            style: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: DimensionConstants.gap20Px.h),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              onPressed: () => _onUnlockSummary(),
              backgroundColor: context.primary,
              textColor: Colors.white,
              borderRadius: DimensionConstants.radius52Px.r,
              padding: 16.0,
              child: TranslatedText(
                AppStrings.unlockSummaryFor,
                style: TextStyle(fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection() {
    return Container(
      padding: EdgeInsets.all(DimensionConstants.gap16Px.w),
      decoration: BoxDecoration(color: context.filledBgDark, borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: context.orange, size: DimensionConstants.gap20Px.w),
          SizedBox(width: DimensionConstants.gap12Px.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TranslatedText(
                  AppStrings.note,
                  style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: DimensionConstants.gap8Px.h),
                TranslatedText(
                  AppStrings.paymentSecurityNote,
                  style: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.only(
        left: DimensionConstants.gap16Px.w,
        right: DimensionConstants.gap16Px.w,
        top: DimensionConstants.gap16Px.h,
        bottom: DimensionConstants.gap16Px.h + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(color: context.bottomNavBarBG),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: BlocBuilder<SessionsBloc, SessionsState>(
                  builder: (context, state) {
                    final session = widget.params.session;
                    final isLoading = state is SessionCancelLoading && state.sessionId == session.id;
                    return CustomButton(
                      onPressed: session.canCancel ? () => _showCancelDialog() : null,
                      backgroundColor: context.buttonSecondary,
                      disabledBackgroundColor: context.buttonDisabled,
                      textColor: context.darkTextPrimary,
                      borderRadius: DimensionConstants.radius52Px.r,
                      padding: 12.0,
                      isLoading: isLoading,
                      child: TranslatedText(
                        AppStrings.cancelSession,
                        style: TextStyle(
                          fontSize: DimensionConstants.font16Px.f,
                          fontWeight: FontWeight.w600,
                          color: session.canCancel ? context.darkTextPrimary : context.darkTextSecondary,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: DimensionConstants.gap12Px.w),
              Expanded(
                child: CustomButton(
                  onPressed: () => _onJoinSession(),
                  backgroundColor: context.primary,
                  textColor: Colors.white,
                  borderRadius: DimensionConstants.radius52Px.r,
                  padding: 12.0,
                  child: TranslatedText(
                    AppStrings.joinSession,
                    style: TextStyle(fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          if (widget.params.session.canCancel) ...[
            SizedBox(height: DimensionConstants.gap12Px.h),
            Text(
              '${AppStrings.youCanCancelTill.tr()} ${SessionDateTimeUtils.formatCancellationDeadline(widget.params.session.scheduledDateTime)}.',
              style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary),
              textAlign: TextAlign.center,
            ),
          ],
          if (!widget.params.session.canCancel) ...[
            SizedBox(height: DimensionConstants.gap12Px.h),
            TranslatedText(
              AppStrings.cancellationPeriodExpired,
              style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.red, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: DimensionConstants.gap4Px.h),
            Text(
              '${AppStrings.youCouldHaveCanceled.tr()} ${SessionDateTimeUtils.formatCancellationDeadline(widget.params.session.scheduledDateTime)}.',
              style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  void _showCancelDialog() {
    CustomBottomSheet.show(
      context: context,
      iconPath: ImageConstants.warning,
      title: AppStrings.cancelSessionTitle,
      subtitle: AppStrings.cancelSessionMessage,
      primaryButtonText: AppStrings.cancelSession,
      secondaryButtonText: AppStrings.keepSession,
      onPrimaryPressed: () {
        Navigator.of(context).pop();
        _onCancelSession();
      },
      onSecondaryPressed: () => Navigator.of(context).pop(),
      primaryButtonColor: context.red,
      primaryTextColor: Colors.white,
    );
  }

  void _onCancelSession() {
    _sessionsBloc.add(CancelSessionRequested(sessionId: widget.params.session.id, reason: AppStrings.userRequestedCancellation));
  }

  void _onJoinSession() {
    SnackBarUtils.showSuccess(context, AppStrings.joiningSession.tr());
  }

  void _onUnlockSummary() {
    // TODO: Implement unlock summary functionality
    SnackBarUtils.showSuccess(context, 'Summary unlock requested');
  }
}
