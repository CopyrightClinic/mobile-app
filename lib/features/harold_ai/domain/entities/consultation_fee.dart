import 'package:equatable/equatable.dart';

class ConsultationFee extends Equatable {
  final double sessionFee;
  final double processingFee;
  final double totalFee;
  final String currency;

  const ConsultationFee({required this.sessionFee, required this.processingFee, required this.totalFee, required this.currency});

  @override
  List<Object?> get props => [sessionFee, processingFee, totalFee, currency];

  @override
  String toString() {
    return 'ConsultationFee(sessionFee: $sessionFee, processingFee: $processingFee, totalFee: $totalFee, currency: $currency)';
  }

  ConsultationFee copyWith({double? sessionFee, double? processingFee, double? totalFee, String? currency}) {
    return ConsultationFee(
      sessionFee: sessionFee ?? this.sessionFee,
      processingFee: processingFee ?? this.processingFee,
      totalFee: totalFee ?? this.totalFee,
      currency: currency ?? this.currency,
    );
  }
}
