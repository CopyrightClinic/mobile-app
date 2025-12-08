import 'package:equatable/equatable.dart';

class UnlockSummaryResponseEntity extends Equatable {
  final bool success;
  final String message;
  final String paymentId;

  const UnlockSummaryResponseEntity({required this.success, required this.message, required this.paymentId});

  @override
  List<Object> get props => [success, message, paymentId];
}
