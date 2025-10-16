import 'package:equatable/equatable.dart';

class CancelSessionSessionEntity extends Equatable {
  final String id;
  final String status;
  final String cancelledBy;
  final String cancellationReason;

  const CancelSessionSessionEntity({required this.id, required this.status, required this.cancelledBy, required this.cancellationReason});

  @override
  List<Object?> get props => [id, status, cancelledBy, cancellationReason];
}

class CancelSessionResponseEntity extends Equatable {
  final String message;
  final int status;
  final CancelSessionSessionEntity session;

  const CancelSessionResponseEntity({required this.message, required this.status, required this.session});

  @override
  List<Object?> get props => [message, status, session];
}
