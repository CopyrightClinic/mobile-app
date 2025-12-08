import 'package:equatable/equatable.dart';

import '../../domain/entities/consultation_fee.dart';

abstract class HaroldAiState extends Equatable {
  const HaroldAiState();

  @override
  List<Object?> get props => [];
}

class HaroldAiInitial extends HaroldAiState {
  const HaroldAiInitial();
}

class HaroldAiLoading extends HaroldAiState {
  const HaroldAiLoading();
}

class HaroldAiSuccess extends HaroldAiState {
  final bool isUserAuthenticated;
  final String query;
  final ConsultationFee? fee;

  const HaroldAiSuccess({required this.isUserAuthenticated, required this.query, this.fee});

  @override
  List<Object?> get props => [isUserAuthenticated, query, fee];
}

class HaroldAiFailure extends HaroldAiState {
  final bool isUserAuthenticated;
  final String query;

  const HaroldAiFailure({required this.isUserAuthenticated, required this.query});

  @override
  List<Object> get props => [isUserAuthenticated, query];
}

class HaroldAiError extends HaroldAiState {
  final String message;

  const HaroldAiError({required this.message});

  @override
  List<Object> get props => [message];
}
