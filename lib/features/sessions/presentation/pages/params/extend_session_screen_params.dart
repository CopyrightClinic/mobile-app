import 'package:equatable/equatable.dart';

class ExtendSessionScreenParams extends Equatable {
  final String sessionId;

  const ExtendSessionScreenParams({required this.sessionId});

  @override
  List<Object> get props => [sessionId];

  Map<String, dynamic> toJson() => {'sessionId': sessionId};

  factory ExtendSessionScreenParams.fromJson(Map<String, dynamic> json) {
    return ExtendSessionScreenParams(sessionId: json['sessionId'] as String);
  }
}
