import 'package:equatable/equatable.dart';

class HaroldIntakeResult extends Equatable {
  final Map<String, String> answersById;

  const HaroldIntakeResult({required this.answersById});

  String? answerFor(String questionId) => answersById[questionId];

  @override
  List<Object?> get props => [answersById];
}

