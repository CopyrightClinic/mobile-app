import 'package:equatable/equatable.dart';

class SetupIntentEntity extends Equatable {
  final String id;
  final String clientSecret;
  final String status;
  final String? customerId;

  const SetupIntentEntity({required this.id, required this.clientSecret, required this.status, this.customerId});

  @override
  List<Object?> get props => [id, clientSecret, status, customerId];
}
