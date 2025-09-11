import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_back_button.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/utils/ui/snackbar_utils.dart';
import '../../../payments/domain/entities/payment_method_entity.dart';
import '../../../payments/presentation/widgets/payment_method_card.dart';
import '../bloc/sessions_bloc.dart';
import '../bloc/sessions_event.dart';
import '../bloc/sessions_state.dart';
import '../widgets/session_details_card.dart';

class ConfirmBookingScreen extends StatefulWidget {
  final DateTime sessionDate;
  final String timeSlot;
  final PaymentMethodEntity paymentMethod;

  const ConfirmBookingScreen({super.key, required this.sessionDate, required this.timeSlot, required this.paymentMethod});

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
        if (state is SessionScheduled) {
          SnackBarUtils.showSuccess(context, AppStrings.sessionScheduledSuccessfully);
          context.go(AppRoutes.homeRouteName);
        } else if (state is SessionScheduleError) {
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
            AppStrings.confirmYourBooking,
            style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: DimensionConstants.gap15Px.h),

                Align(
                  alignment: Alignment.center,
                  child: TranslatedText(
                    AppStrings.pleaseReviewSessionDetails,
                    style: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w400),
                  ),
                ),

                SizedBox(height: DimensionConstants.gap24Px.h),

                TranslatedText(
                  AppStrings.sessionDetails,
                  style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font20Px.f, fontWeight: FontWeight.w600),
                ),

                SizedBox(height: DimensionConstants.gap16Px.h),

                SessionDetailsCard(sessionDate: widget.sessionDate),

                TranslatedText(
                  AppStrings.paymentMethod,
                  style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font20Px.f, fontWeight: FontWeight.w600),
                ),

                SizedBox(height: DimensionConstants.gap16Px.h),

                PaymentMethodCard(paymentMethod: widget.paymentMethod, action: TapPaymentMethodAction(onTap: () {}), isSelected: false),

                Container(
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
                              style: TextStyle(
                                color: context.darkTextSecondary,
                                fontSize: DimensionConstants.font14Px.f,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                BlocBuilder<SessionsBloc, SessionsState>(
                  builder: (context, state) {
                    final isLoading = state is SessionScheduleLoading;

                    return AuthButton(text: AppStrings.confirmAndBookSession, onPressed: _onConfirmBooking, isLoading: isLoading, isEnabled: true);
                  },
                ),

                SizedBox(height: DimensionConstants.gap16Px.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onConfirmBooking() {
    _sessionsBloc.add(ScheduleSessionRequested(selectedDate: widget.sessionDate, selectedTimeSlot: widget.timeSlot));
  }
}
