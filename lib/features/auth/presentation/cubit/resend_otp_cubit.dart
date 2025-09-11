import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'resend_otp_state.dart';

class ResendOtpCubit extends Cubit<ResendOtpState> {
  static const int _timerDuration = 60; // 60 seconds
  Timer? _timer;
  int _remainingSeconds = _timerDuration;

  ResendOtpCubit() : super(ResendOtpInitial());

  bool get canResend => _remainingSeconds == 0;

  String get formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void startResendTimer() {
    if (_timer?.isActive == true) return;

    _remainingSeconds = _timerDuration;
    emit(ResendOtpTimerRunning(_remainingSeconds));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        emit(ResendOtpTimerRunning(_remainingSeconds));
      } else {
        _timer?.cancel();
        emit(ResendOtpTimerCompleted());
      }
    });
  }

  void resetTimer() {
    _timer?.cancel();
    _remainingSeconds = 0;
    emit(ResendOtpTimerCompleted());
  }

  void stopTimer() {
    _timer?.cancel();
    emit(ResendOtpTimerCompleted());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
