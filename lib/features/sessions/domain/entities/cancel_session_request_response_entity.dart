import 'package:equatable/equatable.dart';

class CancelSessionRequestResponseEntity extends Equatable {
  final String? message;

  const CancelSessionRequestResponseEntity({this.message});

  @override
  List<Object?> get props => [message];
}
