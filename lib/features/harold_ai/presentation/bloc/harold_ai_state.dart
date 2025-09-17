import 'package:equatable/equatable.dart';

abstract class HaroldAiState extends Equatable {
  const HaroldAiState();

  @override
  List<Object> get props => [];
}

class HaroldAiInitial extends HaroldAiState {
  const HaroldAiInitial();
}

class HaroldAiLoading extends HaroldAiState {
  const HaroldAiLoading();
}

class HaroldAiSuccess extends HaroldAiState {
  final bool isUserAuthenticated;

  const HaroldAiSuccess({required this.isUserAuthenticated});

  @override
  List<Object> get props => [isUserAuthenticated];
}

class HaroldAiFailure extends HaroldAiState {
  final bool isUserAuthenticated;

  const HaroldAiFailure({required this.isUserAuthenticated});

  @override
  List<Object> get props => [isUserAuthenticated];
}

class HaroldAiError extends HaroldAiState {
  final String message;

  const HaroldAiError({required this.message});

  @override
  List<Object> get props => [message];
}
