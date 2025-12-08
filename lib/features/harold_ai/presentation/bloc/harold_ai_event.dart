import 'package:equatable/equatable.dart';

abstract class HaroldAiEvent extends Equatable {
  const HaroldAiEvent();

  @override
  List<Object> get props => [];
}

class SubmitHaroldQuery extends HaroldAiEvent {
  final String query;

  const SubmitHaroldQuery({required this.query});

  @override
  List<Object> get props => [query];
}

class ResetHaroldState extends HaroldAiEvent {
  const ResetHaroldState();
}
