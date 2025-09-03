import 'package:equatable/equatable.dart';

abstract class ResendOtpState extends Equatable {
  const ResendOtpState();

  @override
  List<Object?> get props => [];
}

class ResendOtpInitial extends ResendOtpState {}

class ResendOtpTimerRunning extends ResendOtpState {
  final int remainingSeconds;

  const ResendOtpTimerRunning(this.remainingSeconds);

  @override
  List<Object?> get props => [remainingSeconds];
}

class ResendOtpTimerCompleted extends ResendOtpState {}
