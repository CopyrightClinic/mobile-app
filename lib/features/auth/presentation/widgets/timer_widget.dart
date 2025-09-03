import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/resend_otp_cubit.dart';

class TimerStarter extends StatefulWidget {
  final Widget child;

  const TimerStarter({super.key, required this.child});

  @override
  State<TimerStarter> createState() => _TimerStarterState();
}

class _TimerStarterState extends State<TimerStarter> {
  @override
  void initState() {
    super.initState();
    // Start the timer automatically when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ResendOtpCubit>().startResendTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
