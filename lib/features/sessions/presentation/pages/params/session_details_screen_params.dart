import 'package:equatable/equatable.dart';

class SessionDetailsScreenParams extends Equatable {
  final String sessionId;

  const SessionDetailsScreenParams({required this.sessionId});

  @override
  List<Object> get props => [sessionId];

  Map<String, dynamic> toJson() => {'sessionId': sessionId};

  factory SessionDetailsScreenParams.fromJson(Map<String, dynamic> json) {
    return SessionDetailsScreenParams(sessionId: json['sessionId'] as String);
  }
}
