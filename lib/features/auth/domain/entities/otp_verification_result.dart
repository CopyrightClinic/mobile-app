import 'package:equatable/equatable.dart';

class OtpVerificationResult extends Equatable {
  final String message;
  final bool isValid;

  const OtpVerificationResult({required this.message, required this.isValid});

  @override
  List<Object?> get props => [message, isValid];
}
