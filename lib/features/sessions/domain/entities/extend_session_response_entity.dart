import 'package:equatable/equatable.dart';

class ExtendSessionResponseEntity extends Equatable {
  final String? message;

  const ExtendSessionResponseEntity({this.message});

  @override
  List<Object?> get props => [message];
}
