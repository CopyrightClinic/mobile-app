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
import '../bloc/sessions_bloc.dart';
import '../bloc/sessions_event.dart';
import '../bloc/sessions_state.dart';
import '../widgets/time_slot_widget.dart';
import '../widgets/day_selector_widget.dart';

class ScheduleSessionScreen extends StatefulWidget {
  const ScheduleSessionScreen({super.key});

  @override
  State<ScheduleSessionScreen> createState() => _ScheduleSessionScreenState();
}

class _ScheduleSessionScreenState extends State<ScheduleSessionScreen> {
  late SessionsBloc _sessionsBloc;

  @override
  void initState() {
    super.initState();
    _sessionsBloc = context.read<SessionsBloc>();
    _sessionsBloc.add(const InitializeScheduleSession());
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
                      onDateSelected: (date) {
                        _sessionsBloc.add(DateSelected(selectedDate: date));
                      },
                    ),

                    SizedBox(height: DimensionConstants.gap32Px.h),

                    TranslatedText(
                      AppStrings.availableTimeSlots,
                      style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font20Px.f, fontWeight: FontWeight.w600),
                    ),

                    SizedBox(height: DimensionConstants.gap20Px.h),

                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3.2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: scheduleState.availableTimeSlots.length,
                        itemBuilder: (context, index) {
                          final timeSlot = scheduleState.availableTimeSlots[index];
                          final isSelected = scheduleState.selectedTimeSlot == timeSlot['value'];

                          return TimeSlotWidget(
                            timeText: timeSlot['time']!,
                            isSelected: isSelected,
                            onTap: () {
                              _sessionsBloc.add(TimeSlotSelected(selectedTimeSlot: timeSlot['value']!));
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
      ),
    );
  }

  void _onContinueToPayment(ScheduleSessionState scheduleState) {
    if (scheduleState.selectedTimeSlot != null) {
      _sessionsBloc.add(ScheduleSessionRequested(selectedDate: scheduleState.selectedDate, selectedTimeSlot: scheduleState.selectedTimeSlot!));
    }
  }
}
