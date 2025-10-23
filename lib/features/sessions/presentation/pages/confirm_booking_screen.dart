import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/utils/timezone_helper.dart';
import '../../../../core/utils/session_datetime_utils.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_back_button.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/utils/ui/snackbar_utils.dart';
import '../../../payments/presentation/widgets/payment_method_card.dart';
import '../../../payments/presentation/widgets/payment_method_card_action.dart';
import '../bloc/sessions_bloc.dart';
import '../bloc/sessions_event.dart';
import '../bloc/sessions_state.dart';
import '../widgets/session_details_card.dart';
import 'params/confirm_booking_screen_params.dart';

class ConfirmBookingScreen extends StatefulWidget {
  final ConfirmBookingScreenParams params;

  const ConfirmBookingScreen({super.key, required this.params});

  @override
  State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  late SessionsBloc _sessionsBloc;

  @override
  void initState() {
    super.initState();
    _sessionsBloc = context.read<SessionsBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionsBloc, SessionsState>(
      listener: (context, state) {
        if (state.hasSuccess && state.lastOperation == SessionsOperation.scheduleSession) {
          context.go(AppRoutes.bookingRequestSentRouteName);
        } else if (state.hasError && state.lastOperation == SessionsOperation.scheduleSession) {
          SnackBarUtils.showError(context, state.errorMessage!);
        } else if (state.hasSuccess && state.lastOperation == SessionsOperation.bookSession && state.bookSessionResponse != null) {
          SnackBarUtils.showSuccess(context, AppStrings.sessionBookedSuccessfully.tr());
          context.go(AppRoutes.bookingRequestSentRouteName);
        } else if (state.hasError && state.lastOperation == SessionsOperation.bookSession) {
          SnackBarUtils.showError(context, state.errorMessage!);
        }
      },
      child: CustomScaffold(
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(
          leadingPadding: EdgeInsets.only(left: DimensionConstants.gap12Px.w),
          leading: const CustomBackButton(),
          centerTitle: true,
          title: TranslatedText(
            AppStrings.confirmYourBooking,
            style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: DimensionConstants.gap15Px.h),
                        _buildSubtitle(),
                        SizedBox(height: DimensionConstants.gap24Px.h),
                        _buildSessionDetailsSection(),
                        _buildPaymentSummarySection(),
                        _buildPaymentMethodSection(),

                        _buildNoteSection(),
                        SizedBox(height: DimensionConstants.gap24Px.h),
                      ],
                    ),
                  ),
                ),
              ),
              _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Align(
      alignment: Alignment.center,
      child: TranslatedText(
        AppStrings.pleaseReviewSessionDetails,
        style: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget _buildSessionDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TranslatedText(
          AppStrings.sessionDetails,
          style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font20Px.f, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: DimensionConstants.gap16Px.h),
        SessionDetailsCard(sessionDate: widget.params.sessionDate, timeSlot: widget.params.timeSlot),
      ],
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TranslatedText(
          AppStrings.paymentMethod,
          style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font20Px.f, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: DimensionConstants.gap16Px.h),
        PaymentMethodCard(paymentMethod: widget.params.paymentMethod, action: NoPaymentMethodAction(), isSelected: false),
        SizedBox(height: DimensionConstants.gap24Px.h),
      ],
    );
  }

  Widget _buildPaymentSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TranslatedText(
          AppStrings.paymentSummary,
          style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font20Px.f, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: DimensionConstants.gap16Px.h),
        Container(
          padding: EdgeInsets.all(DimensionConstants.gap16Px.w),
          decoration: BoxDecoration(color: context.filledBgDark, borderRadius: BorderRadius.circular(DimensionConstants.radius12Px.r)),
          child: Column(
            children: [
              _buildPaymentSummaryItem(AppStrings.holdAmount, AppStrings.holdAmountDescription),
              SizedBox(height: DimensionConstants.gap16Px.h),
              _buildPaymentSummaryItem(AppStrings.processingFee, AppStrings.processingFeeNonRefundable),
              SizedBox(height: DimensionConstants.gap16Px.h),
              Container(height: 1.h, color: context.darkTextSecondary.withOpacity(0.2)),
              SizedBox(height: DimensionConstants.gap16Px.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TranslatedText(
                    AppStrings.totalAmountLabel,
                    style: TextStyle(fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w700, color: context.darkTextPrimary),
                  ),
                  TranslatedText(
                    AppStrings.totalAmount,
                    style: TextStyle(fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w700, color: context.darkTextPrimary),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: DimensionConstants.gap24Px.h),
      ],
    );
  }

  Widget _buildPaymentSummaryItem(String amountKey, String descriptionKey) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TranslatedText(
              amountKey,
              style: TextStyle(fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600, color: context.darkTextPrimary),
            ),
            SizedBox(height: DimensionConstants.gap2Px.h),
            TranslatedText(descriptionKey, style: TextStyle(fontSize: DimensionConstants.font14Px.f, color: context.darkTextSecondary)),
          ],
        ),
      ],
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

  Widget _buildConfirmButton() {
    return Container(
      padding: EdgeInsets.only(left: DimensionConstants.gap16Px.w, right: DimensionConstants.gap16Px.w, top: DimensionConstants.gap10Px.h),
      child: BlocBuilder<SessionsBloc, SessionsState>(
        builder: (context, state) {
          final isLoading = state.isProcessingSchedule || state.isProcessingBook;
          return AuthButton(text: AppStrings.confirmAndBookSession, onPressed: _onConfirmBooking, isLoading: isLoading, isEnabled: true);
        },
      ),
    );
  }

  void _onConfirmBooking() async {
    final parsedTimeSlot = SessionDateTimeUtils.parseTimeSlot(widget.params.timeSlot);
    if (parsedTimeSlot == null) {
      return;
    }

    final formattedDate = SessionDateTimeUtils.formatDateToIso(widget.params.sessionDate);
    final summary = widget.params.query;
    final String timezone = await TimezoneHelper.getUserTimezone();

    _sessionsBloc.add(
      BookSessionRequested(
        stripePaymentMethodId: widget.params.paymentMethod.id,
        date: formattedDate,
        startTime: parsedTimeSlot.startTimeIso,
        endTime: parsedTimeSlot.endTimeIso,
        summary: summary,
        timezone: timezone,
      ),
    );
  }
}
