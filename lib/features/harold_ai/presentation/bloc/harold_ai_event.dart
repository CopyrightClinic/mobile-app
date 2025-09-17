import 'package:equatable/equatable.dart';

abstract class HaroldAiEvent extends Equatable {
  const HaroldAiEvent();

  @override
  List<Object> get props => [];
}

class SubmitHaroldQuery extends HaroldAiEvent {
  final String query;
  final bool isUserAuthenticated;

  const SubmitHaroldQuery({required this.query, required this.isUserAuthenticated});

  @override
  List<Object> get props => [query, isUserAuthenticated];
}

class ResetHaroldState extends HaroldAiEvent {
  const ResetHaroldState();
}
