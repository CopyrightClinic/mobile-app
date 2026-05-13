import 'package:equatable/equatable.dart';

import '../registration_method.dart';

final class CompleteRegistrationPayload extends Equatable {
  final RegistrationMethod method;
  final String? userId;

  const CompleteRegistrationPayload({required this.method, this.userId});

  @override
  List<Object?> get props => [method, userId];
}
