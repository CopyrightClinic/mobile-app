import 'package:equatable/equatable.dart';

class DeclineExtensionResponseEntity extends Equatable {
  final bool success;
  final String? message;

  const DeclineExtensionResponseEntity({this.success = true, this.message});

  @override
  List<Object?> get props => [success, message];
}
