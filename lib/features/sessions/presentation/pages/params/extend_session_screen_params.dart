import 'package:equatable/equatable.dart';

class ExtendSessionScreenParams extends Equatable {
  final String sessionId;
  final double totalFee;

  const ExtendSessionScreenParams({required this.sessionId, required this.totalFee});

  @override
  List<Object> get props => [sessionId, totalFee];

  Map<String, dynamic> toJson() => {'sessionId': sessionId, 'totalFee': totalFee};

  factory ExtendSessionScreenParams.fromJson(Map<String, dynamic> json) {
    return ExtendSessionScreenParams(sessionId: json['sessionId'] as String, totalFee: (json['totalFee'] as num).toDouble());
  }
}
