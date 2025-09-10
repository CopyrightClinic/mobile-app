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
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  late SessionsBloc _sessionsBloc;

  final List<Map<String, String>> _timeSlots = [
    {'time': '9:00 AM – 9:30 AM', 'value': '09:00-09:30'},
    {'time': '10:30 AM – 11:00 AM', 'value': '10:30-11:00'},
    {'time': '2:00 PM – 2:30 PM', 'value': '14:00-14:30'},
    {'time': '3:00 PM – 3:30 PM', 'value': '15:00-15:30'},
  ];

  @override
  void initState() {
    super.initState();
    _sessionsBloc = context.read<SessionsBloc>();
    _selectedDate = _getNextWeekday(DateTime.now(), 1);
  }

  DateTime _getNextWeekday(DateTime date, int weekday) {
    final daysUntilWeekday = (weekday - date.weekday) % 7;
    return date.add(Duration(days: daysUntilWeekday == 0 ? 0 : daysUntilWeekday));
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
          child: Padding(
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
                  selectedDate: _selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                      _selectedTimeSlot = null;
                    });
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
                    itemCount: _timeSlots.length,
                    itemBuilder: (context, index) {
                      final timeSlot = _timeSlots[index];
                      final isSelected = _selectedTimeSlot == timeSlot['value'];

                      return TimeSlotWidget(
                        timeText: timeSlot['time']!,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedTimeSlot = timeSlot['value'];
                          });
                        },
                      );
                    },
                  ),
                ),

                BlocBuilder<SessionsBloc, SessionsState>(
                  builder: (context, state) {
                    final isLoading = state is SessionScheduleLoading;

                    return AuthButton(
                      text: AppStrings.continueToPayment,
                      onPressed: _selectedTimeSlot != null ? _onContinueToPayment : null,
                      isLoading: isLoading,
                      isEnabled: _selectedTimeSlot != null,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onContinueToPayment() {
    if (_selectedTimeSlot != null) {
      _sessionsBloc.add(ScheduleSessionRequested(selectedDate: _selectedDate, selectedTimeSlot: _selectedTimeSlot!));
    }
  }
}
