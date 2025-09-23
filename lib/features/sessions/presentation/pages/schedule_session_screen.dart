import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/utils/timezone_helper.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_back_button.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../bloc/sessions_bloc.dart';
import '../bloc/sessions_event.dart';
import '../bloc/sessions_state.dart';
import '../widgets/time_slot_widget.dart';
import '../widgets/day_selector_widget.dart';
import 'params/schedule_session_screen_params.dart';
import 'params/select_payment_method_screen_params.dart';

class ScheduleSessionScreen extends StatefulWidget {
  final ScheduleSessionScreenParams params;

  const ScheduleSessionScreen({super.key, required this.params});

  @override
  State<ScheduleSessionScreen> createState() => _ScheduleSessionScreenState();
}

class _ScheduleSessionScreenState extends State<ScheduleSessionScreen> {
  late SessionsBloc _sessionsBloc;

  @override
  void initState() {
    super.initState();
    _sessionsBloc = context.read<SessionsBloc>();
    if (!_sessionsBloc.isClosed) {
      _sessionsBloc.add(const InitializeScheduleSession());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        leadingPadding: EdgeInsets.only(left: DimensionConstants.gap12Px.w),
        leading: const CustomBackButton(),
        centerTitle: true,
        title: TranslatedText(
          AppStrings.bookSession,
          style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<SessionsBloc, SessionsState>(
          builder: (context, state) {
            if (state is! ScheduleSessionState) {
              return const Center(child: CircularProgressIndicator());
            }

            final scheduleState = state;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: DimensionConstants.gap15Px.h),

                  TranslatedText(
                    AppStrings.chooseTimeFor30MinSession,
                    style: TextStyle(color: context.darkTextSecondary, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w400),
                  ),

                  SizedBox(height: DimensionConstants.gap20Px.h),

                  DaySelectorWidget(
                    selectedDate: scheduleState.selectedDate,
                    availableDays: scheduleState.availableDays,
                    onDateSelected: (date) {
                      if (!_sessionsBloc.isClosed) {
                        _sessionsBloc.add(DateSelected(selectedDate: date));
                      }
                    },
                  ),

                  SizedBox(height: DimensionConstants.gap32Px.h),

                  TranslatedText(
                    AppStrings.availableTimeSlots,
                    style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font20Px.f, fontWeight: FontWeight.w600),
                  ),

                  SizedBox(height: DimensionConstants.gap20Px.h),

                  Expanded(
                    child:
                        scheduleState.isLoadingAvailability
                            ? const TimeSlotGridShimmer()
                            : scheduleState.errorMessage != null
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline, size: 48.w, color: context.red),
                                  SizedBox(height: DimensionConstants.gap16Px.h),
                                  Text(
                                    scheduleState.errorMessage!,
                                    style: TextStyle(color: context.red, fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: DimensionConstants.gap16Px.h),
                                  AuthButton(
                                    text: AppStrings.retry,
                                    onPressed: () async {
                                      if (!_sessionsBloc.isClosed) {
                                        final String currentTimeZone = await TimezoneHelper.getUserTimezone();
                                        _sessionsBloc.add(LoadSessionAvailability(timezone: currentTimeZone));
                                      }
                                    },
                                    isLoading: false,
                                    isEnabled: true,
                                  ),
                                ],
                              ),
                            )
                            : scheduleState.availableTimeSlotsForSelectedDate.isEmpty
                            ? EmptyStateWidget(
                              title: AppStrings.noTimeSlotsAvailable,
                              subtitle: AppStrings.noTimeSlotsForSelectedDate,
                              icon: Icons.access_time_outlined,
                              iconColor: context.darkTextSecondary,
                              action: Container(
                                padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w, vertical: DimensionConstants.gap8Px.h),
                                decoration: BoxDecoration(
                                  color: context.filledBgDark,
                                  borderRadius: BorderRadius.circular(DimensionConstants.radius8Px.r),
                                  border: Border.all(color: context.darkTextSecondary.withAlpha(20)),
                                ),
                                child: TranslatedText(
                                  AppStrings.trySelectingDifferentDate,
                                  style: TextStyle(
                                    color: context.darkTextSecondary,
                                    fontSize: DimensionConstants.font14Px.f,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            : GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 3.2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: scheduleState.availableTimeSlotsForSelectedDate.length,
                              itemBuilder: (context, index) {
                                final timeSlot = scheduleState.availableTimeSlotsForSelectedDate[index];
                                final timeSlotKey = '${timeSlot.start.toIso8601String()}-${timeSlot.end.toIso8601String()}';
                                final isSelected = scheduleState.selectedTimeSlot == timeSlotKey;

                                return TimeSlotWidget(
                                  timeText: timeSlot.formattedTime,
                                  isSelected: isSelected,
                                  onTap: () {
                                    log('Selected time slot: $timeSlotKey');
                                    if (!_sessionsBloc.isClosed) {
                                      _sessionsBloc.add(TimeSlotSelected(selectedTimeSlot: timeSlotKey));
                                    }
                                  },
                                );
                              },
                            ),
                  ),

                  BlocBuilder<SessionsBloc, SessionsState>(
                    builder: (context, buttonState) {
                      final isLoading = buttonState is SessionScheduleLoading;

                      return AuthButton(
                        text: AppStrings.continueToPayment,
                        onPressed: scheduleState.canContinueToPayment ? () => _onContinueToPayment(scheduleState) : null,
                        isLoading: isLoading,
                        isEnabled: scheduleState.canContinueToPayment,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _onContinueToPayment(ScheduleSessionState scheduleState) {
    if (scheduleState.selectedTimeSlot != null) {
      context.push(
        AppRoutes.selectPaymentMethodRouteName,
        extra: SelectPaymentMethodScreenParams(
          sessionDate: scheduleState.selectedDate,
          timeSlot: scheduleState.selectedTimeSlot!,
          query: widget.params.query,
        ),
      );
    }
  }
}
