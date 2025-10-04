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
import '../../../../di.dart';
import '../../domain/entities/session_details_entity.dart';
import '../bloc/session_details_bloc.dart';
import '../bloc/session_details_event.dart';
import '../bloc/session_details_state.dart';
import '../bloc/sessions_bloc.dart';
import '../bloc/sessions_state.dart';
import '../widgets/add_rating_review_widget.dart';
import '../widgets/submitted_rating_review_widget.dart';
import 'params/session_details_screen_params.dart';

class SessionDetailsScreen extends StatelessWidget {
  final SessionDetailsScreenParams params;

  const SessionDetailsScreen({super.key, required this.params});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SessionDetailsBloc>()..add(LoadSessionDetails(sessionId: params.sessionId)),
      child: SessionDetailsView(sessionId: params.sessionId),
    );
  }
}

class SessionDetailsView extends StatefulWidget {
  final String sessionId;

  const SessionDetailsView({super.key, required this.sessionId});

  @override
  State<SessionDetailsView> createState() => _SessionDetailsViewState();
}

class _SessionDetailsViewState extends State<SessionDetailsView> {
  late final ValueNotifier<bool> _isRatingExpanded;
  double _currentRating = 0.0;
  String _currentReview = '';

  @override
  void initState() {
    super.initState();
    _isRatingExpanded = ValueNotifier<bool>(false);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SessionsBloc, SessionsState>(
          listener: (context, state) {
            if (state is SessionCancelled) {
              SnackBarUtils.showSuccess(context, AppStrings.sessionCancelledSuccessfully.tr());
              context.pop();
            } else if (state is SessionsError) {
              SnackBarUtils.showError(context, state.message);
            }
          },
        ),
        BlocListener<SessionDetailsBloc, SessionDetailsState>(
          listener: (context, state) {
            if (state is SessionDetailsCancelled) {
              SnackBarUtils.showSuccess(context, state.message);
              context.pop();
            } else if (state is SessionDetailsError) {
              SnackBarUtils.showError(context, state.message);
            } else if (state is SessionDetailsFeedbackSubmitted) {
              SnackBarUtils.showSuccess(context, state.message);
            }
          },
        ),
      ],
      child: BlocBuilder<SessionDetailsBloc, SessionDetailsState>(
        builder: (context, state) {
          if (state is SessionDetailsLoading) {
            return _buildLoadingScreen(context);
          } else if (state is SessionDetailsError) {
            return _buildErrorScreen(context, state.message);
          } else if (state is SessionDetailsLoaded || state is SessionDetailsCancelLoading || state is SessionDetailsFeedbackLoading) {
            final sessionDetails =
                state is SessionDetailsLoaded
                    ? state.sessionDetails
                    : state is SessionDetailsCancelLoading
                    ? state.sessionDetails
                    : (state as SessionDetailsFeedbackLoading).sessionDetails;
            return _buildSessionDetailsScreen(context, sessionDetails);
          } else {
            return _buildLoadingScreen(context);
          }
        },
      ),
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return CustomScaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        leadingPadding: EdgeInsets.only(left: DimensionConstants.gap12Px.w),
        leading: const CustomBackButton(),
        centerTitle: true,
        title: TranslatedText(
          AppStrings.sessionDetailsTitle,
          style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w700),
        ),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message) {
    return CustomScaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        leadingPadding: EdgeInsets.only(left: DimensionConstants.gap12Px.w),
        leading: const CustomBackButton(),
        centerTitle: true,
        title: TranslatedText(
          AppStrings.sessionDetailsTitle,
          style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w700),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: context.red),
            SizedBox(height: DimensionConstants.gap16Px.h),
            Text(message, style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font16Px.f), textAlign: TextAlign.center),
            SizedBox(height: DimensionConstants.gap16Px.h),
            CustomButton(
              onPressed: () => context.read<SessionDetailsBloc>().add(LoadSessionDetails(sessionId: widget.sessionId)),
              backgroundColor: context.primary,
              textColor: Colors.white,
              borderRadius: DimensionConstants.radius52Px.r,
              padding: 12.0,
              child: TranslatedText(
                AppStrings.retry,
                style: TextStyle(fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionDetailsScreen(BuildContext context, SessionDetailsEntity sessionDetails) {
    return CustomScaffold(
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
                color: sessionDetails.isUpcoming ? context.neonBlue.withAlpha(30) : context.neonGreen.withAlpha(30),
                borderRadius: BorderRadius.circular(DimensionConstants.radius52Px.r),
              ),
              child: TranslatedText(
                sessionDetails.isUpcoming ? AppStrings.upcoming : AppStrings.completed,
                style: TextStyle(
                  color: sessionDetails.isUpcoming ? context.neonBlue : context.neonGreen,
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
                      _buildSessionDetailsSection(sessionDetails),
                      if (sessionDetails.isCompleted) ...[
                        SizedBox(height: DimensionConstants.gap24Px.h),
                        _buildRatingReviewSection(sessionDetails),
                        SizedBox(height: DimensionConstants.gap24Px.h),
                        _buildSessionSummarySection(sessionDetails),
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
            if (sessionDetails.isUpcoming) _buildActionButtons(sessionDetails) else SizedBox(height: DimensionConstants.gap16Px.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionDetailsSection(SessionDetailsEntity session) {
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

  Widget _buildRatingReviewSection(SessionDetailsEntity session) {
    if (session.rating != null) {
      return SubmittedRatingReviewWidget(rating: session.rating!, review: session.review, isExpanded: _isRatingExpanded);
    } else {
      return AddRatingReviewWidget(
        onSubmit: () => _onSubmitRatingReview(session.id),
        onRatingChanged: (rating) {
          _currentRating = rating;
        },
        onReviewChanged: (review) {
          _currentReview = review;
        },
        isExpanded: _isRatingExpanded,
      );
    }
  }

  Widget _buildSessionSummarySection(SessionDetailsEntity session) {
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

  Widget _buildActionButtons(SessionDetailsEntity session) {
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
                child: BlocBuilder<SessionDetailsBloc, SessionDetailsState>(
                  builder: (context, state) {
                    final isLoading = state is SessionDetailsCancelLoading;
                    return CustomButton(
                      onPressed: (session.cancelTimeExpired == true) ? null : () => _showCancelDialog(session),
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
                          color: (session.cancelTimeExpired == true) ? context.darkTextSecondary : context.darkTextPrimary,
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
          if (session.cancelTimeExpired == false) ...[
            SizedBox(height: DimensionConstants.gap12Px.h),
            Text(
              '${AppStrings.youCanCancelTill.tr()} ${SessionDateTimeUtils.formatCancelTime(session.cancelTime)}.',
              style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary),
              textAlign: TextAlign.center,
            ),
          ],
          if (session.cancelTimeExpired == true) ...[
            SizedBox(height: DimensionConstants.gap12Px.h),
            TranslatedText(
              AppStrings.cancellationPeriodExpired,
              style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.red, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: DimensionConstants.gap4Px.h),
            Text(
              '${AppStrings.youCouldHaveCanceled.tr()} ${SessionDateTimeUtils.formatCancelTime(session.cancelTime)}.',
              style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  void _showCancelDialog(SessionDetailsEntity session) {
    CustomBottomSheet.show(
      context: context,
      iconPath: ImageConstants.warning,
      title: AppStrings.cancelSessionTitle,
      subtitle: AppStrings.cancelSessionMessage,
      primaryButtonText: AppStrings.cancelSession,
      secondaryButtonText: AppStrings.keepSession,
      onPrimaryPressed: () {
        Navigator.of(context).pop();
        _onCancelSession(session);
      },
      onSecondaryPressed: () => Navigator.of(context).pop(),
      primaryButtonColor: context.red,
      primaryTextColor: Colors.white,
    );
  }

  void _onCancelSession(SessionDetailsEntity session) {
    context.read<SessionDetailsBloc>().add(CancelSessionFromDetails(sessionId: session.id, reason: AppStrings.userRequestedCancellation));
  }

  void _onJoinSession() {
    SnackBarUtils.showSuccess(context, AppStrings.joiningSession.tr());
  }

  void _onUnlockSummary() {
    SnackBarUtils.showSuccess(context, AppStrings.summaryUnlockRequested.tr());
  }

  void _onSubmitRatingReview(String sessionId) {
    if (_currentRating > 0) {
      context.read<SessionDetailsBloc>().add(
        SubmitSessionFeedback(sessionId: sessionId, rating: _currentRating, review: _currentReview.isNotEmpty ? _currentReview : null),
      );
    }
  }

  @override
  void dispose() {
    _isRatingExpanded.dispose();
    super.dispose();
  }
}
